#!/bin/bash
set -e

PREFIX="${PREFIX}"

# Libraries
for lib in scotch scotcherr scotcherrexit esmumps; do
    if [ -f "$PREFIX/lib/lib${lib}${SHLIB_EXT}" ]; then
        echo "Found $PREFIX/lib/lib${lib}${SHLIB_EXT}"
    else
        echo "Missing $PREFIX/lib/lib${lib}${SHLIB_EXT}"
        exit 1
    fi
done

# Include files
for header in scotch.h scotchf.h esmumps.h; do
    if [ -f "$PREFIX/include/$header" ]; then
        echo "Found $PREFIX/include/$header"
    else
        echo "Missing $PREFIX/include/$header"
        exit 1
    fi
done

# metis.h should NOT exist
if [ -f "$PREFIX/include/metis.h" ]; then
    echo "Unexpected file found: $PREFIX/include/metis.h"
    exit 1
fi

# scotch/metis.h should exist
if [ -f "$PREFIX/include/scotch/metis.h" ]; then
    echo "Found $PREFIX/include/scotch/metis.h"
else
    echo "Missing $PREFIX/include/scotch/metis.h"
    exit 1
fi

# gord should NOT exist
if [ -f "$PREFIX/bin/gord" ]; then
    echo "Unexpected file found: $PREFIX/bin/gord"
    exit 1
fi

echo "All tests passed."
