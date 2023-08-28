#!/bin/bash

#mkdir -p "$SRC_DIR/deps/config"
#tar -xzvf "$SRC_DIR/deps/archives/med-4.1.1.tar.gz" -C . --strip-components=1

# Patches are only relevant if you try to use HDF5 v1.10.9
#patch -p1 < ${RECIPE_DIR}/patches/med-4.1.1-check-hdf5-with-tabs.diff
#patch -p1 < ${RECIPE_DIR}/patches/med-4.1.1-check-hdf5-parallel.diff

export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-fdefault-integer-8 ${FFLAGS}"
export F77=${FC}

export CXXFLAGS="-std=gnu++98 ${CXXFLAGS}"

./configure --with-swig=yes --prefix="$PREFIX" --with-f90 --with-hdf5="$PREFIX"
make
make install

rm -rf "${PREFIX}/share/doc/med"
