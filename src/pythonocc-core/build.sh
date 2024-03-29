#!/bin/bash

mkdir build
cd build

# Configure step
cmake ${CMAKE_ARGS} -G Ninja \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D PYTHONOCC_BUILD_TYPE=Release \
  -D Python3_FIND_STRATEGY=LOCATION \
  -D Python3_FIND_FRAMEWORK=NEVER \
  -D SWIG_HIDE_WARNINGS=ON \
  -D PYTHONOCC_INSTALL_DIRECTORY:FILEPATH=$SP_DIR/OCC \
  -D PYTHONOCC_MESHDS_NUMPY:BOOL=ON \
  -D PYTHON3_NUMPY_INCLUDE_DIRS:FILEPATH=${PREFIX}/include \
  ..

# Install step
ninja install
