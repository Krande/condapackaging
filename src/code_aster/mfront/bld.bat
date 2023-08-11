@echo off
echo Build MFRONT/TFEL

if not exist build mkdir build
cd build

cmake .. -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -Denable-fortran=OFF ^
    -Denable-python-bindings=ON ^
    -Denable-cyrano=ON ^
    -Denable-aster=ON ^
    -Ddisable-reference-doc=ON ^
    -Ddisable-website=ON ^
    -Denable-portable-build=ON ^
    -DPython_ADDITIONAL_VERSIONS=%CONDA_PY% ^
    -Denable-python=ON ^
    -DPYTHON_EXECUTABLE:FILEPATH=%PYTHON% ^
    -DPYTHON_LIBRARY:FILEPATH=%LIBRARY_PREFIX%\lib ^
    -DPYTHON_INCLUDE_DIR:PATH=%LIBRARY_PREFIX%\include ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^

REM Adjust the parallel build command as needed; for example, you can replace $(nproc) with the number of cores on your machine
ninja install

IF ERRORLEVEL 1 (
  type configure.log
  exit /b 1
)
echo MFRONT/TFEL build complete