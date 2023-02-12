rem https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots

mkdir build -p
cd build

echo "**************** M F R O N T  B U I L D  S T A R T S  H E R E ****************"

cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -Dlocal-castem-header=ON \
    -Denable-fortran=ON \
    -Denable-aster=ON \
    -Denable-cyrano=ON \
    -DPython_ADDITIONAL_VERSIONS=%CONDA_PY% \
    -Denable-python=ON \
    -Denable-python-bindings=OFF \
    -Denable-broken-boost-python-module-visibility-handling=ON \
    -DCMAKE_INSTALL_PREFIX=$PREFIX

make -j
make install

echo "**************** M F R O N T  B U I L D  E N D S  H E R E ****************"