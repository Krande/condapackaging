set -ex

export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-fdefault-integer-8 ${FFLAGS}"

opts=()
if [[ "$mpi" == "nompi" ]]; then
  echo "Compiling $mpi"
else
  echo "Compiling $mpi"
  opts+=(-DMEDFILE_USE_MPI=True)
fi

mkdir -p build
pushd build

cmake \
  ${CMAKE_ARGS} \
  "${opts[@]}" \
  -Wno-dev \
  -D Python_FIND_VIRTUALENV=FIRST \
  -D Python_FIND_STRATEGY=LOCATION \
  -D Python_ROOT_DIR="${PREFIX}" \
  -D Python_EXECUTABLE="${PYTHON}" \
  -D HDF5_ROOT_DIR=${PREFIX} \
  -D MEDFILE_INSTALL_DOC=OFF \
  -D MEDFILE_BUILD_TESTS=OFF \
  -D MEDFILE_BUILD_PYTHON=ON \
  -D MEDFILE_BUILD_SHARED_LIBS=ON \
  -D MEDFILE_BUILD_STATIC_LIBS=OFF \
  -D MEDFILE_USE_UNICODE=OFF \
  ..

make -j${CPU_COUNT}
make install

popd
