#!/bin/bash

cmake . \
    -DCMAKE_BUILD_TYPE=Release \
    -Dlocal-castem-header=ON -Denable-fortran=OFF \
    -Denable-broken-boost-python-module-visibility-handling=ON \
    -Denable-python-bindings=ON \
    -Denable-cyrano=ON -Denable-aster=ON \
    -Ddisable-reference-doc=ON -Ddisable-website=ON \
    -Denable-portable-build=ON \
    -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
    -Denable-python=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX

# shellcheck disable=SC2046
make -j $(nproc) install