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

# The -fPIC flag is automatically added by conda-build, but I'll add it here just in case
mkdir -p $PREFIX
make config prefix=$PREFIX CFLAGS="-fPIC ${CFLAGS}"
make
make install

echo "METIS Build complete"