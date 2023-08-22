#!/bin/bash

# Install metis-aster
echo "** Building METIS **"

# The -fPIC flag is automatically added by conda-build, but I'll add it here just in case
mkdir -p $PREFIX
make config prefix=$PREFIX CFLAGS="-fPIC ${CFLAGS}"
make
make install

echo "METIS Build complete"