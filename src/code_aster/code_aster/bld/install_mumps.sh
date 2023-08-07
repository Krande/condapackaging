#!/bin/bash

echo "**************** M U M P S  B U I L D  S T A R T S  H E R E ****************"

cd deps/mumps-aster

$PYTHON waf configure install --prefix=${PREFIX}/mumps-aster --enable-metis --embed-metis --enable-scotch -j 1

cd ../..

echo "**************** M U M P S  B U I L D  E N D S  H E R E ****************"
