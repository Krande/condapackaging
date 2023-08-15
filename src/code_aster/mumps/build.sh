#!/bin/bash

tar -xzvf "$SRC_DIR/deps/archives/mumps-5.5.1_aster1.tar.gz" -C . --strip-components=1

export CFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"
export FCFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${FCFLAGS}"

export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

$PYTHON waf configure install \
  --prefix=$PREFIX \
  --enable-metis \
  --maths-libs=auto \
  --enable-scotch \
  --enable-openmp \
  --install-tests

$PYTHON ./waf build
$PYTHON ./waf install