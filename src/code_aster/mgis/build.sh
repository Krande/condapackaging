#!/bin/bash

mkdir build
cd build

export INCLUDES_BOOST="$PREFIX/include/boost"
export LIBPATH_BOOST="$PREFIX/lib"
export LIB_BOOST="libboost_python$CONDA_PY"
export TFELHOME=$PREFIX

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -Denable-website:BOOL=OFF \
    -Denable-doxygen-doc:BOOL=OFF \
    -Denable-c-bindings=OFF -Denable-fortran-bindings=OFF \
    -Denable-broken-boost-python-module-visibility-handling=ON \
    -Denable-python-bindings=ON \
    -Denable-portable-build=ON \
    -DBOOST_INCLUDEDIR=${INCLUDES_BOOST} \
    -DBOOST_LIBRARYDIR=${LIBPATH_BOOST} \
    -DPYTHONLIBS_VERSION_STRING=$PY_VER \
    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
    -DPYTHON_LIBRARY:FILEPATH="$PREFIX/lib/libpython${PY_VER}.so" \
    -DPYTHON_INCLUDE_DIR="$PREFIX/include" \
    "${CA_CFG_MFRONT[@]}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"
make
make install