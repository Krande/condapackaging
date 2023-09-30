#!/bin/bash

export CLICOLOR_FORCE=1

export LDFLAGS="-L$PREFIX/lib -lm -lpthread -lrt -ldl -lz -lgomp ${LDFLAGS}"
export LIBPATH="$PREFIX/lib $LIBPATH"

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

# missing include causes issues with gcc > 12
major_version=$($FC -dumpversion | awk -F. '{print $1}')
if [[ $major_version -gt 12 ]]; then
  echo "adding '#include <cstdint>' to src/System/LibraryInformation.cxx"
  awk '/#include <cstring>/ { print; print "#include <cstdint>"; next }1' src/System/LibraryInformation.cxx > tmp.cxx && mv tmp.cxx src/System/LibraryInformation.cxx
else
  echo "no modification needed"
fi


cmake -S . -B build \
    -Wno-dev \
    -DCMAKE_BUILD_TYPE=$build_type \
    -Dlocal-castem-header=ON \
    -Denable-fortran=ON \
    -Denable-python-bindings=ON \
    -Denable-cyrano=ON \
    -Denable-aster=ON \
    -Denable-portable-build=ON \
    -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
    -Denable-python=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DPYTHONLIBS_VERSION_STRING="${CONDA_PY}" \
    -DPython_ADDITIONAL_VERSIONS="${python_version}" \
    -DPYTHON_EXECUTABLE:FILEPATH="${PREFIX}/bin/python" \
    -DPYTHON_LIBRARY:FILEPATH="${PREFIX}/lib/libpython${python_version}.so" \
    -DPYTHON_LIBRARY_PATH:PATH="${PREFIX}/lib" \
    -DPYTHON_INCLUDE_DIRS:PATH="${PREFIX}/include" \
    -DUSE_EXTERNAL_COMPILER_FLAGS=ON


cmake --build ./build --config Release

cmake --install ./build --verbose
