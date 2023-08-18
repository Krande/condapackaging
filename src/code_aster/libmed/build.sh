export FCFLAGS="-fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-fdefault-integer-8 ${FFLAGS}"

./configure --with-swig=yes --prefix="$PREFIX" --with-f90 --with-hdf5="$PREFIX"
make
make install

rm -rf "${PREFIX}/share/doc/med"
