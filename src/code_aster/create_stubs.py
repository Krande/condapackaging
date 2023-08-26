import os
import pathlib
import shutil

import pybind11_stubgen
conda_prefix = os.getenv('CONDA_PREFIX')

stubs_dir = pathlib.Path(__file__).parent / 'stubs' / 'code_aster-stubs'
aster_lib = pathlib.Path(conda_prefix) / 'lib' / 'aster' / 'code_aster'
dummy_lib = './dummy_lib'
# pybind11_stubgen.main(['--help'])

pybind11_stubgen.main(['code_aster', '--ignore-invalid=all', '--no-setup-py', '--skip-signature-downgrade'])
# shutil.copytree('stubs', dummy_lib, dirs_exist_ok=True)
