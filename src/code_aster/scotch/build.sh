#!/bin/bash

export CLICOLOR_FORCE=1


tar -xzf "$SRC_DIR/deps/archives/scotch-7.0.1.tar.gz" -C . --strip-components=1

mkinc=Make.inc/Makefile.inc.x86-64_pc_linux2

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

cd src

if [ "${mpi}" == "nompi" ]; then
  echo "Compiling non-mpi -> mpi=$mpi"

  sed -e "s|CFLAGS\s*=|CFLAGS = ${CFLAGS} -Wl,--no-as-needed -DINTSIZE64|g" \
        -e "s|CCD\s*=.*$|CCD = cc|g" ${mkinc} > Makefile.inc

  make scotch
else
  echo "Compiling mpi=$mpi"

  sed -e "s|CFLAGS\s*=|CFLAGS = ${CFLAGS} -Wl,--no-as-needed -DINTSIZE64|g" \
    -e "s|CCD\s*=.*$|CCD = mpicc|g" ${mkinc} > Makefile.inc

  # see https://bugzilla.redhat.com/show_bug.cgi?id=1386707
  # we do not use MPI_Init_Thread
  sed -i -e "s/-DSCOTCH_PTHREAD_MPI//g" -e "s/-DSCOTCH_PTHREAD//g" Makefile.inc

  make scotch
  make ptscotch
fi

make esmumps
make install prefix=${PREFIX}