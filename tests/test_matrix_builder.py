from cpack.matrix_builder import create_actions_matrix as matrix_builder_main, convert_from_bytes_str


def test_matrix_builder_variant_specify_os():
    pyver = "3.10,3.11"
    platforms = "windows-2022"
    variants = "mpi=nompi,mpi=openmpi"
    matrix = matrix_builder_main(pyver, platforms, variants)
    assert matrix == {
        "pyver": ["3.10", "3.11"],
        "platform": [{"os": "windows-2022", "short": "win"}],
        "variants": [
            {"key": "mpi", "value": "mpi=nompi", "var_str": "IC0tdmFyaWFudHM9InsnbXBpJzogJ25vbXBpJ30i", "mpi": "nompi"},
            {"key": "mpi", "value": "mpi=openmpi", "var_str": "IC0tdmFyaWFudHM9InsnbXBpJzogJ29wZW5tcGknfSI=",
             "mpi": "openmpi"},
        ],
    }


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
                'hdf5': '1.10.6=*nompi*', 'occt': '7.7.2=*novtk*'
            },
            {
                "key": "occt,hdf5",
                "value": "occt=7.7.2=*novtk*;hdf5=1.10.6=*mpi*",
                "var_str": "IC0tdmFyaWFudHM9Insnb2NjdCc6ICc3LjcuMj0qbm92dGsqJywgJ2hkZjUnOiAnMS4xMC42PSptcGkqJ30i",
                'hdf5': '1.10.6=*mpi*', 'occt': '7.7.2=*novtk*'
            },
        ],
    }
    # decode the var_strings to see what they look like

    # decode the first var_str
    decoded_str = convert_from_bytes_str(matrix["variants"][0]["var_str"])
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*novtk*', 'hdf5': '1.10.6=*nompi*'}\""

    # decode the second var_str
    decoded_str = convert_from_bytes_str(matrix["variants"][1]["var_str"])
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
                "occt": "7.7.2=*novtk*",
            },
            {
                "key": "occt",
                "value": "occt=7.7.2=*all*",
                "var_str": "IC0tdmFyaWFudHM9Insnb2NjdCc6ICc3LjcuMj0qYWxsKid9Ig==",
                "occt": "7.7.2=*all*",
            },
        ],
    }

    # decode the var_strings to see what they look like
    decoded_str = convert_from_bytes_str(matrix["variants"][0]["var_str"])
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*novtk*'}\""

    decoded_str = convert_from_bytes_str(matrix["variants"][1]["var_str"])
    assert decoded_str == " --variants=\"{'occt': '7.7.2=*all*'}\""


def test_matrix_builder_variant_config_only_hdf5_file(root_dir):
    pyver = "3.10,3.11"
    platforms = "windows-latest,ubuntu-latest,macos-latest"
    variants = root_dir / "files" / "variant_config_hdf5_only.yaml"
    matrix = matrix_builder_main(pyver, platforms, variants.as_posix())

    decoded_str = convert_from_bytes_str(matrix["variants"][0]["var_str"])
    assert decoded_str == " --variants=\"{'hdf5': '1.10.6=*mpi*openmpi'}\""

    decoded_str = convert_from_bytes_str(matrix["variants"][1]["var_str"])
    assert decoded_str == " --variants=\"{'hdf5': '1.10.6=*nompi*'}\""


def test_matrix_builder_zip_keys_config_file(root_dir):
    pyver = "3.10,3.11"
    platforms = "windows-latest,ubuntu-latest,macos-latest"
    variants = root_dir / "files" / "variant_config_zip_keys.yaml"
    matrix = matrix_builder_main(pyver, platforms, variants.as_posix())

    decoded_str = convert_from_bytes_str(matrix["variants"][0]["var_str"])
    assert decoded_str == " --variants=\"{'hdf5': '1.10.6=*mpi*openmpi'}\""

    decoded_str = convert_from_bytes_str(matrix["variants"][1]["var_str"])
    assert decoded_str == " --variants=\"{'hdf5': '1.10.6=*nompi*'}\""


def test_matrix_v1(root_dir):
    pyver = "3.12"
    platforms = "windows-latest"
    variants = ""
    recipe_file = root_dir / "files" / "recipe_v1/recipe.yaml"
    extra_recipe_config = ""
    matrix = matrix_builder_main(pyver, platforms, variants, recipe_file=recipe_file.as_posix(),
                                 extra_config=extra_recipe_config)
    print(matrix)
    decoded_str = convert_from_bytes_str(matrix["variants"][0]["yaml_str"])
    print(decoded_str)


def test_matrix_v1_multi_os(root_dir):
    pyver = "3.12"
    platforms = "windows-latest"
    variants = ""
    recipe_file = root_dir / "files" / "recipe_v1_multi_os/recipe.yaml"
    extra_recipe_config = ""
    matrix = matrix_builder_main(pyver, platforms, variants, recipe_file=recipe_file.as_posix(),
                                 extra_config=extra_recipe_config)
    print(matrix)
    for variant in matrix["variants"]:
        decoded_str = convert_from_bytes_str(variant["yaml_str"])
        print(decoded_str)


def test_matrix_v1_multi_output(root_dir):
    pyver = "3.12"
    platforms = "windows-latest"
    variants = ""
    recipe_file = root_dir / "files" / "recipe_v1_multi_output/recipe.yaml"
    extra_recipe_config = "--experimental"
    matrix = matrix_builder_main(pyver, platforms, variants, recipe_file=recipe_file.as_posix(),
                                 extra_config=extra_recipe_config)
    print(matrix)
    for variant in matrix["variants"]:
        decoded_str = convert_from_bytes_str(variant["yaml_str"])
        print(decoded_str)


def test_matrix_v0(root_dir):
    pyver = "3.12"
    platforms = "windows-latest"
    variants = ""
    recipe_file = root_dir / "files" / "recipe_v1/recipe.yaml"
    extra_recipe_config = ""
    matrix = matrix_builder_main(pyver, platforms, variants, recipe_file=recipe_file.as_posix(),
                                 extra_config=extra_recipe_config)
    print(matrix)
    decoded_str = convert_from_bytes_str(matrix["variants"][0]["var_str"])
    print(decoded_str)
