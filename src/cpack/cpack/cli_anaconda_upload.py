import argparse
import os
import pathlib
from typing import Annotated

import typer
from binstar_client.commands.upload import Uploader
from dotenv import load_dotenv

app = typer.Typer()
load_dotenv()


@app.command(name="upload")
def main(artifacts_dir: str, label: str, user: str, token: Annotated[str, typer.Argument(envvar="CONDA_API_TOKEN")]):
    """Entrypoint of the :code:`upload` command."""
    if isinstance(artifacts_dir, str):
        artifacts_dir = pathlib.Path(artifacts_dir).resolve().absolute()

    arguments = argparse.Namespace(
        token=token,
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
            print(f"Uploading {filename}")
            uploader.upload(str(filename))
        for filename in artifacts_dir.rglob("*.conda"):
            print(f"Uploading {filename}")
            uploader.upload(str(filename))
    finally:
        uploader.print_uploads()
        uploader.cleanup()


if __name__ == "__main__":
    app()
