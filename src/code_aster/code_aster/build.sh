#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

cp $RECIPE_DIR/config/wafcfg_conda.py .

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

#export LINKFLAGS="${LINKFLAGS} -Wl,-rpath=${CONDA_LIBRARY_PATH}"
export CONFIG_PARAMETERS_addmem=4096

# Install for standard sequential
./waf_std \
  --use-config=wafcfg_conda \
  --without-hg \
  --use-config-dir=${CONDA_LIBRARY_PATH} \
  --prefix=${CONDA_PREFIX} \
  --with-data=data \
  configure
./waf_std install -v