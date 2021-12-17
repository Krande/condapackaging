#!/bin/bash

declare -a CMAKE_PLATFORM_FLAGS

if [ `uname` == Darwin ]; then
    export CFLAGS="$CFLAGS   -Wl,-flat_namespace,-undefined,suppress"
    export CXXFLAGS="$CXXFLAGS -Wl,-flat_namespace,-undefined,suppress"
    export LDFLAGS="$LDFLAGS  -Wl,-flat_namespace,-undefined,suppress"
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
 -DOCC_INCLUDE_DIR=$PREFIX/include/opencascade \
 -DOCC_LIBRARY_DIR=$PREFIX/lib \
 -DHDF5_INCLUDE_DIR:FILEPATH=$PREFIX\include ^
 -DHDF5_LIBRARY_DIR:FILEPATH=$PREFIX\lib ^
 -DCGAL_INCLUDE_DIR=$PREFIX/include/CGAL \
 -DCOLLADA_SUPPORT:BOOL=OFF \
 -DBUILD_EXAMPLES:BOOL=OFF \
 -DIFCXML_SUPPORT:BOOL=OFF \
 -DBUILD_GEOMSERVER:BOOL=ON \
 -DBUILD_CONVERT:BOOL=ON \
 -DBUILD_IFCPYTHON:BOOL=ON \
 -DBUILD_IFCGEOM:BOOL=ON \
 ./cmake

ninja

ninja install