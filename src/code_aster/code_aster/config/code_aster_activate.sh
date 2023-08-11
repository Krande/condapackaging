#!/bin/bash

# Save current values of environment variables
echo $ASTER_LIBDIR > $CONDA_PREFIX/.aster_libdir_old
echo $ASTER_DATADIR > $CONDA_PREFIX/.aster_datadir_old
echo $ASTER_LOCALEDIR > $CONDA_PREFIX/.aster_localedir_old
echo $ASTER_ELEMENTSDIR > $CONDA_PREFIX/.aster_elementsdir_old


export PYTHONPATH="$PYTHONPATH:$CONDA_PREFIX/lib/aster"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/aster"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:$CONDA_PREFIX/include/aster"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$CONDA_PREFIX/include/aster"

export ASTER_LIBDIR="$CONDA_PREFIX/lib/aster"
export ASTER_DATADIR="$CONDA_PREFIX/share/aster"
export ASTER_LOCALEDIR="$CONDA_PREFIX/share/locale/aster"
export ASTER_ELEMENTSDIR="$CONDA_PREFIX/lib/aster"
