export FCFLAGS="-w -fallow-argument-mismatch -O2 -fdefault-integer-8 ${FCFLAGS}"
export FFLAGS="-w -fallow-argument-mismatch -O2 -fdefault-integer-8 ${FFLAGS}"

./configure --prefix=$PREFIX --with-f90 --with-hdf5=$PREFIX
make
make install
