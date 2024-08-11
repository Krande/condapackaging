#!/bin/bash

export CLICOLOR_FORCE=1

export CONFIG_PARAMETERS_addmem=2000
export TFELHOME=${PREFIX}

export LIBPATH_METIS="${PREFIX}/lib"
export INCLUDES_METIS="${PREFIX}/include"

export LIBPATH_PETSC="${PREFIX}/lib"
export INCLUDES_PETSC="${PREFIX}/include"

export INCLUDES_BOOST=${PREFIX}/include
export LIBPATH_BOOST=${PREFIX}/lib
export LIB_BOOST="libboost_python$CONDA_PY"

export INCLUDES_MUMPS="${PREFIX}/include"
export LIBPATH_MUMPS="${PREFIX}/lib"

export INCLUDES_MED="${PREFIX}/include"
export LIBPATH_MED="${PREFIX}/lib"

export LIBPATH_MEDCOUPLING="${PREFIX}/lib"
export INCLUDES_MEDCOUPLING="${PREFIX}/include"
export PYPATH_MEDCOUPLING=${SP_DIR}

python conda/scripts/update_version.py
python ${RECIPE_DIR}/config/set_env_var.py ${SRC_DIR}

mpi_type=std
if [[ "$mpi" != "nompi" ]]; then
  mpi_type=mpi
fi

build_type=release
if [[ "${build_type}" == "debug" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
    build_type=debug
else
    echo "Debugging Disabled"
fi

export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-fdefault-integer-8 ${FFLAGS}"

# if gfortran version > 9, we need to conditionally add -fallow-argument-mismatch
# to avoid mismatch errors related to floats and integer types
major_version=$($FC -dumpversion | awk -F. '{print $1}')
if [[ $major_version -gt 9 ]]; then
  echo "adding -fallow-argument-mismatch to FCFLAGS"

  export FCFLAGS="-fallow-argument-mismatch ${FCFLAGS}"
else
  echo "FCFLAGS: $FCFLAGS"
fi


if [[ "$mpi" == "nompi" ]]; then
  # Install for standard sequential
  ./waf_std \
    --use-config=wafcfg_conda \
    --use-config-dir="$RECIPE_DIR"/config \
    --prefix="${PREFIX}" \
    --med-libs="med medC medfwrap medimport" \
    --libdir="${PREFIX}/lib" \
    --install-tests \
    --disable-mpi \
    --without-hg \
    configure

  if [[ "${build_type}" == "debug" ]]; then
      ./waf_std install_debug -v
  else
      echo "Debugging Disabled"
      ./waf_std install
  fi
else
  export PYTHONPATH="$PYTHONPATH:${PREFIX}/lib"
  export CONFIG_PARAMETERS_addmem=4096

  export ENABLE_MPI=1
  export CC=mpicc
  export CXX=mpicxx
  export FC=mpif90
  export F77=mpif77
  export F90=mpif90
  export OPAL_PREFIX=${PREFIX}

  ./waf_mpi configure \
    --use-config=wafcfg_conda \
    --use-config-dir="$RECIPE_DIR"/config \
    --prefix="${PREFIX}" \
    --med-libs="medC" \
    --enable-mpi \
    --libdir="${PREFIX}/lib" \
    --install-tests \
    --without-hg


  if [[ "${build_type}" == "debug" ]]; then
      ./waf_mpi install_debug
  else
      ./waf_mpi install
  fi
fi

echo "Compilation complete"

# Change the PYTHONPATH just for pybind11_stubgen to find the necessary module
export PYTHONPATH="${PREFIX}/lib/aster:$SRC_DIR/stubgen"
export LD_LIBRARY_PATH="${PREFIX}/lib/aster"

# This is for reducing reliance on conda activation scripts.
mv "${PREFIX}/lib/aster/code_aster" "${SP_DIR}/code_aster"
mv "${PREFIX}/lib/aster/run_aster" "${SP_DIR}/run_aster"


mv ${SRC_DIR}/build/${mpi_type}/${build_type}/code_aster/*.py "${SP_DIR}/code_aster/Utilities/"
# note to self. aster.so is symlinked to libaster.so
mv ${PREFIX}/lib/aster/libb*.so "${PREFIX}/lib/"
mv ${PREFIX}/lib/aster/libAsterMFrOff*.so "${PREFIX}/lib/"

mv "${PREFIX}/lib/aster/med_aster.so" "${SP_DIR}/"
mv ${PREFIX}/lib/aster/*.so "${SP_DIR}/"
cp "${RECIPE_DIR}/config/__init__.py" "${SP_DIR}/code_aster/__init__.py"

# copy modified shell scripts and create backups of the ones we don't want.
cp "${PREFIX}/bin/run_aster" "${PREFIX}/bin/_run_aster_old"
cp "${PREFIX}/bin/run_ctest" "${PREFIX}/bin/_run_ctest_old"

cp "${RECIPE_DIR}/config/run_aster" "${PREFIX}/bin/run_aster"
cp "${RECIPE_DIR}/config/run_ctest" "${PREFIX}/bin/run_ctest"
# Update the path to python env root dir in run_aster utils.py
