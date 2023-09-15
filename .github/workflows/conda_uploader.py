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

    def add_channel(self, channel_name: str, force: bool = False):
        try:
            self.client.set_channel(channel_name)
        # except 409 client exception
        except requests.exceptions.HTTPError as e:
            logger.info(f"Channel {channel_name} already exists")
            if not force:
                raise e

        for channel in self.client.yield_channels():
            logger.info(channel)

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


@app.command()
def quetz_manager(package_dir: str, channel: str, make_unique_label: bool = False):
    qm = QuetzManager()
    # if make_unique_label add a date string suffix to the channel name
    if make_unique_label:
        import datetime

        channel = f"{channel}-{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}"

    qm.add_channel(channel)
    # Loop of recursive globbing find .conda and .tar.bz2 files
    for package_file in pathlib.Path(package_dir).rglob("*.conda"):
        qm.upload_package_to_channel(package_file, channel)
    for package_file in pathlib.Path(package_dir).rglob("*.tar.bz2"):
        qm.upload_package_to_channel(package_file, channel)

    qm.list_packages_for_channel(channel)


if __name__ == "__main__":
    app()
