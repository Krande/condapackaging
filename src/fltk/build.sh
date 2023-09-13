#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

# The build uses DSOFLAGS instead of LDFLAGS for shared libraries
export DSOFLAGS=$LDFLAGS

./configure --prefix=$PREFIX --enable-shared

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  # Don't build test/ when cross compiling
  sed -i.bak 's/fluid test documentation/fluid documentation/' Makefile
fi

if [[ "$target_platform" == osx-* ]]; then
  # avoid libc++ conflict with <version>
  rm -rf VERSION
fi

make -j${CPU_COUNT}

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make test
fi

make install
