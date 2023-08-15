#!/bin/bash

mkdir build
cd build

export TFELHOME=$PREFIX
python_version="${CONDA_PY:0:1}.${CONDA_PY:1:2}"
echo $python_version

ls $PREFIX/include/boost/python/module.hpp

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -Denable-website:BOOL=OFF \
    -Denable-doxygen-doc:BOOL=OFF \
    -Denable-c-bindings=OFF \
    -Denable-fortran-bindings=OFF \
    -Denable-python-bindings=ON \
    -Denable-portable-build=ON \
    -DPYTHONLIBS_VERSION_STRING=$PY_VER \
    -DPython_ADDITIONAL_VERSIONS=$python_version \
    -DPYTHON_EXECUTABLE:FILEPATH="${PYTHON}" \
    -DPYTHON_LIBRARY:FILEPATH="$PREFIX/lib/libpython${PY_VER}.so" \
    -DPYTHON_LIBRARY_PATH:PATH="$PREFIX/lib" \
    -DPYTHON_INCLUDE_DIRS="$PREFIX/include;$PREFIX/include/boost/python;$PREFIX/include/python3.9" \
    -DPYTHON_INCLUDE_PATH="$PREFIX/include" \
    -DBoost_INCLUDE_DIRS="$PREFIX/include" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}"

ls $PREFIX/include/boost/python/module.hpp

make VERBOSE=2
make install