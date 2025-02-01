#!/bin/bash
set -e

# Ensure required tools are available
if ! command -v cmake &> /dev/null; then
    echo "cmake not found, ensure it is installed."
    exit 1
fi

PREFIX="${PREFIX}"

# Libraries
for lib in ptscotch ptscotcherr ptscotcherrexit ptesmumps; do
    if [ -f "$PREFIX/lib/lib${lib}${SHLIB_EXT}" ]; then
        echo "Found $PREFIX/lib/lib${lib}${SHLIB_EXT}"
    else
        echo "Missing $PREFIX/lib/lib${lib}${SHLIB_EXT}"
        exit 1
    fi
done

# Include files
for header in ptscotch.h ptscotchf.h ptesmumps.h; do
    if [ -f "$PREFIX/include/$header" ]; then
        echo "Found $PREFIX/include/$header"
    else
        echo "Missing $PREFIX/include/$header"
        exit 1
    fi
done

# parmetis.h should exist in scotch but not globally
if [ -f "$PREFIX/include/scotch/parmetis.h" ]; then
    echo "Found $PREFIX/include/scotch/parmetis.h"
else
    echo "Missing $PREFIX/include/scotch/parmetis.h"
    exit 1
fi

if [ -f "$PREFIX/include/parmetis.h" ]; then
    echo "Unexpected file found: $PREFIX/include/parmetis.h"
    exit 1
fi

# dgord should NOT exist
if [ -f "$PREFIX/bin/dgord" ]; then
    echo "Unexpected file found: $PREFIX/bin/dgord"
    exit 1
fi

echo "All tests passed."
