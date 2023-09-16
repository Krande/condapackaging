import json

from cpack.matrix_builder import main as matrix_builder_main


def test_matrix_builder_variant1():
    pyver = "3.10,3.11"
    platforms = "windows-latest,ubuntu-latest,macos-latest"
    variants = "occt=7.7.2=*novtk*;hdf5=1.10.6=*nompi*,occt=7.7.2=*novtk*;hdf5=1.10.6=*mpi*"
    matrix = matrix_builder_main(pyver, platforms, variants)
    assert matrix == {
        "pyver": ["3.10", "3.11"],
        "platform": [
            {"os": "windows-latest", "short": "win"},
            {"os": "ubuntu-latest", "short": "linux"},
            {"os": "macos-latest", "short": "macos"},
        ],
        "variants": [
            {
                "key": "occt,hdf5",
                "value": "occt=7.7.2=*novtk*;hdf5=1.10.6=*nompi*",
                "var_str": " --variants= \"{'occt': '7.7.2=*novtk*', 'hdf5': '1.10.6=*nompi*'}\"",
            },
            {
                "key": "occt,hdf5",
                "value": "occt=7.7.2=*novtk*;hdf5=1.10.6=*mpi*",
                "var_str": " --variants= \"{'occt': '7.7.2=*novtk*', 'hdf5': '1.10.6=*mpi*'}\"",
            },
        ],
    }


def test_matrix_builder_variant2():
    pyver = "3.10,3.11"
    platforms = "windows-latest,ubuntu-latest,macos-latest"
    variants = "occt=7.7.2=*novtk*,occt=7.7.2=*all*"
    matrix = matrix_builder_main(pyver, platforms, variants)
    assert matrix == {
        "pyver": ["3.10", "3.11"],
        "platform": [
            {"os": "windows-latest", "short": "win"},
            {"os": "ubuntu-latest", "short": "linux"},
            {"os": "macos-latest", "short": "macos"},
        ],
        "variants": [
            {"key": "occt", "value": "occt=7.7.2=*novtk*", "var_str": " --variants= \"{'occt': '7.7.2=*novtk*'}\""},
            {"key": "occt", "value": "occt=7.7.2=*all*", "var_str": " --variants= \"{'occt': '7.7.2=*all*'}\""},
        ],
    }
