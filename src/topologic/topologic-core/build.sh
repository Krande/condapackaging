#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status.
set -x  # Print commands and their arguments as they are executed.

export CLICOLOR_FORCE=1

# Set build type
TGT_BUILD_TYPE=Release
if [[ "$build_type" == "debug" ]]; then
    TGT_BUILD_TYPE=RelWithDebInfo
    export CFLAGS="$CFLAGS -O0 -g"
    export CXXFLAGS="$CXXFLAGS -O0 -g"
    export FCFLAGS="$FCFLAGS -O0 -g -fbacktrace"
    export LDFLAGS="$LDFLAGS -g"
fi

# Run cmake configuration
cmake -B "build" -G "Ninja" \
  -D CMAKE_BUILD_TYPE:STRING="${TGT_BUILD_TYPE}" \
  -D CMAKE_INSTALL_PREFIX:FILEPATH="${LIBRARY_PREFIX}" \
  -D CMAKE_PREFIX_PATH:FILEPATH="${LIBRARY_PREFIX}" \
  -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="${LIBRARY_PREFIX}" \
  -D USE_CONDA_PYBIND11:BOOL=ON \
  -D OCC_INCLUDE_DIR:FILEPATH="${LIBRARY_PREFIX}/include/opencascade" \
  -D OCC_LIBRARY_DIR:FILEPATH="${LIBRARY_PREFIX}/lib" \
  -D PYTHON_INCLUDE_DIR="${PREFIX}/include" \
  -D PYTHON_EXECUTABLE:FILEPATH="${PREFIX}/bin/python" \
  -D PYTHON_LIBRARY:FILEPATH="${PREFIX}/lib/libpython${MY_PY_VER}.so" \
  ../TopologicCore

# Build the project
cmake --build "build" --config "${TGT_BUILD_TYPE}"

# Install the built files
cmake --install "build" --config "${TGT_BUILD_TYPE}"

# Move output files to appropriate directories
mv "${LIBRARY_LIB}/TopologicCore/"*.so "${LIBRARY_PREFIX}/bin" || true
mv "${LIBRARY_LIB}/TopologicCore/"*.a "${LIBRARY_PREFIX}/lib" || true
mv "${LIBRARY_LIB}/TopologicPythonBindings/"*.so "${PREFIX}/lib/python${MY_PY_VER}/site-packages" || true
