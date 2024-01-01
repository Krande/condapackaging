set -ex

export CLICOLOR_FORCE=1
USE_MPI=OFF
if [[ "$mpi" == "nompi" ]]; then
  export F77=${FC}
  echo "Compiling for Sequential MPI=$mpi"
else
  USE_MPI=ON
  echo "Compiling for MPI=$mpi"
  export OPAL_PREFIX=$PREFIX
  export CC=mpicc
  export CXX=mpicxx
  export FC=mpif90
  export F77=mpif77
  export F90=mpif90
fi

export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-fdefault-integer-8 ${FFLAGS}"

mkdir -p build
pushd build

# we specify both old style (all capital PYTHON)
# and new style (Python) variables
cmake -Wno-dev \
  ${CMAKE_ARGS} \
  -D Python_FIND_VIRTUALENV=FIRST \
  -D Python_FIND_STRATEGY=LOCATION \
  -D Python_ROOT_DIR="${PREFIX}" \
  -D Python_EXECUTABLE="${PYTHON}" \
  -D PYTHON_EXECUTABLE="${PYTHON}" \
  -D HDF5_ROOT_DIR=${PREFIX} \
  -D MPI_ROOT=${PREFIX} \
  -D MEDFILE_INSTALL_DOC=OFF \
  -D MEDFILE_BUILD_TESTS=OFF \
  -D MEDFILE_BUILD_PYTHON=ON \
  -D MEDFILE_BUILD_SHARED_LIBS=ON \
  -D MEDFILE_BUILD_STATIC_LIBS=OFF \
  -D MEDFILE_USE_UNICODE=OFF \
  -D MED_MEDINT_TYPE=long \
  -D MEDFILE_USE_MPI=${USE_MPI} \
  ..

make -j${CPU_COUNT}
make install

popd
