#!/bin/bash

set -ex

cd $SRC_DIR

if [[ $(uname) == "Darwin" ]]; then
  shared_flags="-Wl,-undefined -Wl,dynamic_lookup"
else
  shared_flags="-Wl,-shared"
fi

if [[ "$mpi" == "nompi" ]]; then
  USE_MPI=OFF
else
  USE_MPI=ON
fi

export TGT_BUILD_TYPE=Release
if [[ "${build_type}" == "debug" ]]; then
  echo "Debugging Enabled"
  export TGT_BUILD_TYPE="Debug"
else
  echo "Debugging Disabled"
fi

if [[ "${mpi}" == "nompi" ]]; then
  echo "Building Scotch without MPI support"
fi
BUILD_DUMMYSIZES=ON

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" && "${mpi}" == "openmpi" ]]; then
  export OPAL_PREFIX="$PREFIX"
fi

cmake ${CMAKE_ARGS} \
  -D CMAKE_BUILD_TYPE=$TGT_BUILD_TYPE \
  -D CMAKE_SHARED_LINKER_FLAGS="$shared_flags" \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D INTSIZE=${int_type} \
  -D BUILD_SHARED_LIBS=ON \
  -D BUILD_PTSCOTCH=$USE_MPI \
  -D MPI_THREAD_MULTIPLE=$USE_MPI \
  -D BUILD_DUMMYSIZES=$BUILD_DUMMYSIZES \
  -B build \
  .

cmake --build ./build --parallel ${CPU_COUNT} --config Release
cmake --install ./build --component=libscotch

# check SCOTCH_VERSION fields
grep VERSION $PREFIX/include/scotch.h
