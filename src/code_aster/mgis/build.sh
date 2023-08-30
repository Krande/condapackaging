#!/bin/bash

mkdir build
cd build

#export LDFLAGS="--sysroot ${CONDA_BUILD_SYSROOT}
# ${LDFLAGS}"
export TFELHOME="${PREFIX}"
python_version="${CONDA_PY:0:1}.${CONDA_PY:1:2}"

if [[ "${PKG_DEBUG}" == "True" ]]; then
  echo "Debugging Enabled"
  export CFLAGS="-g -O0 ${CFLAGS}"
  export CXXFLAGS="-g -O0 ${CXXFLAGS}"
  export FCFLAGS="-g -O0 ${FCFLAGS}"
  build_type="Debug"
else
  build_type="Release"
  echo "Debugging Disabled"
fi

cmake .. \
    -DCMAKE_BUILD_TYPE=$build_type \
    -Denable-c-bindings=OFF \
    -Denable-fortran-bindings=OFF \
    -Denable-python-bindings=ON \
    -Denable-portable-build=ON \
    -Denable-julia-bindings=OFF \
    -Denable-website=OFF \
    -Denable-broken-boost-python-module-visibility-handling=ON \
    -DPYTHONLIBS_VERSION_STRING="${CONDA_PY}" \
    -DPython_ADDITIONAL_VERSIONS="${python_version}" \
    -DPYTHON_EXECUTABLE:FILEPATH="${PREFIX}/bin/python" \
    -DPYTHON_LIBRARY:FILEPATH="${PREFIX}/lib/libpython${python_version}.so" \
    -DPYTHON_LIBRARY_PATH:PATH="${PREFIX}/lib" \
    -DPYTHON_INCLUDE_DIRS:PATH="${PREFIX}/include" \
    -DUSE_EXTERNAL_COMPILER_FLAGS=ON \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}"

make
make install