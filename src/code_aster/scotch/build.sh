#!/bin/bash

# A very basic
if [ -d "$SRC_DIR/deps" ]; then
  echo "/deps directory exists."
  tar -xzvf "$SRC_DIR/deps/archives/scotch-7.0.1.tar.gz" -C . --strip-components=1
  mkinc=src/Make.inc/Makefile.inc.x86-64_pc_linux2
  sed -e "s|CFLAGS\s*=|CFLAGS = ${CFLAGS} -Wl,--no-as-needed -DINTSIZE64|g" \
        -e "s|CCD\s*=.*$|CCD = cc|g" ${mkinc} > src/Makefile.inc

else
  echo "/deps directory does not exist."
  cp $RECIPE_DIR/Makefile.inc.x86-64_pc_linux2 src/Makefile.inc
fi

cd src

make scotch
make esmumps

make install prefix=${PREFIX}
