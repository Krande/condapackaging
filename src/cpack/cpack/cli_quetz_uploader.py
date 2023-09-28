import logging
import os
import pathlib
from dataclasses import dataclass

import requests
import typer
from quetz_client import QuetzClient
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

        for channel in self.client.yield_channels():
            print(channel)

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


@app.command(name="create-channel")
def create_channel(channel: str, channel_description: str = "", create_public_channel: bool = True):
    qm = QuetzManager()
    qm.add_channel(channel, private=not create_public_channel, description=channel_description)


@app.command(name="upload")
def quetz_manager(package_dir: str, channel: str,
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
