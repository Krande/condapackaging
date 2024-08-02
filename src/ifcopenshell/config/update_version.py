import re


def update_version_string(init_file_path: str, version: str):
    result = re.sub(r'__version__ = version = ".*"', f'__version__ = version = "{version}"',
                    open(init_file_path, 'r').read(), flags=re.MULTILINE | re.DOTALL)
    with open(init_file_path, 'w') as f:
        f.write(result)


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Update version string in __init__.py')
    parser.add_argument('init_file_path', type=str, help='Path to __init__.py file')
    parser.add_argument('version', type=str, help='New version string')
    args = parser.parse_args()

    update_version_string(args.init_file_path, args.version)
