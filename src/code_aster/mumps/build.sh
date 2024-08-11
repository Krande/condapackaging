#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status
set -o pipefail  # Consider a pipeline to fail if any command in it fails

# Create build directory and navigate into it
mkdir -p build
cd build

TGT_BUILD_TYPE="Release"
if [ "$build_type" == "debug" ]; then
    TGT_BUILD_TYPE="Debug"
    CFLAGS="$CFLAGS -O0 -g"
    FCFLAGS="$FCFLAGS -O0 -g -fbacktrace"
    LDFLAGS="$LDFLAGS -g"
fi

# Needed for the pthread library when linking with scotch
LDFLAGS="$LDFLAGS -L$PREFIX/lib -lpthread"
CFLAGS="$CFLAGS -Dtry_null_space -DUSE_SCHEDAFFINITY -DPORD_INTSIZE64"
FCFLAGS="$FCFLAGS -fdefault-real-8 -fdefault-integer-8 -Dtry_null_space -DUSE_SCHEDAFFINITY -DUSE_MPI3 -DPORD_INTSIZE64"

# Configure using CMake
cmake -G "Ninja" \
      -D CMAKE_PREFIX_PATH="$PREFIX" \
      -D CMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
      -D CMAKE_BUILD_TYPE:STRING="$TGT_BUILD_TYPE" \
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      -D MUMPS_UPSTREAM_VERSION:STRING=5.7.2 \
      -D intsize64:BOOL=ON \
      -D gemmt:BOOL=ON \
      -D metis:BOOL=ON \
      -D scotch:BOOL=ON \
      -D openmp:BOOL=OFF \
      -D parallel:BOOL=OFF \
      -D BUILD_SHARED_LIBS:BOOL=ON \
      -D BUILD_SINGLE:BOOL=ON \
      -D BUILD_DOUBLE:BOOL=ON \
      -D BUILD_COMPLEX:BOOL=ON \
      -D BUILD_COMPLEX16:BOOL=ON \
      ..

# Build and install the project
ninja install
