#!/bin/bash
set -ex

mkdir -p "$SRC_DIR/deps/config"
tar -xzf "$SRC_DIR/deps/archives/petsc-3.17.1_aster.tar.gz" -C . --strip-components=1

export BUILD_3rdParty=$SRC_DIR
cd petsc-src

echo "mpi=$mpi"

_HYPRE="v2.24.0"
_ML="v13.2.0"
_SOWING="v1.1.26-p4"
_SPLEC="aa5f86854e5d457ce6ff5041b1c308588ba71c25"
_SUPERLU="v5.3.0"
_HPDDM="b9ae0dc6cf88af52b1572b990f8b1731cabceaaf"

export LIBS="-Wl,-rpath,$PREFIX/lib -lmpi_mpifh -lgfortran"
# OpenMPI related
export OMPI_MCA_plm=isolated
export OMPI_MCA_rmaps_base_oversubscribe=yes
export OMPI_MCA_btl_vader_single_copy_mechanism=none
export OMPI_CC=$CC
export OPAL_PREFIX=$PREFIX
export LDFLAGS="-pthread -fopenmp $LDFLAGS"
export LDFLAGS="$LDFLAGS -Wl,-rpath-link,$PREFIX/lib"

# SHLIB_EXT https://docs.conda.io/projects/conda-build/en/latest/user-guide/environment-variables.html#id2
if [[ "${PKG_DEBUG}" == "True" ]]; then
  enable_debugging=1
  export CFLAGS="-g -O0 ${CFLAGS}"
  export CXXFLAGS="-g -O0 ${CXXFLAGS}"
  export FCFLAGS="-g -O0 ${FCFLAGS}"
else
  enable_debugging=0
fi

export CC=mpicc
export CXX=mpicxx
export FC=mpifort
export F77=mpif77
export F90=mpif90

echo "python=$(which python)"
# ensure to have consistent python3 and cython in PATH
$PYTHON ./configure \
    CC="mpicc" \
    CXX="mpicxx" \
    FC="mpifort" \
    CFLAGS="$CFLAGS" \
    CPPFLAGS="$CPPFLAGS" \
    CXXFLAGS="$CXXFLAGS" \
    FFLAGS="$FFLAGS" \
    LDFLAGS="$LDFLAGS" \
    LIBS="$LIBS" \
    --with-debugging=$enable_debugging \
    --with-mpi=1 \
    --with-ssl=0 \
    --with-x=0 \
    --with-64-bit-indices=0 \
    --with-mumps-lib="-L${PREFIX}/lib -lzmumps -ldmumps -lmumps_common -lpord -lesmumps -lptscotch -lptscotcherr -lptscotcherrexit -lscotch -lscotcherr -lscotcherrexit -lmetis" \
    --with-mumps-include="${PREFIX}/include" \
    --with-blas-lib=libblas"${SHLIB_EXT}" \
    --with-lapack-lib=liblapack"${SHLIB_EXT}" \
    --with-scalapack=1 \
    --with-python=1 \
    --with-petsc4py=1 \
    --with-shared-libraries \
    --download-ml="${BUILD_3rdParty}/3rd/pkg-trilinos-ml-${_ML}.tar.gz" \
    --download-sowing="${BUILD_3rdParty}"/3rd/sowing_${_SOWING}.tar.gz \
    --download-hypre="${BUILD_3rdParty}"/3rd/hypre_${_HYPRE}.tar.gz \
    --download-superlu="${BUILD_3rdParty}"/3rd/SuperLU_${_SUPERLU}.tar.gz \
    --download-slepc="${BUILD_3rdParty}"/3rd/slepc-${_SPLEC}.tar.gz \
    --download-hpddm="${BUILD_3rdParty}"/3rd/hpddm_${_HPDDM}.tar.gz \
    --with-openmp=0 \
    --prefix="${PREFIX}"

[ $? -eq 0 ] || exit 1

make -j ${procs} all
[ $? -eq 0 ] || exit 1

make -j ${procs} install
[ $? -eq 0 ] || exit 1