#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

cp $RECIPE_DIR/bld/* .

chmod +x ./install_asrun.sh
chmod +x ./install_metis.sh

./install_asrun.sh
./install_metis.sh

export TFELHOME=$PREFIX
export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

export LIBPATH_METIS="$PREFIX/metis-aster/lib"
export INCLUDES_METIS="$PREFIX/metis-aster/include"

#export ASTERLIBDIR="$PREFIX/lib"
#export PYTHONPATH="$SP_DIR:$SRC_DIR:$PYTHONPATH"
#export LD_LIBRARY_PATH="$SRC_DIR/deps/devtools/lib:$LD_LIBRARY_PATH"
#export PATH="$SRC_DIR/deps/devtools/bin:$PATH"

# Install for standard sequential
./waf \
  --use-config=wafcfg_conda \
  --use-config-dir="$RECIPE_DIR"/config \
  --prefix=$PREFIX \
  --embed-metis \
  --without-hg \
  configure
./waf install

#
#find $PREFIX -name "profile.sh" -exec sed -i 's/PYTHONHOME=/#PYTHONHOME=/g' {} \;
#find $PREFIX -name "profile.sh" -exec sed -i 's/export PYTHONHOME/#export PYTHONHOME/g' {} \;
#
