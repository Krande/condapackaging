#!/usr/bin/env bash

export PYTHONPATH=$(echo $PYTHONPATH | sed "s|$CONDA_PREFIX/lib/aster:||g")
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed "s|$CONDA_PREFIX/lib/aster:||g")

export C_INCLUDE_PATH=$(echo $C_INCLUDE_PATH | sed "s|$CONDA_PREFIX/include/aster:||g")
export CPLUS_INCLUDE_PATH=$(echo $CPLUS_INCLUDE_PATH | sed "s|$CONDA_PREFIX/include/aster:||g")

# These seem to cause pycharm marking the python interpreter as invalid when used on WSL2 on windows
## Restore original values of environment variables, or unset them if they were not previously set
#export ASTER_LIBDIR=$(cat $CONDA_PREFIX/.aster_libdir_old 2> /dev/null || echo "")
#export ASTER_DATADIR=$(cat $CONDA_PREFIX/.aster_datadir_old 2> /dev/null || echo "")
#export ASTER_LOCALEDIR=$(cat $CONDA_PREFIX/.aster_localedir_old 2> /dev/null || echo "")
#export ASTER_ELEMENTSDIR=$(cat $CONDA_PREFIX/.aster_elementsdir_old 2> /dev/null || echo "")
#
## Remove temporary files
#rm -f $CONDA_PREFIX/.aster_libdir_old
#rm -f $CONDA_PREFIX/.aster_datadir_old
#rm -f $CONDA_PREFIX/.aster_localedir_old
#rm -f $CONDA_PREFIX/.aster_elementsdir_old

# Do simply this instead

unset ASTER_LIBDIR
unset ASTER_DATADIR
unset ASTER_LOCALEDIR
unset ASTER_ELEMENTSDIR