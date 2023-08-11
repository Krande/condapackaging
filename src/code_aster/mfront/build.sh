#!/bin/bash

export LDFLAGS="-L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp"
export LIBPATH="$PREFIX/lib $LIBPATH"

cmake -S . -B build \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=Release \
    -Dlocal-castem-header=ON \
    -Denable-fortran=ON \
    -Denable-python-bindings=ON \
    -Denable-cyrano=ON \
    -Denable-aster=ON \
    -Ddisable-reference-doc=ON \
    -Ddisable-website=ON \
    -Denable-portable-build=ON \
    -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
    -Denable-python=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX


cmake --build ./build --config Release

cmake --install ./build --verbose
