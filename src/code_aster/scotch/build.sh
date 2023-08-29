#!/bin/bash


tar -xzvf "$SRC_DIR/deps/archives/scotch-7.0.1.tar.gz" -C . --strip-components=1

mkinc=src/Make.inc/Makefile.inc.x86-64_pc_linux2
sed -e "s|CFLAGS\s*=|CFLAGS = ${CFLAGS} -Wl,--no-as-needed -DINTSIZE64|g" \
      -e "s|CCD\s*=.*$|CCD = cc|g" ${mkinc} > src/Makefile.inc

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
else
    echo "Debugging Disabled"
fi

cd src
make scotch
make esmumps

make install prefix=${PREFIX}
