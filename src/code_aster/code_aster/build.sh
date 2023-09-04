#!/bin/bash


# This adds a printout of the error when trying to import the code_aster module. Useful when debugging
#cp $RECIPE_DIR/config/__init__.py code_aster/__init__.py

python $RECIPE_DIR/config/update_version.py

export CONFIG_PARAMETERS_addmem=3000
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

export INCLUDES_MED="$PREFIX/include"
export LIBPATH_MED="$PREFIX/lib"

export LIBPATH_MEDCOUPLING="$PREFIX/lib"
export INCLUDES_MEDCOUPLING="$PREFIX/include"
export PYPATH_MEDCOUPLING=$SP_DIR

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

# Install for standard sequential
./waf_std \
  --use-config=wafcfg_conda \
  --use-config-dir="$RECIPE_DIR"/config \
  --prefix="${PREFIX}" \
  --libdir="${PREFIX}/lib" \
  --install-tests \
  --disable-mpi \
  --without-hg \
  configure

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
    ./waf_std install_debug
else
    echo "Debugging Disabled"
    ./waf_std install
fi

# Change the PYTHONPATH just for pybind11_stubgen to find the necessary module
export PYTHONPATH="$PREFIX/lib/aster:$SRC_DIR/stubgen"
export LD_LIBRARY_PATH="${PREFIX}/lib/aster"

# Generate stubs for pybind11
$PREFIX/bin/python  $RECIPE_DIR/stubs/custom_stubs_gen.py
#cp stubs/libaster.pyi "${PREFIX}/lib/aster/libaster.pyi"

# copy modified shell scripts and create backups of the ones we don't want.
cp $PREFIX/bin/run_aster $PREFIX/bin/_run_aster_old
cp $PREFIX/bin/run_ctest $PREFIX/bin/_run_ctest_old

cp $RECIPE_DIR/config/run_aster $PREFIX/bin/run_aster
cp $RECIPE_DIR/config/run_ctest $PREFIX/bin/run_ctest
#cp $RECIPE_DIR/config/as_run $PREFIX/bin/as_run


# Alternative, I could move the entire code_aster subdirectory to site-packages granted I am able to relocate all
# relevant .so files
# Add activation/deactivation scripts to set/unset required env variables for code-aster
mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/config/code_aster_activate.sh $PREFIX/etc/conda/activate.d/code_aster.sh
chmod +x $PREFIX/etc/conda/activate.d/code_aster.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/config/code_aster_deactivate.sh $PREFIX/etc/conda/deactivate.d/code_aster.sh
chmod +x $PREFIX/etc/conda/deactivate.d/code_aster.sh


