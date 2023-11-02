#!/bin/bash

export CLICOLOR_FORCE=1

# This adds a printout of the error when trying to import the code_aster module. Useful when debugging
#cp $RECIPE_DIR/config/__init__.py code_aster/__init__.py

python "${RECIPE_DIR}/config/update_version.py"

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

# Tried with cleaner flags (but did nothing to reduce compilation errors for MPI)
#export CFLAGS="-fPIC"
#export CXXFLAGS="-fPIC -std=c++17 -Wno-attributes"

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

if [[ "$mpi" == "nompi" ]]; then
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
else
  export PYTHONPATH="$PYTHONPATH:$PREFIX/lib"

  export ENABLE_MPI=1
  export CONFIG_PARAMETERS_addmem=4096

  export CC=mpicc
  export CXX=mpicxx
  export FC=mpif90
  export F77=mpif77
  export F90=mpif90
  export OPAL_PREFIX=$PREFIX

  ./waf_mpi configure \
    --use-config=wafcfg_conda \
    --use-config-dir="$RECIPE_DIR"/config \
    --prefix="${PREFIX}" \
    --enable-mpi \
    --libdir="${PREFIX}/lib" \
    --install-tests \
    --without-hg


  if [[ "${PKG_DEBUG}" == "True" ]]; then
      echo "Debugging Enabled"
      export CFLAGS="-g -O0 ${CFLAGS}"
      export CXXFLAGS="-g -O0 ${CXXFLAGS}"
      export FCFLAGS="-g -O0 ${FCFLAGS}"
      ./waf_mpi install_debug
  else
      echo "Debugging Disabled"
      ./waf_mpi install
  fi
fi
# Change the PYTHONPATH just for pybind11_stubgen to find the necessary module
export PYTHONPATH="$PREFIX/lib/aster:$SRC_DIR/stubgen"
export LD_LIBRARY_PATH="${PREFIX}/lib/aster"

# This is planned for reducing reliance on conda activation scripts. But it's not yet working
mv $PREFIX/lib/aster/code_aster $SP_DIR/code_aster
mv $PREFIX/lib/aster/run_aster $SP_DIR/run_aster
mv $PREFIX/lib/aster/*.so $SP_DIR/
#mv $PREFIX/include/aster/* $PREFIX/include

# Generate stubs for pybind11
$PREFIX/bin/python  ${RECIPE_DIR}/stubs/custom_stubs_gen.py
echo "Stubs generation completed"

# copy modified shell scripts and create backups of the ones we don't want.
cp $PREFIX/bin/run_aster $PREFIX/bin/_run_aster_old
cp $PREFIX/bin/run_ctest $PREFIX/bin/_run_ctest_old

cp $RECIPE_DIR/config/run_aster $PREFIX/bin/run_aster
cp $RECIPE_DIR/config/run_ctest $PREFIX/bin/run_ctest
# Update the path to python env root dir in run_aster utils.py
sed -i.bak 's|RUNASTER_ROOT = os\.environ\.get(|&\n    "RUNASTER_ROOT", osp\.dirname\(osp\.dirname\(osp\.dirname\(osp\.dirname\(osp\.abspath\(__file__\)\)\)\)\)\)|RUNASTER_ROOT = os.environ.get(\n    "RUNASTER_ROOT", osp.dirname(osp.dirname(osp.dirname(osp.dirname(osp.dirname(osp.abspath(__file__))))))|' $PREFIX/bin/run_aster/utils.py


# Alternative, I could move the entire code_aster subdirectory to site-packages granted I am able to relocate all
# relevant .so files
# Add activation/deactivation scripts to set/unset required env variables for code-aster
mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/config/code_aster_activate.sh $PREFIX/etc/conda/activate.d/code_aster_activate.sh
chmod +x $PREFIX/etc/conda/activate.d/code_aster_activate.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/config/code_aster_deactivate.sh $PREFIX/etc/conda/deactivate.d/code_aster_deactivate.sh
chmod +x $PREFIX/etc/conda/deactivate.d/code_aster_deactivate.sh


