import re
from dataclasses import dataclass


@dataclass
class Package:
    name: str
    version: str
    build: str


def get_meta_package_version(meta_yaml_file) -> str:
    with open(meta_yaml_file, 'r') as file:
        text = file.read()
    version_pattern = r"{%\s*set\s+version\s*=\s*['\"](.+?)['\"]\s*%}"
    match = re.search(version_pattern, text)
    if match:
        return match.group(1)
    else:
        raise ValueError('Unable to find version number')


if __name__ == '__main__':
    result = get_meta_package_version(r'/home/kristoffer/code/condapackaging/src/code_aster/code_aster/meta.yaml')
    print(f'{result=}')
