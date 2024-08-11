#!/bin/bash
export CLICOLOR_FORCE=1

# Install metis-aster
echo "** Building METIS **"

if [[ "${build_type}" == "debug" ]]; then
    echo "Debugging Enabled"
    export TGT_BUILD_TYPE="Debug"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

mkdir "content"
#tar -xzf "$SRC_DIR/deps/archives/gklib-master.tar.gz" -C ${SRC_DIR}/content --strip-components=1
#tar -xzf "$SRC_DIR/deps/archives/parmetis-4.0.3_aster3.tar.gz" -C ${SRC_DIR} --strip-components=1

cmake -Bbuild -G Ninja -Drealsize=64 -Dintsize=64 -DBUILD_SHARED_LIBS=ON \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    -D CMAKE_PREFIX_PATH="${PREFIX}" \
    -D CMAKE_BUILD_TYPE=${TGT_BUILD_TYPE}

ninja -C build install

echo "METIS Build complete"