# Assuming you have created a debug suite already. This script will help debugging the failed tests.
from typing import Iterable

import pathlib

def get_related_files_from_export(export_file: pathlib.Path) -> Iterable[str]:
    with open(export_file) as f:
        for line in f:
            if not line.startswith("F "):
                continue
            yield line.split(" ")[2].strip()
def script_contains(test_dir, search_string):
    test_dir = pathlib.Path(test_dir).resolve()
    export_files = list(test_dir.rglob('*.export'))
    num_export_files = len(export_files)
    print(f'Found {num_export_files} export files')

    num_found = 0
    for export_file in export_files:
        found_ref = False
        for related_file in get_related_files_from_export(export_file):
            suffix = related_file.split('.')[-1]
            if suffix not in ('comm', 'py', 'com1'):
                continue
            with open(export_file.parent / related_file) as f:
                if search_string in f.read():
                    found_ref = True
        if found_ref:
            num_found += 1
        else:
            print(f'Not found in {export_file.stem}')
    print(f'Found {num_found} files containing {search_string}')


if __name__ == '__main__':
    script_contains("temp/py310fail_unique", "TEST_FONCTION")