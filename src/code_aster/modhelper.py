import pathlib

import ruamel.yaml
from ruamel.yaml import YAML

yaml = YAML(typ='rt')
#yaml.explicit_start = True
yaml.indent(mapping=2, offset=2)
yaml.preserve_quotes = True  # not necessary for your current input
yaml.allow_duplicate_keys = True


def iter_valid_dirs(root_dir, return_file="conda_build_config.yaml"):
    for subdir in pathlib.Path(root_dir).iterdir():
        if not subdir.is_dir():
            continue
        config_file = subdir.joinpath(return_file)
        if not config_file.exists():
            continue
        yield config_file


def ensure_consistent_package_versions(package, version, root_dir='.'):
    """Add strict versioning to the conda_build_config.yaml files for specific packages"""
    for config_file in iter_valid_dirs(root_dir):
        with open(config_file, 'r') as f:
            data = yaml.load(f)

        if data.get(package, None) is None:
            data.setdefault(package, [version])
        else:
            data[package][0] = version

        with open(config_file, 'w') as f:
            yaml.dump(data, f)


def add_pin_run_as_build(package, max_version=None, min_version=None, root_dir='.'):
    """Add strict versioning to the conda_build_config.yaml files for specific packages"""
    for config_file in iter_valid_dirs(root_dir):
        with open(config_file, 'r') as f:
            data = yaml.load(f)
        pins = {}
        if min_version is not None:
            pins['min_version'] = min_version
        if max_version is not None:
            pins['max_version'] = max_version

        if data.get('pin_run_as_build', None) is None:
            data.setdefault('pin_run_as_build', {})

        data['pin_run_as_build'][package] = pins

        with open(config_file, 'w') as f:
            yaml.dump(data, f)
        break


def change_compilers(compiler_version, root_dir='.'):
    """Make changes to the compiler versions set in the conda_build_config.yaml files"""
    for config_file in iter_valid_dirs(root_dir):
        with open(config_file, 'r') as f:
            data = yaml.load(f)

        compilers = ["c_compiler_version", "cxx_compiler_version", "fortran_compiler_version", "libgomp"]
        for cver in compilers:
            if data.get(cver, None) is None:
                continue
            data[cver][0] = compiler_version

        with open(config_file, 'w') as f:
            yaml.dump(data, f)


def set_meta_requirement(req_type, package, version=None, root_dir='.'):
    if req_type not in ['build', 'host', 'run']:
        raise ValueError('req_type must be either build, host or run')
    meta = list(iter_valid_dirs(root_dir, 'meta.yaml')) + list(iter_valid_dirs(root_dir, 'recipe.yaml'))
    for meta_file in meta:
        with open(meta_file, 'r') as f:
            data = yaml.load(f)

        requirement: ruamel.yaml.CommentedSeq = data['requirements'][req_type]
        if package not in requirement:
            requirement.append(package)

        with open(meta_file, 'w') as f:
            yaml.dump(data, f)


if __name__ == '__main__':
    compiler_version = 8
    # This will harmonize all compilers to same version
    change_compilers(compiler_version)
    # set_meta_requirement('build', 'sysroot_linux-64', '2.17')
    # for dep in ['libgomp']:
    #     ensure_consistent_package_versions(dep, compiler_version)
    #     set_meta_requirement('build', dep)

    # various dependencies that ought to be pinned
    # ensure_consistent_package_versions('numpy', '1.23')
    # ensure_consistent_package_versions('libgomp', '1.23')
    ensure_consistent_package_versions('hdf5', '1.10.6=nompi*')
    # add_pin_run_as_build('hdf5', min_version='x.x.x', max_version='x.x.x')
