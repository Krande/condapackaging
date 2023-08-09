@echo off
echo Build MFRONT/TFEL
REM assuming you have already downloaded tfel using the conda recipe to "deps/mfront"

cd deps\mfront
if not exist build mkdir build
cd build

cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -Dlocal-castem-header=ON ^
    -Denable-fortran=ON ^
    -Denable-broken-boost-python-module-visibility-handling=ON ^
    -Denable-python-bindings=ON ^
    -Denable-cyrano=ON -Denable-aster=ON ^
    -Ddisable-reference-doc=ON ^
    -Ddisable-website=ON ^
    -Denable-portable-build=ON ^
    -DPython_ADDITIONAL_VERSIONS=%CONDA_PY% ^
    -Denable-python=ON ^
    -DPYTHON_EXECUTABLE:FILEPATH=%PYTHON% ^
    -DPYTHON_LIBRARY:FILEPATH=%LIBRARY_PREFIX%\lib\libpython%CONDA_PY%.dll ^
    -DPYTHON_INCLUDE_DIR:PATH=%LIBRARY_PREFIX%\include\python%CONDA_PY% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%

REM Adjust the parallel build command as needed; for example, you can replace $(nproc) with the number of cores on your machine
make install
cd ..\..
echo MFRONT/TFEL build complete
