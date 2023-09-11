#!/bin/bash
export CLICOLOR_FORCE=1

# for cross compiling with openmpi
export OPAL_PREFIX=$PREFIX
export CC=mpicc
export CXX=mpicxx
export FC=mpiifort

if [[ "${PKG_DEBUG}" == "True" ]]; then
  echo "Debugging Enabled"
  export CFLAGS="-g -O0 ${CFLAGS}"
  export CXXFLAGS="-g -O0 ${CXXFLAGS}"
  export FCFLAGS="-g -O0 ${FCFLAGS}"
  build_type="Debug"
else
  build_type="Release"
  echo "Debugging Disabled"
fi

mkdir -p build
cd build

export CFLAGS="-fPIC ${CFLAGS}"
cmake ${CMAKE_ARGS} \
  -DGKLIB_PATH=$SRC_DIR/metis/GKlib \
  -DMETIS_PATH=$SRC_DIR/metis \
  -DSHARED=1 \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  ..

make -j${CPU_COUNT}
make install