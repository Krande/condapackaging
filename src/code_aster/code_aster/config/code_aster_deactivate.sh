#!/bin/bash

export PYTHONPATH="\${PYTHONPATH//\$CONDA_PREFIX\/lib\/aster:/}"
export LD_LIBRARY_PATH="\${LD_LIBRARY_PATH//\$CONDA_PREFIX\/lib\/aster:/}"
export C_INCLUDE_PATH="\${C_INCLUDE_PATH//\$CONDA_PREFIX\/include\/aster:/}"
export CPLUS_INCLUDE_PATH="\${CPLUS_INCLUDE_PATH//\$CONDA_PREFIX\/include\/aster:/}"
