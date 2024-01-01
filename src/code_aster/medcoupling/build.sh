set -ex

export CLICOLOR_FORCE=1

mkdir -p build
cd build

USE_MPI=ON
if [[ "$mpi" == "nompi" ]]; then
  USE_MPI=OFF
else
  echo "Compiling for MPI=$mpi"
  export OPAL_PREFIX=$PREFIX
  export CC=mpicc
  export CXX=mpicxx
  export FC=mpif90
  export F77=mpif77
  export F90=mpif90
fi

BUILD_TYPE="Release"
if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    BUILD_TYPE="Debug"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi


# remove the share cmake files
find ${PREFIX}/share/cmake -type d -name "medfile-*" -exec rm -rf {} +

cmake .. \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
    -DPYTHON_ROOT_DIR="${PREFIX}" \
    -DPYTHON_EXECUTABLE:FILEPATH="$PYTHON" \
    -Wno-dev \
    -DCONFIGURATION_ROOT_DIR="${SRC_DIR}/deps/config" \
    -DSALOME_CMAKE_DEBUG=ON \
    -DMED_INT_IS_LONG=ON \
    -DSALOME_USE_MPI=${USE_MPI} \
    -DMEDCOUPLING_BUILD_TESTS=OFF \
    -DMEDCOUPLING_BUILD_DOC=OFF \
    -DMEDCOUPLING_USE_64BIT_IDS=ON \
    -DMEDCOUPLING_USE_MPI=${USE_MPI} \
    -DMEDCOUPLING_MEDLOADER_USE_XDR=OFF \
    -DXDR_INCLUDE_DIRS="" \
    -DMEDCOUPLING_PARTITIONER_PARMETIS=OFF \
    -DMEDCOUPLING_PARTITIONER_METIS=OFF \
    -DMEDCOUPLING_PARTITIONER_SCOTCH=OFF \
    -DMEDCOUPLING_PARTITIONER_PTSCOTCH=${USE_MPI} \
    -DMPI_C_COMPILER:PATH="$(which mpicc)" \
    ${CMAKE_ARGS}

make -j$CPU_COUNT
make install

# Generate stubs for pybind11
python "${RECIPE_DIR}/stubs/custom_stubs_gen.py"
echo "Stubs generation completed"