import pathlib

import subprocess
import shutil

def main(module_name):
    lib_so = pathlib.Path(__import__(module_name).__file__)

    subprocess.run(['pybind11-stubgen', module_name, '--ignore-all-errors'])
    shutil.copy(f'stubs/{module_name}.pyi', lib_so.with_suffix('.pyi'))

if __name__ == '__main__':
    main('libaster')