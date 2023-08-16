#!/bin/bash

export CONDA_INCLUDE_PATH="$PREFIX/include"
export CONDA_LIBRARY_PATH="$PREFIX/lib"

# This adds a printout of the error when trying to import the code_aster module
cp $RECIPE_DIR/config/__init__.py code_aster/__init__.py
python $RECIPE_DIR/config/update_version.py

export TFELHOME=$PREFIX

export LIBPATH_METIS="$PREFIX/lib"
export INCLUDES_METIS="$PREFIX/include"

export LIBPATH_PETSC="$PREFIX/lib"
export INCLUDES_PETSC="$PREFIX/include"

export INCLUDES_BOOST=$PREFIX/include
export LIBPATH_BOOST=$PREFIX/lib
export LIB_BOOST="libboost_python$CONDA_PY"

export INCLUDES_MUMPS="$PREFIX/include"
export LIBPATH_MUMPS="$PREFIX/lib"

export MED_LIBS="$PREFIX/lib"
export MED_INCLUDES="$PREFIX/include"
export INCLUDES_MED="$PREFIX/include"
export LIBPATH_MED="$PREFIX/lib"

export LIBPATH_MEDCOUPLING="$PREFIX/lib"
export INCLUDES_MEDCOUPLING="$PREFIX/include"

# Install for standard sequential
./waf_std \
  --use-config=wafcfg_conda \
  --use-config-dir="$RECIPE_DIR"/config \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --includedir="${PREFIX}/include" \
  --install-tests \
  --datadir="${SRC_DIR}/data" \
  --disable-mpi \
  --without-hg \
  configure

#./waf_std install
./waf_std install_debug

# copy modified shell scripts and create backups of the ones we don't want.
cp $PREFIX/bin/run_aster $PREFIX/bin/_run_aster_old
cp $PREFIX/bin/run_ctest $PREFIX/bin/_run_ctest_old

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


