#!/bin/bash

# Install metis-aster
echo "** Building METIS **"

mkdir -p $PREFIX
make config prefix=$PREFIX
make
make install

echo "METIS Build complete"