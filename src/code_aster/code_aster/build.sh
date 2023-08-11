#!/bin/bash

export CONDA_INCLUDE_PATH="$CONDA_PREFIX/include"
export CONDA_LIBRARY_PATH="$CONDA_PREFIX/lib"

# This adds a printout of the error when trying to import the code_aster module
cp $RECIPE_DIR/config/__init__.py code_aster/__init__.py
python $RECIPE_DIR/config/update_version.py

cp $RECIPE_DIR/bld/* .

chmod +x ./install_metis.sh
./install_metis.sh

# if env variable _CA_VERSION
if [ "$_CA_VERSION" == "16.4.2" ]; then
  chmod +x ./install_medcoupling.sh
  ./install_medcoupling.sh
fi

export TFELHOME=$PREFIX
export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

export LIBPATH_METIS="$PREFIX/metis-aster/lib"
export INCLUDES_METIS="$PREFIX/metis-aster/include"

export LIBPATH_PETSC="$PREFIX/lib"
export INCLUDES_PETSC="$PREFIX/include"

export INCLUDES_BOOST=$PREFIX/include
export LIBPATH_BOOST=$PREFIX/lib
export LIB_BOOST="libboost_python$CONDA_PY"

# Install for standard sequential
./waf_std \
  --use-config=wafcfg_conda \
  --use-config-dir="$RECIPE_DIR"/config \
  --prefix=$PREFIX \
  --libdir=$PREFIX/lib \
  --pythondir=$PREFIX/lib \
  --install-tests \
  --embed-metis \
  --without-hg \
  configure

#./waf install
./waf install_debug

# copy modified shell scripts
cp $RECIPE_DIR/config/run_aster $PREFIX/bin/run_aster
cp $RECIPE_DIR/config/run_ctest $PREFIX/bin/run_ctest
#cp $RECIPE_DIR/config/as_run $PREFIX/bin/as_run


# Alternative, I could move the entire code_aster subdirectory to site-packages granted I am able to relocate all
# relevant .so files

mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/config/code_aster_activate.sh $PREFIX/etc/conda/activate.d/code_aster.sh
chmod +x $PREFIX/etc/conda/activate.d/code_aster.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/config/code_aster_deactivate.sh $PREFIX/etc/conda/deactivate.d/code_aster.sh
chmod +x $PREFIX/etc/conda/deactivate.d/code_aster.sh


