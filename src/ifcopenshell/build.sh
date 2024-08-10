#!/bin/bash
export CLICOLOR_FORCE=1

# IF osx use file lib suffix .dylib
# IF linux use file lib suffix .so
# IF windows use file lib suffix .dll

if [ "$(uname)" == "Darwin" ]; then
    export FSUFFIX=dylib
    export LDFLAGS="$LDFLAGS -Wl,-flat_namespace,-undefined,suppress"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    export FSUFFIX=so
fi

if [[ "$mpi" == "nompi" ]]; then
  echo "nompi"
else
  export ENABLE_MPI=1
  export CC=$PREFIX/bin/mpicc
  export CXX=$PREFIX/bin/mpic++
  export FC=$PREFIX/bin/mpifort
fi

TGT_CMAKE_BUILD_TYPE=Release
if [[ "$build_type" == "debug" ]]; then
  export TGT_CMAKE_BUILD_TYPE=RelWithDebInfo
fi

cmake ${CMAKE_ARGS} -G Ninja \
 -DSCHEMA_VERSIONS="2x3;4;4x1;4x3_add2" \
 -DCMAKE_BUILD_TYPE=$TGT_CMAKE_BUILD_TYPE \
 -DCMAKE_INSTALL_PREFIX=$PREFIX \
  ${CMAKE_PLATFORM_FLAGS[@]} \
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
 -DLIBXML2_INCLUDE_DIR=$PREFIX/include/libxml2 \
 -DLIBXML2_LIBRARIES=$PREFIX/lib/libxml2.$FSUFFIX \
 -DEIGEN_DIR:FILEPATH=$PREFIX/include/eigen3 \
 -DCOLLADA_SUPPORT:BOOL=OFF \
 -DBUILD_EXAMPLES:BOOL=OFF \
 -DIFCXML_SUPPORT:BOOL=ON \
 -DGLTF_SUPPORT:BOOL=ON \
 -DBUILD_CONVERT:BOOL=ON \
 -DBUILD_IFCPYTHON:BOOL=ON \
 -DBUILD_IFCGEOM:BOOL=ON \
 -DBUILD_GEOMSERVER:BOOL=OFF \
 -DBOOST_USE_STATIC_LIBS:BOOL=OFF \
 -DCITYJSON_SUPPORT:BOOL=OFF \
 ./cmake

ninja

ninja install -j 1