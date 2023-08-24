import pathlib

# import yaml
from ruamel.yaml import YAML

yaml = YAML()
yaml.explicit_start = True
yaml.indent(mapping=2, offset=2)
yaml.preserve_quotes = True  # not necessary for your current input
yaml.allow_duplicate_keys = True


def iter_valid_dirs(root_dir):
    for subdir in pathlib.Path(root_dir).iterdir():
        if not subdir.is_dir():
            continue
        config_file = subdir.joinpath("conda_build_config.yaml")
        if not config_file.exists():
            continue
        yield config_file


def ensure_consistent_numpy_versions(numpy_version, root_dir='.'):
    for config_file in iter_valid_dirs(root_dir):
        with open(config_file, 'r') as f:
            data = yaml.load(f)

        data.setdefault('numpy', [numpy_version])

        with open(config_file, 'w') as f:
            yaml.dump(data, f)


def change_compilers(compiler_version, root_dir='.'):
    """Make changes to the compiler versions set in the conda_build_config.yaml files"""
    for config_file in iter_valid_dirs(root_dir):
        with open(config_file, 'r') as f:
            data = yaml.load(f)

        compilers = ["c_compiler_version", "cxx_compiler_version", "fortran_compiler_version"]
        for cver in compilers:
            if data.get(cver, None) is None:
                continue
            data[cver][0] = compiler_version

        with open(config_file, 'w') as f:
            yaml.dump(data, f)


if __name__ == '__main__':
    # change_compilers(12)
    ensure_consistent_numpy_versions('1.22')
