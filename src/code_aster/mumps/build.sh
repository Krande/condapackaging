#!/bin/bash

echo "**************** M U M P S  B U I L D  S T A R T S  H E R E ****************"

#export METIS_LIBS="$PREFIX/metis-aster"
#export METIS_INCLUDES="$PREFIX/metis-aster/include"

$PYTHON waf configure install --prefix=$PREFIX --enable-metis --enable-scotch -j 1

echo "**************** M U M P S  B U I L D  E N D S  H E R E ****************"
