export FCFLAGS="-w -fallow-argument-mismatch -O2"
export FFLAGS="-w -fallow-argument-mismatch -O2"

echo "PYTHON=${PYTHON}"
echo "PY_VER=${PY_VER}"
echo "SP_DIR=${SP_DIR}"
echo "STDLIB_DIR=${STDLIB_DIR}"

PYTHON_INCLUDE_DIR=$(${PYTHON} -c 'import sysconfig;print("{0}".format(sysconfig.get_path("platinclude")))')
echo "PYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}"
#PYTHON_LIBRARY=$(${PYTHON} -c 'import sysconfig;print("{0}/{1}".format(*map(sysconfig.get_config_var, ("LIBDIR", "LDLIBRARY"))))')
#echo "PYTHON_LIBRARY=${PYTHON_LIBRARY}"

VERBOSE=1 cmake \
          -Wno-dev \
          -D CMAKE_BUILD_TYPE=Release \
          -D "CMAKE_PREFIX_PATH=${PREFIX}" \
          -D "CMAKE_INSTALL_PREFIX=${PREFIX}" \
          -D CMAKE_FIND_FRAMEWORK=NEVER \
          -D "HDF5_ROOT_DIR=${LIBRARY_PREFIX}" \
          -D MEDFILE_INSTALL_DOC=OFF \
          -D MEDFILE_BUILD_PYTHON=ON \
          -D "PYTHON_LIBRARY=${PREFIX}/lib" \
          -D "PYTHON_INCLUDE_DIR=${PYTHON_INCLUDE_DIR}" -S . -B build

cmake --build ./build --config Release
cmake --install ./build

#./configure --prefix=$PREFIX --with-f90 --with-hdf5=$PREFIX
#make
#make check
#make installcheck
#make install