#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS

if [ `uname` == Darwin ]; then
    export CFLAGS="$CFLAGS   -Wl,-flat_namespace,-undefined,suppress"
    export CXXFLAGS="$CXXFLAGS -Wl,-flat_namespace,-undefined,suppress"
    export LDFLAGS="$LDFLAGS  -Wl,-flat_namespace,-undefined,suppress"
    export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib"
else
    CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")
fi

cmake -G Ninja \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DCMAKE_BUILD_TYPE=Release \
  ${CMAKE_PLATFORM_FLAGS[@]} \
 -DCMAKE_PREFIX_PATH=$PREFIX \
 -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
 -DPython3_FIND_STRATEGY=LOCATION \
 -DPython3_FIND_FRAMEWORK=NEVER \
 -DGMP_LIBRARY_DIR=$PREFIX/lib \
 -DMPFR_LIBRARY_DIR=$PREFIX/lib \
 -DOCC_INCLUDE_DIR=$PREFIX/include/opencascade \
 -DOCC_LIBRARY_DIR=$PREFIX/lib \
 -DHDF5_SUPPORT:BOOL=ON \
 -DHDF5_INCLUDE_DIR=$PREFIX/include \
 -DHDF5_LIBRARY_DIR=$PREFIX/lib \
 -DJSON_INCLUDE_DIR=$PREFIX/include \
 -DCGAL_INCLUDE_DIR=$PREFIX/include \
 -DCOLLADA_SUPPORT:BOOL=OFF \
 -DBUILD_EXAMPLES:BOOL=OFF \
 -DIFCXML_SUPPORT:BOOL=OFF \
 -DBUILD_CONVERT:BOOL=ON \
 -DBUILD_IFCPYTHON:BOOL=ON \
 -DBUILD_IFCGEOM:BOOL=ON \
 ./cmake

ninja

ninja install
