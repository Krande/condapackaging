#!/bin/bash
export CLICOLOR_FORCE=1

# Install metis-aster
echo "** Building METIS **"

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

mkdir "content"
tar -xzf "$SRC_DIR/deps/archives/gklib-master.tar.gz" -C ${SRC_DIR}/content --strip-components=1
tar -xzf "$SRC_DIR/deps/archives/parmetis-4.0.3_aster3.tar.gz" -C ${SRC_DIR} --strip-components=1

# GKLib
cd content

make config CFLAGS="-fPIC ${CFLAGS}" prefix=$PREFIX
make -j ${procs}
make install

# METIS
cd ../metis
# The -fPIC flag is automatically added by conda-build, but I'll add it here just in case
make config CFLAGS="-fPIC ${CFLAGS}" \
    prefix=${PREFIX} \
    shared=1 i64=1 r64=1
make -j ${procs}
make install

echo "METIS Build complete"