#!/bin/bash

# Install metis-aster
echo "** Building METIS **"

mkdir -p $PREFIX/metis-aster
make config prefix=$PREFIX/metis-aster
make
make install

echo "METIS Build complete"