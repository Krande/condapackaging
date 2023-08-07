#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

cp $RECIPE_DIR/config/wafcfg_conda.py .
cp $RECIPE_DIR/bld/* .

chmod +x ./install_asrun.sh
chmod +x ./install_metis.sh

./install_asrun.sh
./install_metis.sh

export TFELHOME=$PREFIX
export LIBPATH="$PREFIX/metis-aster/lib $PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/metis-aster/include $PREFIX/include $INCLUDES"

export LIBPATH_METIS="$PREFIX/metis-aster/lib"
export INCLUDES_METIS="$PREFIX/metis-aster/include"

# Install for standard sequential
./waf \
  --use-config=wafcfg_conda \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --pythondir="${PREFIX}/lib/aster" \
  --embed-metis \
  --with-data=data \
  --without-hg \
  configure
./waf install -v

find $PREFIX -name "profile.sh" -exec sed -i 's/PYTHONHOME=/#PYTHONHOME=/g' {} \;
find $PREFIX -name "profile.sh" -exec sed -i 's/export PYTHONHOME/#export PYTHONHOME/g' {} \;

