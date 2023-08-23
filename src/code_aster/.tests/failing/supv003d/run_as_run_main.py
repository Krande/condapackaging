import os
import pathlib

from run_aster.run_aster_main import main as run_aster_main
from run_aster.export import Export, File
from run_aster.run import RunAster

conda_prefix = os.getenv('CONDA_PREFIX')
os.environ['LD_LIBRARY_PATH'] = conda_prefix + "/lib/aster"
os.environ['ASTER_LIBDIR'] = conda_prefix + "/lib/aster"
os.environ['ASTER_DATADIR'] = conda_prefix + "/share/aster"
os.environ['ASTER_LOCALEDIR'] = conda_prefix + "/share/locale/aster"
os.environ['ASTER_ELEMENTSDIR'] = conda_prefix + "/lib/aster"

export_file = 'supv003d.export'

wrkdir = 'temp/pynative2'

exp_file = pathlib.Path(export_file).absolute()
export = Export(export_file, test=True)
export.add_file(File('supv003d.comm'))
export.add_file(File('supv003d.com1'))
export.add_file(File('efica01a.mail'))
# export.set_argument(['--memory', '3512.0', '--tpmax', '60', '--numthreads', '1'])

opts = {}
opts["test"] = "--test"
opts["env"] = False
opts["tee"] = True
opts["interactive"] = False

calc = RunAster.factory(export, **opts)
status = calc.execute(wrkdir)
exitcode = status.exitcode
print(exitcode)
# run_aster_main([export_file])