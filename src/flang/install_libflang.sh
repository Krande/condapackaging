#!/bin/bash
set -ex

# copy symlink & its target, e.g. libFortranRuntime.so.16 & libFortranRuntime.so
cp $SRC_DIR/build/lib/libFortranRuntime*${SHLIB_EXT}* $PREFIX/lib
# same for libFortranDecimal
cp $SRC_DIR/build/lib/libFortranDecimal*${SHLIB_EXT}* $PREFIX/lib
