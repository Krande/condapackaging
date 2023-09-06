# minimal setup.py for conda-forge

import os
from setuptools import setup


def get_version():
    """Get the version from the version.py file."""
    version_file = os.path.join(
        os.path.dirname(__file__), "src", "ifcopenshell", "version.py"
    )
    with open(version_file) as f:
        for line in f:
            if line.startswith("__version__"):
                return line.split("=")[1].strip().strip('"')
    raise RuntimeError("Unable to find version string.")


def get_long_description():
    """Get the long description from the README file."""
    with open("README.md") as f:
        return f.read()


setup(
    name="ifcopenshell",
    version=get_version(),
    description="Python bindings for the IFCOpenShell library",
    long_description=get_long_description(),
    long_description_content_type="text/markdown",
)
