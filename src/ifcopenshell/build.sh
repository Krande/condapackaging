#!/bin/bash
export CLICOLOR_FORCE=1

if [ `uname` == Darwin ]; then
  export CFLAGS="$CFLAGS -Wl,-twolevel_namespace"
  export CXXFLAGS="$CXXFLAGS -Wl,-twolevel_namespace"
  export LDFLAGS="$LDFLAGS -Wl,-twolevel_namespace"
fi

# Overwrite the CMakeLists.txt file with the one from the config folder (which has a fix for finding hdf5 and zlibs)
cp $RECIPE_DIR/config/CMakeLists.txt "${SRC_DIR}/cmake/CMakeLists.txt"

cmake -G Ninja \
 -Wno-dev \
 -DSCHEMA_VERSIONS="2x3;4;4x1;4x3_add1" \
 -DCMAKE_BUILD_TYPE=Release \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
 -DCMAKE_PREFIX_PATH=$PREFIX \
 -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
 -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
 -DGMP_LIBRARY_DIR=$PREFIX/lib \
 -DMPFR_LIBRARY_DIR=$PREFIX/lib \
 -DOCC_INCLUDE_DIR=$PREFIX/include/opencascade \
 -DOCC_LIBRARY_DIR=$PREFIX/lib \
 -DHDF5_SUPPORT:BOOL=ON \
 -DHDF5_INCLUDE_DIR=$PREFIX/include \
 -DHDF5_LIBRARY_DIR=$PREFIX/lib \
 -DJSON_INCLUDE_DIR=$PREFIX/include \
 -DCGAL_INCLUDE_DIR=$PREFIX/include \
 -DCOLLADA_SUPPORT=0 \
 -DBUILD_EXAMPLES:BOOL=OFF \
 -DIFCXML_SUPPORT:BOOL=ON \
 -DGLTF_SUPPORT:BOOL=ON \
 -DBUILD_CONVERT:BOOL=ON \
 -DBUILD_IFCPYTHON:BOOL=ON \
 -DBUILD_IFCGEOM:BOOL=ON \
 -DBUILD_GEOMSERVER:BOOL=OFF \
 -DBOOST_USE_STATIC_LIBS:BOOL=OFF \
 ./cmake

ninja

ninja install -j 1