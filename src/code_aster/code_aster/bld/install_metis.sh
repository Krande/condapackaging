#!/bin/bash

# Install metis-aster
echo "** Building METIS **"

cd deps/metis-aster

mkdir -p $PREFIX/metis-aster

make config prefix=$PREFIX/metis-aster

make -j 1
make install

cd ../..

echo "METIS Build complete"