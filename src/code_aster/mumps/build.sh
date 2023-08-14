#!/bin/bash

echo "**************** M U M P S  B U I L D  S T A R T S  H E R E ****************"

#export METIS_LIBS="$PREFIX/metis-aster"
#export METIS_INCLUDES="$PREFIX/metis-aster/include"

export CFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"
export FCFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${FCFLAGS}"

$PYTHON waf configure install --prefix=$PREFIX --enable-metis --enable-scotch --enable-openmp

echo "**************** M U M P S  B U I L D  E N D S  H E R E ****************"
