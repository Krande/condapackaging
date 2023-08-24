#!/bin/bash

tar -xzvf "$SRC_DIR/deps/archives/mumps-5.5.1_aster1.tar.gz" -C . --strip-components=1

export CFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"
export FCFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space -fallow-argument-mismatch ${FCFLAGS}"
# -fallow-argument-mismatch is needed to avoid mismatch errors related to floats and integer types
# This enables us to use gcc compilers > 8.*

export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

$PYTHON waf configure install \
  --prefix="${PREFIX}" \
  --enable-openmp \
  --enable-metis \
  --enable-scotch \
  --install-tests

$PYTHON ./waf build
$PYTHON ./waf install