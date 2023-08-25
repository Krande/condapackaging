#!/bin/bash

tar -xzvf "$SRC_DIR/deps/archives/mumps-5.5.1_aster1.tar.gz" -C . --strip-components=1

export CFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"

# if gfortran version > 8, we need to conditionally add -fallow-argument-mismatch
# to avoid mismatch errors related to floats and integer types

if [[ $($FC -dumpversion) -gt 8 ]]; then
  export FCFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space -fallow-argument-mismatch ${CFLAGS}"
else
  # -fallow-argument-mismatch is not supported by gfortran <= 8
  export FCFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"
fi

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