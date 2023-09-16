import os

import pathlib

import argparse
from dotenv import load_dotenv
from binstar_client.commands.upload import Uploader

load_dotenv()


def main(artifacts_dir, label) -> None:
    """Entrypoint of the :code:`upload` command."""
    if isinstance(artifacts_dir, str):
        artifacts_dir = pathlib.Path(artifacts_dir).resolve().absolute()

    arguments = argparse.Namespace(
        token=os.getenv("ANACONDA_TOKEN"),
        user=os.getenv("ANACONDA_USER"),
        label=label,
        labels=[label],
        site=None,
        package_type=None,
        package=None,
        version=None,
        build_id=None,
        summary=None,
        description=None,
        auto_register=True,
        private=False,
        mode="force",
        keep_basename=False,
        force_metadata_update=True
    )
    uploader: Uploader = Uploader(arguments=arguments)
    uploader.api.check_server()
    _ = uploader.username

    try:
        filename: str
        for filename in artifacts_dir.rglob("*.tar.bz2"):
            uploader.upload(str(filename))
        for filename in artifacts_dir.rglob("*.conda"):
            uploader.upload(str(filename))
    finally:
        uploader.print_uploads()
        uploader.cleanup()


if __name__ == "__main__":
    main(artifacts_dir="artifacts", label="test")
