#!/bin/bash

# Install metis-aster
echo "** Building MEDCOUPLING **"

cd deps/medcoupling
mkdir -p build
cd build

cmake .. \
    -DCMAKE_INSTALL_PREFIX=install \
    -DMEDCOUPLING_MICROMED=ON \
    -DMEDCOUPLING_BUILD_DOC=OFF \
    -DMEDCOUPLING_ENABLE_PARTITIONER=OFF \
    -DMEDCOUPLING_BUILD_TESTS=OFF \
    -DMEDCOUPLING_ENABLE_RENUMBER=OFF \
    -DMEDCOUPLING_WITH_FILE_EXAMPLES=OFF \
    -DMEDCOUPLING_USE_64BIT_IDS=OFF

cd ../..

echo "MEDCOUPLING Build complete"