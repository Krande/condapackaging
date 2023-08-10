#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

cp $RECIPE_DIR/bld/* .

chmod +x ./install_metis.sh

#pip install ./deps/asrun
./install_metis.sh

export TFELHOME=$PREFIX
export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

export LIBPATH_METIS="$PREFIX/metis-aster/lib"
export INCLUDES_METIS="$PREFIX/metis-aster/include"

#export ASTERLIBDIR="$PREFIX/lib"

# Install for standard sequential
./waf \
  --use-config=wafcfg_conda \
  --use-config-dir="$RECIPE_DIR"/config \
  --prefix=$PREFIX \
  --libdir=$PREFIX/lib \
  --pythondir=$PREFIX/lib/aster \
  --install-tests \
  --embed-metis \
  --without-hg \
  configure
./waf install

# copy modified shell scripts
cp $RECIPE_DIR/config/run_aster $PREFIX/bin/run_aster
cp $RECIPE_DIR/config/run_ctest $PREFIX/bin/run_ctest
#cp $RECIPE_DIR/config/as_run $PREFIX/bin/as_run

mkdir -p $PREFIX/etc/conda/activate.d
echo "export PYTHONPATH=\"\$PYTHONPATH:\$PREFIX/lib/aster\"" > $PREFIX/etc/conda/activate.d/code_aster.sh
chmod +x $PREFIX/etc/conda/activate.d/code_aster.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
echo "export PYTHONPATH=\"\${PYTHONPATH//\$PREFIX\/lib\/aster:/}\"" > $PREFIX/etc/conda/deactivate.d/code_aster.sh
chmod +x $PREFIX/etc/conda/deactivate.d/code_aster.sh

