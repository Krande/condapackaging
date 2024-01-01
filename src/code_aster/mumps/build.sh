#!/bin/bash
export CLICOLOR_FORCE=1

tar -xzf "$SRC_DIR/deps/archives/mumps-5.5.1_aster1.tar.gz" -C . --strip-components=1

# Use a slightly modified wscript that builds shared libs (.so)
#cp "$RECIPE_DIR/config/wscript" .

echo "FC: $FC, Version: $($FC -dumpversion)"
echo "CC: $CC"
echo "CXX: $CXX"
echo "CFLAGS: $CFLAGS"

export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-fdefault-integer-8 ${FFLAGS}"
export CFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"

# if gfortran version > 9, we need to conditionally add -fallow-argument-mismatch
# to avoid mismatch errors related to floats and integer types
major_version=$($FC -dumpversion | awk -F. '{print $1}')
if [[ $major_version -gt 9 ]]; then
  echo "adding -fallow-argument-mismatch to FCFLAGS"

  export FCFLAGS="-fallow-argument-mismatch ${FCFLAGS}"
else
  echo "FCFLAGS: $FCFLAGS"
fi

export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

if [ "${mpi}" == "nompi" ]; then
  echo "Compiling non-mpi -> MPI_TYPE=$mpi"

  $PYTHON waf configure install \
    --prefix="${PREFIX}" \
    --enable-openmp \
    --enable-metis \
    --enable-scotch \
    --install-tests
else
  echo "Compiling MPI_TYPE=$mpi"

  export CC=mpicc
  export CXX=mpicxx
  export FC=mpifort
  export F77=mpif77
  export F90=mpif90

  $PYTHON ./waf configure \
    FPIC_OPT=-fPIC \
    --enable-mpi \
    --enable-openmp \
    --enable-metis \
    --enable-parmetis \
    --enable-scotch \
    --maths-libs=auto \
    --install-tests \
    --prefix="${PREFIX}"
fi


$PYTHON ./waf build
$PYTHON ./waf install