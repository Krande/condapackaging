import os
import pathlib
import re

ROOT_DIR = pathlib.Path(__file__).parent.parent.parent.parent


def set_output(name, value):
    with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
        print(f'{name}={value}', file=fh)


def main():
    # Get Code Aster Version
    with open(ROOT_DIR / 'src/code_aster/code_aster/meta.yaml', 'r') as file:
        text = file.read()

    version_pattern = r"{%\s*set\s+version\s*=\s*['\"](.+?)['\"]\s*%}"
    match = re.search(version_pattern, text)
    if match:
        result = match.group(1)
        set_output('code_aster_version', result)
        print(f"Code Aster version: {result}")
    else:
        raise ValueError('Unable to find version number')

    # Auto generate Conda label if not manually set
    conda_label = os.getenv('CONDA_LABEL', None)
    if not conda_label:
        conda_label = "ca-${{ github.run_id }}"

    print(f"{conda_label=}")
    set_output('unique_suffix', conda_label)


if __name__ == '__main__':
    main()
