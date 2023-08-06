#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

cp $RECIPE_DIR/config/wafcfg_conda.py .

# Install asrun
pip install ./deps/asrun

# Install metis-aster
echo "**************** M E T I S  B U I L D  S T A R T S  H E R E ****************"

cd deps/metis-aster

mkdir -p $PREFIX/metis-aster

make config \
     prefix=$PREFIX/metis-aster

make -j 1
make install

cd ../..

#export LIBPATH="$PREFIX/metis-aster/lib"
#export INCLUDES="$PREFIX/metis-aster/include $PREFIX/include $INCLUDES"

echo "**************** M E T I S  B U I L D  E N D S  H E R E ****************"

export LINKFLAGS="${LINKFLAGS} -Wl,--no-as-needed,-rpath=${CONDA_LIBRARY_PATH}"

# Install for standard sequential
./waf_std \
  --use-config=wafcfg_conda \
  --without-hg \
  --use-config-dir=${CONDA_LIBRARY_PATH} \
  --prefix=${CONDA_PREFIX} \
  --with-data=data \
  --install-tests \
  configure
# ./waf_std build
./waf_std install