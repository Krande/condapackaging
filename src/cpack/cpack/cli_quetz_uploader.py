import os

import logging
import pathlib
import requests
import typer
from dataclasses import dataclass
from quetz_client import QuetzClient

logger = logging.getLogger(__name__)

app = typer.Typer()


API_KEY = os.getenv("QUETZ_API_KEY")
QUETZ_URL = os.getenv("QUETZ_URL")


@dataclass
class QuetzManager:
    client: QuetzClient = None

    def __post_init__(self):
        self.client = QuetzClient.from_token(QUETZ_URL, API_KEY)

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
def create_channel(channel: str, channel_description: str="", create_public_channel: bool = True):
    qm = QuetzManager()
    qm.add_channel(channel, private=not create_public_channel, description=channel_description)


@app.command(name="upload")
def quetz_manager(package_dir: str, channel: str):
    qm = QuetzManager()
    # Loop of recursive globbing find .conda and .tar.bz2 files
    for package_file in pathlib.Path(package_dir).rglob("*.conda"):
        qm.upload_package_to_channel(package_file, channel)
    for package_file in pathlib.Path(package_dir).rglob("*.tar.bz2"):
        qm.upload_package_to_channel(package_file, channel)

    qm.list_packages_for_channel(channel)


if __name__ == "__main__":
    app()
