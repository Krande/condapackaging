#!/bin/bash
set -ex

export HDF5_VERSION=${hdf5}
if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  echo "This is a CROSS-COMPILATION"
  # load HDF5 library from _build_env
  export HDF5_DIR=${BUILD_PREFIX}
else
  export HDF5_DIR=${PREFIX}
fi
export OPAL_PREFIX=${PREFIX}
if [[ "$mpi" != "nompi" ]]; then
  export HDF5_MPI="ON"
fi

if [[ ${target_platform} == "osx-arm64" ]]; then
  # disable complex256 on macOS ARM64, see https://github.com/h5py/h5py/pull/2065
  export CIBW_ARCHS_MACOS=arm64
fi

echo "Copying files"
cp -f "$RECIPE_DIR/config/setup_configure.py" "$SRC_DIR/setup_configure.py"
cp -f "$RECIPE_DIR/config/version.py" "$SRC_DIR/h5py/version.py"
cp -f "$RECIPE_DIR/config/__init__.py" "$SRC_DIR/h5py/__init__.py"
cp -f "$RECIPE_DIR/config/test_file.py" "$SRC_DIR/h5py/tests/test_file.py"
echo "Files copied"

# tell setup.py to not 'pip install' exact package requirements
export H5PY_SETUP_REQUIRES="0"

"${PYTHON}" -m pip install . --no-deps --ignore-installed --no-cache-dir -vv
