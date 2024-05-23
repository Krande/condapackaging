#!/bin/bash

set -ex

cd $SRC_DIR

if [[ $(uname) == "Darwin" ]]; then
  shared_flags="-Wl,-undefined -Wl,dynamic_lookup"
else
  shared_flags="-Wl,-shared"
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == 1 ]]; then
  # Build dummysizes helper executable
  (
    mkdir -p $SRC_DIR/src/dummysizes/build-host
    pushd $SRC_DIR/src/dummysizes/build-host

    cp $RECIPE_DIR/CMakeLists-dummysizes.txt $SRC_DIR/src/dummysizes/CMakeLists.txt

    export CC=$CC_FOR_BUILD
    export LDFLAGS=${LDFLAGS//$PREFIX/$BUILD_PREFIX}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH//$PREFIX/$BUILD_PREFIX}

    # Unset them as we're ok with builds that are either slow or non-portable
    unset CFLAGS

    cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$BUILD_PREFIX \
      -DCMAKE_INSTALL_PREFIX=$BUILD_PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DSCOTCH_VERSION=$(echo ${PKG_VERSION} | cut -d. -f 1) \
      -DSCOTCH_RELEASE=$(echo ${PKG_VERSION} | cut -d. -f 2) \
      -DSCOTCH_PATCHLEVEL=$(echo ${PKG_VERSION} | cut -d. -f 3) \
      -DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=True

    cmake --build . --parallel ${CPU_COUNT} --config Release
  )

  # Set flag to not build dummysizes in main build
  BUILD_DUMMYSIZES=OFF
  # Cross-compile run results
  export CMAKE_ARGS="${CMAKE_ARGS} -DMPI_RUN_RESULT_C_libver_mpi_normal:INTERNAL=1 -DMPI_RUN_RESULT_C_libver_mpi_normal__TRYRUN_OUTPUT:STRING="""
else
  BUILD_DUMMYSIZES=ON
fi

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" && "${mpi}" == "openmpi" ]]; then
  export OPAL_PREFIX="$PREFIX"
fi

cmake ${CMAKE_ARGS} \
  -D CMAKE_BUILD_TYPE=Release \
  -D CMAKE_SHARED_LINKER_FLAGS="$shared_flags" \
  -D CMAKE_INSTALL_PREFIX=$PREFIX \
  -D BUILD_SHARED_LIBS=ON \
  -D BUILD_DUMMYSIZES=$BUILD_DUMMYSIZES \
  -B build \
  .

cmake --build ./build --parallel ${CPU_COUNT} --config Release
cmake --install ./build --component=libscotch

# check SCOTCH_VERSION fields
grep VERSION $PREFIX/include/scotch.h
