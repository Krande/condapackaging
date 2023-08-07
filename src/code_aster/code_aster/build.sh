#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

cp $RECIPE_DIR/config/wafcfg_conda.py .
cp -r code_aster $SP_DIR
ls $SP_DIR

# Install asrun
pip install ./deps/asrun

# Install metis-aster
echo "** Building METIS **"

cd deps/metis-aster

mkdir -p $PREFIX/metis-aster

make config \
     prefix=$PREFIX/metis-aster

make -j 1
make install

cd ../..

echo "METIS Build complete"
#
#echo "**************** M U M P S  B U I L D  S T A R T S  H E R E ****************"
#
#cd deps/mumps-aster
#
#$PYTHON waf configure install --prefix=${PREFIX}/mumps-aster --enable-metis --embed-metis --enable-scotch -j 1
#
#cd ../..
#
#echo "**************** M U M P S  B U I L D  E N D S  H E R E ****************"

#echo "Build MFRONT/TFEL"
#
#cd deps/mfront
#mkdir -p build
#cd build
#
#export VERSION_TFEL=3.4.0
#
#cmake .. \
#    -DCMAKE_BUILD_TYPE=Release \
#    -DTFEL_SVN_REVISION=${VERSION_TFEL} \
#    -DTFEL_APPEND_VERSION=${VERSION_TFEL} \
#    -Dlocal-castem-header=ON \
#    -Denable-fortran=ON \
#    -Denable-broken-boost-python-module-visibility-handling=ON \
#    -Denable-python-bindings=ON \
#    -Denable-cyrano=ON -Denable-aster=ON \
#    -Ddisable-reference-doc=ON \
#    -Ddisable-website=ON \
#    -Denable-portable-build=ON \
#    -DPython_ADDITIONAL_VERSIONS=${CONDA_PY} \
#    -Denable-python=ON \
#    -DPYTHON_EXECUTABLE:FILEPATH=${PYTHON} \
#    -DPYTHON_LIBRARY:FILEPATH=${PREFIX}/lib/libpython${CONDA_PY}.so \
#    -DPYTHON_INCLUDE_DIR:PATH=${PREFIX}/include/python${CONDA_PY} \
#    -DCMAKE_INSTALL_PREFIX=${PREFIX}
#
#make -j $(nproc) install
#echo "MFRONT/TFEL build complete"

#export LINKFLAGS="${LINKFLAGS} -Wl,-rpath=${CONDA_LIBRARY_PATH}"
#export CONFIG_PARAMETERS_addmem=4096

# Install for standard sequential
./waf \
  --use-config=wafcfg_conda \
  --without-hg \
  --use-config-dir=${CONDA_LIBRARY_PATH} \
  --prefix=${CONDA_PREFIX} \
  --with-data=data \
  configure
./waf install -v --jobs=4

