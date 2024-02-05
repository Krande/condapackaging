import io
import logging
import os
import pathlib
import tarfile
from dataclasses import dataclass
from typing import Iterable
import libarchive

import requests
import typer
import zstandard as zstd
from quetz_client import QuetzClient
from ruamel.yaml import YAML
yaml = YAML(typ='rt')
from typing_extensions import Annotated

logger = logging.getLogger(__name__)

app = typer.Typer()


@dataclass
class QuetzManager:
    client: QuetzClient = None

    def __post_init__(self):
        if self.client is None:
            self.client = QuetzClient.from_token(os.getenv("QUETZ_URL"), os.getenv("QUETZ_API_KEY"))

    def add_channel(self, channel_name: str, private: bool = False, description: str = None):
        try:
            self.client.set_channel(channel_name, private=private, description=description)
        # except 409 client exception
        except requests.exceptions.HTTPError:
            print(f"Channel {channel_name} already exists")

    def upload_package_to_channel(self, package_file: str | pathlib.Path, channel: str, force: bool = False):
        if isinstance(package_file, str):
            package_file = pathlib.Path(package_file).resolve().absolute()

        if not package_file.exists():
            raise FileNotFoundError(f"Package file {package_file} does not exist")

        try:
            self.client.post_file_to_channel(channel, package_file, force)
        except requests.exceptions.HTTPError:
            logger.info(f"Package {package_file} already exists in channel {channel}")

    def list_packages_for_channel(self, channel: str):
        for channel in self.client.yield_packages(channel):
            print(channel)

    def get_package_metadata(self, channel: str, platform: str, package_file_name: str) -> dict:
        rfile = self.client.session.get(f"{self.client.url}/get/{channel}/{platform}/{package_file_name}", stream=True)
        rfile.raise_for_status()
        # rfile.content is a tarfile which contains zst files

        # Create a BytesIO object to hold the conda data.
        conda_stream = io.BytesIO(rfile.content)

        with libarchive.memory_reader(conda_stream.read()) as archive:
            for entry in archive:
                if not entry.pathname.endswith(".zst") or not entry.pathname.startswith("info"):
                    continue
                with io.BytesIO() as file_data:
                    for block in entry.get_blocks():
                        file_data.write(block)
                    file_data.seek(0)

                    decompressor = zstd.ZstdDecompressor()
                    with io.BytesIO() as tar_data:
                        with decompressor.stream_reader(file_data) as reader:
                            while True:
                                chunk = reader.read(16384)
                                if not chunk:
                                    break
                                tar_data.write(chunk)

                        # Go back to the start of the tar data
                        tar_data.seek(0)

                        # Read the tar file
                        with tarfile.open(fileobj=tar_data, mode="r:") as tar:
                            for tarinfo in tar:
                                if not tarinfo.name.endswith("meta.yaml"):
                                    continue
                                meta_yaml_data = yaml.load(tar.extractfile(tarinfo).read())
                                return meta_yaml_data

    def get_packages_meta_for_channel(self, channel: str, package_name=None) -> Iterable[dict]:
        try:
            for pkg in self.client.yield_packages(channel):
                if package_name is not None and pkg.name != package_name:
                    continue
                for platform in pkg.platforms:
                    r = self.client.session.get(f"{self.client.url}/get/{channel}/{platform}/repodata.json")
                    r.raise_for_status()
                    data = r.json()
                    for pkg_conda, pkg_data in data["packages.conda"].items():
                        yield self.get_package_metadata(channel, platform, pkg_conda)
        except requests.exceptions.HTTPError:
            logger.error(f"Channel {channel} does not exist")
            return {}


@app.command(name="create-channel")
def create_channel(channel: str, channel_description: str = "", create_public_channel: bool = True):
    qm = QuetzManager()
    qm.add_channel(channel, private=not create_public_channel, description=channel_description)


@app.command(name="upload")
def quetz_manager(
    package_dir: str,
    channel: str,
    api_key: Annotated[str, typer.Option(envvar="QUETZ_API_KEY")],
    quetz_url: Annotated[str, typer.Option(envvar="QUETZ_URL")],
    force: bool = False,
):
    client = QuetzClient.from_token(quetz_url, api_key)
    qm = QuetzManager(client=client)
    logger.info(f"uploading to channel: {channel}")
    # Loop of recursive globbing find .conda and .tar.bz2 files
    for package_file in pathlib.Path(package_dir).rglob("*.conda"):
        logger.info(f"uploading file: {package_file}")
        qm.upload_package_to_channel(package_file, channel, force=force)
    for package_file in pathlib.Path(package_dir).rglob("*.tar.bz2"):
        logger.info(f"uploading file: {package_file}")
        qm.upload_package_to_channel(package_file, channel, force=force)

    qm.list_packages_for_channel(channel)


@app.command(name="download")
def download_packages(channel: str):
    qm = QuetzManager()
    qm.list_packages_for_channel(channel)


if __name__ == "__main__":
    logger.setLevel(logging.INFO)
    app()
