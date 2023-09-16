from cpack.matrix_builder import main as matrix_builder_main
import base64


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
                "var_str": "IC0tdmFyaWFudHM9Insnb2NjdCc6ICc3LjcuMj0qbm92dGsqJywgJ2hkZjUnOiAnMS4xMC42PSpub21waSonfSI=",
            },
            {
                "key": "occt,hdf5",
                "value": "occt=7.7.2=*novtk*;hdf5=1.10.6=*mpi*",
                "var_str": "IC0tdmFyaWFudHM9Insnb2NjdCc6ICc3LjcuMj0qbm92dGsqJywgJ2hkZjUnOiAnMS4xMC42PSptcGkqJ30i",
            },
        ],
    }
    # decode the var_strings to see what they look like

    # decode the first var_str
    var_str = matrix["variants"][0]["var_str"]
    decoded_bytes = base64.b64decode(var_str)
    decoded_str = decoded_bytes.decode("utf-8")
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*novtk*', 'hdf5': '1.10.6=*nompi*'}\""

    # decode the second var_str
    var_str = matrix["variants"][1]["var_str"]
    decoded_bytes = base64.b64decode(var_str)
    decoded_str = decoded_bytes.decode("utf-8")
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*novtk*', 'hdf5': '1.10.6=*mpi*'}\""


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
            {
                "key": "occt",
                "value": "occt=7.7.2=*novtk*",
                "var_str": "IC0tdmFyaWFudHM9Insnb2NjdCc6ICc3LjcuMj0qbm92dGsqJ30i",
            },
            {
                "key": "occt",
                "value": "occt=7.7.2=*all*",
                "var_str": "IC0tdmFyaWFudHM9Insnb2NjdCc6ICc3LjcuMj0qYWxsKid9Ig==",
            },
        ],
    }

    # decode the var_strings to see what they look like
    var_str = matrix["variants"][0]["var_str"]
    decoded_bytes = base64.b64decode(var_str)
    decoded_str = decoded_bytes.decode("utf-8")
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*novtk*'}\""

    var_str = matrix["variants"][1]["var_str"]
    decoded_bytes = base64.b64decode(var_str)
    decoded_str = decoded_bytes.decode("utf-8")
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*all*'}\""
