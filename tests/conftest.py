import pathlib
import pytest


@pytest.fixture
def root_dir():
    return pathlib.Path(__file__).parent


@pytest.fixture
def files_dir(root_dir):
    return root_dir / "files"
