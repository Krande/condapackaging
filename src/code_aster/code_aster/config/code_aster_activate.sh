#!/bin/bash

# Save current values of environment variables
echo $ASTER_LIBDIR > $CONDA_PREFIX/.aster_libdir_old
echo $ASTER_DATADIR > $CONDA_PREFIX/.aster_datadir_old
echo $ASTER_LOCALEDIR > $CONDA_PREFIX/.aster_localedir_old
echo $ASTER_ELEMENTSDIR > $CONDA_PREFIX/.aster_elementsdir_old


export PYTHONPATH="$PYTHONPATH:$PREFIX/lib/aster"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$PREFIX/lib/aster"
export C_INCLUDE_PATH="$C_INCLUDE_PATH:$PREFIX/include/aster"
export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:$PREFIX/include/aster"

export ASTER_LIBDIR="$PREFIX/lib/aster"
export ASTER_DATADIR="$PREFIX/share/aster"
export ASTER_LOCALEDIR="$PREFIX/share/locale/aster"
export ASTER_ELEMENTSDIR="$PREFIX/lib/aster"
