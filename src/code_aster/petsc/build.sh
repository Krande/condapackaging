#!/bin/bash
set -ex

mkdir -p "$SRC_DIR/deps/config"
tar -xzf "$SRC_DIR/deps/archives/petsc-3.17.1_aster.tar.gz" -C . --strip-components=1

export BUILD_3rdParty=$SRC_DIR
cd petsc-src
# ensure to have consistent python3 and cython in PATH
python3 ./configure \
    --with-debugging=1 \
    --with-mpi=1 \
    --with-ssl=0 \
    --with-x=0 \
    --with-64-bit-indices=0 \
    --with-mumps-lib="${PREFIX}/lib" \
    --with-mumps-include=${PREFIX}/include \
    --with-blas-lapack-lib="${PREFIX}/lib" \
    --with-scalapack-lib="${PREFIX}/lib" \
    --with-python=1 \
    --with-petsc4py=1 \
    --download-ml=${BUILD_3rdParty}/3rd/pkg-trilinos-ml-${_ML}.tar.gz \
    --download-sowing=${BUILD_3rdParty}/3rd/sowing_${_SOWING}.tar.gz \
    --download-hypre=${BUILD_3rdParty}/3rd/hypre_${_HYPRE}.tar.gz \
    --download-superlu=${BUILD_3rdParty}/3rd/SuperLU_${_SUPERLU}.tar.gz \
    --download-slepc=${BUILD_3rdParty}/3rd/slepc-${_SPLEC}.tar.gz \
    --download-hpddm=${BUILD_3rdParty}/3rd/hpddm_${_HPDDM}.tar.gz \
    --with-openmp=0 \
    --prefix=${PREFIX}

[ $? -eq 0 ] || exit 1

make -j ${procs} all
[ $? -eq 0 ] || exit 1

make -j ${procs} install
[ $? -eq 0 ] || exit 1