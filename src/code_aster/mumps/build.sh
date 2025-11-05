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
# Note: -fdefault-integer-8 is automatically added by CMake when intsize64=ON (see cmake/compilers.cmake)
# We should NOT add it manually here as it interferes with the INTEGER(4) interface headers
FCFLAGS="$FCFLAGS -Dtry_null_space -DUSE_SCHEDAFFINITY -DUSE_MPI3 -DPORD_INTSIZE64"

# Note: -fallow-argument-mismatch and -Wno-argument-mismatch are now added by the patched
# cmake/compilers.cmake for gfortran >= 10. These flags suppress MPI type mismatch warnings.

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
