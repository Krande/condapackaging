#!/bin/bash

echo "Build MFRONT/TFEL"
# assuming you have already downloaded tfel using the conda recipe to "deps/mfront"

cd deps/mfront
mkdir -p build
cd build

export VERSION_TFEL=3.4.0

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DTFEL_SVN_REVISION=${VERSION_TFEL} \
    -DTFEL_APPEND_VERSION=${VERSION_TFEL} \
    -Dlocal-castem-header=ON \
    -Denable-fortran=ON \
    -Denable-broken-boost-python-module-visibility-handling=ON \
    -Denable-python-bindings=ON \
    -Denable-cyrano=ON -Denable-aster=ON \
    -Ddisable-reference-doc=ON \
    -Ddisable-website=ON \
    -Denable-portable-build=ON \
    -DPython_ADDITIONAL_VERSIONS=${CONDA_PY} \
    -Denable-python=ON \
    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
    -DPYTHON_LIBRARY:FILEPATH=${PREFIX}/lib/libpython${CONDA_PY}.so \
    -DPYTHON_INCLUDE_DIR:PATH=${PREFIX}/include/python${CONDA_PY} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX}

make -j $(nproc) install
echo "MFRONT/TFEL build complete"