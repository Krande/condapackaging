#!/bin/bash

mkdir -p "$SRC_DIR/deps/config"
tar -xzvf "$SRC_DIR/deps/archives/medcoupling-V9_10_0.tar.gz" -C . --strip-components=1
tar -xzvf "$SRC_DIR/deps/archives/configuration-V9_10_0.tar.gz" -C "$SRC_DIR/deps/config" --strip-components=1

mkdir -p build
cd build

on_mpi="OFF"
on_seq="ON"

cmake .. \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCONFIGURATION_ROOT_DIR="${SRC_DIR}/deps/config" \
    -DSALOME_CMAKE_DEBUG=ON \
    -DSALOME_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_BUILD_TESTS=OFF \
    -DMEDCOUPLING_BUILD_DOC=OFF \
    -DMEDCOUPLING_USE_64BIT_IDS=ON \
    -DMEDCOUPLING_USE_MPI=${on_mpi} \
    -DMEDCOUPLING_MEDLOADER_USE_XDR=OFF \
    -DXDR_INCLUDE_DIRS="" \
    -DMEDCOUPLING_PARTITIONER_PARMETIS=OFF \
    -DMEDCOUPLING_PARTITIONER_METIS=OFF \
    -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF \
    -DMEDCOUPLING_PARTITIONER_PTSCOTCH=${on_mpi} \
    -DPYTHON_EXECUTABLE:FILEPATH=$PYTHON \
    -DMEDFILE_ROOT_DIR=${PREFIX} \
    -DSCOTCH_ROOT_DIR=${PREFIX} \
    -DSCOTCH_INCLUDE_DIRS="${PREFIX}/include" \
    -DMETIS_ROOT_DIR=${PREFIX} \
    -DMETIS_INCLUDE_DIRS="${PREFIX}/include" \
    -DPTSCOTCH_ROOT_DIR=${PREFIX} \
    -DPTSCOTCH_INCLUDE_DIRS="${PREFIX}/include" \
    -DPARMETIS_ROOT_DIR=${PREFIX} \
    -DPARMETIS_INCLUDE_DIRS="${PREFIX}/include" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}"

make -j
make install