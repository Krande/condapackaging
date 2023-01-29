export FCFLAGS="-w -fallow-argument-mismatch -O2"
export FFLAGS="-w -fallow-argument-mismatch -O2"

#mkdir build -p
#cd build 

#cmake -G "Ninja"  \
#      -D CMAKE_BUILD_TYPE=Release \
#      -D CMAKE_INSTALL_PREFIX=$PREFIX \
#      -D MEDFILE_INSTALL_DOC=OFF \
#      -D MEDFILE_BUILD_PYTHON=ON \
#      ..

#ninja install
#ninja test

./configure --prefix=$PREFIX --with-f90 --with-hdf5=$PREFIX
make
make check 
make installcheck
make install