# supv003d

This fails on python versions 3.9 and 3.10, but not on python 3.11.

to run the file using an IDE such as Pycharm I had to include the following

run configuration -> `LD_LIBRARY_PATH=/home/../lib/aster` ie absolute path to `$CONDA_PREFIX/lib/aster`

And before importing any packages I had to do include this in the top of my python file (I could have added this :

````python
import os
conda_prefix = os.getenv('CONDA_PREFIX')
os.environ['LD_LIBRARY_PATH'] = conda_prefix + "/lib/aster"
os.environ['ASTER_LIBDIR'] = conda_prefix + "/lib/aster"
os.environ['ASTER_DATADIR'] = conda_prefix + "/share/aster"
os.environ['ASTER_LOCALEDIR'] = conda_prefix + "/share/locale/aster"
os.environ['ASTER_ELEMENTSDIR'] = conda_prefix + "/lib/aster"
````