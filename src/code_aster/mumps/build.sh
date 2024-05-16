#!/bin/bash
export CLICOLOR_FORCE=1

tar -xzf "$SRC_DIR/deps/archives/mumps-5.6.2.tar.gz" -C . --strip-components=1

echo "FC: $FC, Version: $($FC -dumpversion)"
echo "CC: $CC"
echo "CXX: $CXX"
echo "CFLAGS: $CFLAGS"

export CFLAGS="-DUSE_SCHEDAFFINITY -Dtry_null_space ${CFLAGS}"
export FCFLAGS="-DUSE_MPI3 ${FCFLAGS}"
export FCFLAGS="-ffixed-line-length-none ${FCFLAGS}"

# if gfortran version > 9, we need to conditionally add -fallow-argument-mismatch
# to avoid mismatch errors related to floats and integer types
major_version=$($FC -dumpversion | awk -F. '{print $1}')
if [[ $major_version -gt 9 ]]; then
  echo "adding -fallow-argument-mismatch to FCFLAGS"
  export FCFLAGS="-fallow-argument-mismatch ${FCFLAGS}"
else
  echo "FCFLAGS: $FCFLAGS"
fi

# add explicit length declaration in include
echo "Substituting INTEGER"

sed -i 's/INTEGER *,/INTEGER(4),/g' include/*_{struc,root}.h
sed -i 's/INTEGER *::/INTEGER(4) ::/g' include/*_{struc,root}.h
sed -i 's/INTEGER MPI/INTEGER(4) MPI/g' libseq/mpif.h
sed -i 's/REAL *,/REAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
sed -i 's/REAL *::/REAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
sed -i 's/COMPLEX *,/COMPLEX(4),/g' include/*_{struc,root}.h libseq/mpif.h
sed -i 's/COMPLEX *::/COMPLEX(4) ::/g' include/*_{struc,root}.h libseq/mpif.h
sed -i 's/LOGICAL *,/LOGICAL(4),/g' include/*_{struc,root}.h libseq/mpif.h
sed -i 's/LOGICAL *::/LOGICAL(4) ::/g' include/*_{struc,root}.h libseq/mpif.h

echo "INTEGER Substituting finished"

export LIBPATH="$PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/include $INCLUDES"

if [[ "${PKG_DEBUG}" == "True" ]]; then
    echo "Debugging Enabled"
    export CFLAGS="-g -O0 ${CFLAGS}"
    export CXXFLAGS="-g -O0 ${CXXFLAGS}"
    export FCFLAGS="-g -O0 ${FCFLAGS}"
else
    echo "Debugging Disabled"
fi

libscal="-lscalapack"
libmath="-lcblas"
libomp="-lgomp"
flagomp="-fopenmp"

# variables used in the template
orderingsf=( "-Dpord" "-Dmetis" "-Dscotch" )
scotchlib=( "-lesmumps -lscotch -lscotcherr -lscotcherrexit" )
incparmetis=""
libparmetis=""
varincs=INCSEQ
varlibs=LIBSEQ
libseqneeded=libseqneeded

if [ "${mpi}" != "nompi" ]; then
  echo "Building MPI '${mpi}'"
    orderingsf+=( "-Dparmetis" "-Dptscotch" )
    scotchlib+=( "-lptscotch -lptscotcherr -lptscotcherrexit" )
    incparmetis="IPARMETIS  = -I${PREFIX}/include"
    libparmetis="LPARMETIS  = -L${PREFIX}/lib -lparmetis"
    varincs=INCPAR
    varlibs=LIBPAR
    libseqneeded=
fi

pathscalapack=$(awk '{print $1}' <<< "${libscal}")
pathscalapack=${pathscalapack/-L/}
common_flags=" -fPIC ${flagomp} -DPORD_INTSIZE64"
rpaths=( -Wl,-rpath,${PREFIX}/lib/ )

if [ "${mpi}" == "nompi" ]; then
  include_arg=""
  link_arg=""
else
  include_arg=$(exec ${FC} --showme:incdirs)
  link_arg=$(exec ${FC} --showme:link)
fi

# templating...
cat << eof > Makefile.inc
# Makefile for mumps

LPORDDIR   = \$(topdir)/PORD/lib/
IPORD      = -I\$(topdir)/PORD/include/
LPORD      = -L\$(LPORDDIR) -lpord

IMETIS     = -I${PREFIX}/include
LMETIS     = -L${PREFIX}/lib -lmetis
${incparmetis}
${libparmetis}
ISCOTCH    = -I${PREFIX}/include
LSCOTCH    = -L${PREFIX}/lib ${scotchlib[@]}

ORDERINGSF = ${orderingsf[@]}
ORDERINGSC = \$(ORDERINGSF)
LORDERINGS  = \$(LPORD) \$(LMETIS) \$(LPARMETIS) \$(LSCOTCH)
IORDERINGSC = \$(IPORD) \$(IMETIS) \$(IPARMETIS) \$(ISCOTCH)
IORDERINGSF = \$(ISCOTCH)

PLAT =
LIBEXT_SHARED = .so
SONAME = -soname
FPIC_OPT = -fPIC

# Adapt/uncomment RPATH_OPT to avoid modifying
# LD_LIBRARY_PATH in case of shared libraries
RPATH_OPT = ${rpaths[@]}

CC = ${CC}
FC = ${FC}
FL = ${FC}
OUTC = -o
OUTF = -o
# WARNING: AR must ends with a blank space!
AR = ${AR}
RANLIB = echo
RM = /bin/rm -f

LAPACK = -llapack
SCALAP = ${libscal}
INCPAR = -I${PREFIX}/include
LIBPAR = \$(SCALAP) ${link_arg}
INCSEQ = -I\$(topdir)/libseq
LIBSEQ = \$(LAPACK) -L\$(topdir)/libseq -lmpiseq
LIBBLAS = ${libmath}
LIBOTHERS = ${libomp} -lpthread

CDEFS = -DAdd_

OPTF = ${common_flags} ${FCFLAGS}
OPTC = ${common_flags} ${CFLAGS}
OPTL = ${common_flags}

INCS = \$(${varincs})
LIBS = \$(${varlibs})
LIBSEQNEEDED = ${libseqneeded}
eof

cat Makefile.inc

# build
make allshared -j ${procs}

# move installation
cp Makefile.inc ${PREFIX}/share/
cp include/* ${PREFIX}/include/
mkdir -p "${PREFIX}/include_seq/"
cp libseq/mpi*.h ${PREFIX}/include_seq/
cp lib/* ${PREFIX}/lib/
cp -r examples ${PREFIX}/share/
rm ${PREFIX}/share/examples/*.*