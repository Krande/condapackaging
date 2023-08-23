#!/usr/bin/env bash

# https://docs.conda.io/projects/conda/en/latest/dev-guide/deep-dives/activation.html

export PYTHONPATH="${CONDA_PREFIX}/lib/aster:${PYTHONPATH}"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib/aster:${LD_LIBRARY_PATH}"

# Not sure if these really matter
export C_INCLUDE_PATH="${CONDA_PREFIX}/include/aster:${C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="${CONDA_PREFIX}/include/aster:${CPLUS_INCLUDE_PATH}"

# Save current values of environment variables
# Will allow
#echo "$ASTER_LIBDIR" > "$CONDA_PREFIX/.aster_libdir_old"
#echo "$ASTER_DATADIR" > "$CONDA_PREFIX/.aster_datadir_old"
#echo "$ASTER_LOCALEDIR" > "$CONDA_PREFIX/.aster_localedir_old"
#echo "$ASTER_ELEMENTSDIR" > "$CONDA_PREFIX/.aster_elementsdir_old"

export ASTER_LIBDIR="$CONDA_PREFIX/lib/aster"
export ASTER_DATADIR="$CONDA_PREFIX/share/aster"
export ASTER_LOCALEDIR="$CONDA_PREFIX/share/locale/aster"
export ASTER_ELEMENTSDIR="$CONDA_PREFIX/lib/aster"
