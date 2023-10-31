#!/bin/bash
export CLICOLOR_FORCE=1

#mkdir -p "$SRC_DIR/deps/config"
#tar -xzvf "$SRC_DIR/deps/archives/med-4.1.1.tar.gz" -C . --strip-components=1

# Patches are only relevant if you try to use HDF5 v1.10.9
#patch -p1 < ${RECIPE_DIR}/patches/med-4.1.1-check-hdf5-with-tabs.diff
#patch -p1 < ${RECIPE_DIR}/patches/med-4.1.1-check-hdf5-parallel.diff

if [[ "${USE_64BIT_IDS}" != "True" ]]
  echo "Using 32 bit Integer IDs"
else
  echo "Using 64 bit Integer IDs"
  export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
  export FFLAGS="-fdefault-integer-8 ${FFLAGS}"
fi

export CXXFLAGS="-std=gnu++98 ${CXXFLAGS}"

if [[ "$mpi" == "nompi" ]]; then
  export F77=${FC}
  echo "Compiling for Sequential MPI=$mpi"
else
  echo "Compiling for MPI=$mpi"
  export OPAL_PREFIX=$PREFIX
  export CC=mpicc
  export CXX=mpicxx
  export FC=mpif90
  export F77=mpif77
  export F90=mpif90
fi

opts=("--with-swig=yes" )

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    # Set compiler flags for debugging, for instance
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
    opts+=( "--enable-mesgerr" )
    # Additional debug build steps
else
    echo "Debugging Disabled"
    # Set compiler flags for production
    opts+=( "--disable-mesgerr" )
    # Additional production build steps
fi

chmod +x ./configure
./configure "${opts[@]}" --prefix="$PREFIX" --with-hdf5="$PREFIX"
make
make install

rm -rf "${PREFIX}/share/doc/med"
