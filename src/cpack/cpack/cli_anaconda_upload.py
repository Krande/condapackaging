import os

import pathlib

import argparse
import typer
from dotenv import load_dotenv
from binstar_client.commands.upload import Uploader

app = typer.Typer()
load_dotenv()


def main(artifacts_dir, label, user) -> None:
    """Entrypoint of the :code:`upload` command."""
    if isinstance(artifacts_dir, str):
        artifacts_dir = pathlib.Path(artifacts_dir).resolve().absolute()

    arguments = argparse.Namespace(
        token=os.getenv("ANACONDA_TOKEN"),
        user=user,
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
        force_metadata_update=True,
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


@app.command(name="upload")
def upload(artifacts_dir: str, label: str, user: str):
    main(artifacts_dir, label, user)


if __name__ == "__main__":
    app()

