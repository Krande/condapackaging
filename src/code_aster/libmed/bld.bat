@echo off

mkdir build
cd build


set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
set FFLAGS=-fdefault-integer-8 %FFLAGS%
set MED_MEDINT_TYPE=int

:: set c int size to 8 bytes
set CMAKE_C_FLAGS=-fdefault-integer-8 %CMAKE_C_FLAGS%
set CMAKE_CXX_FLAGS=-fdefault-integer-8 %CMAKE_CXX_FLAGS%

cmake -G "Ninja" -S %SRC_DIR%^
    -Wno-dev ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D "CMAKE_PREFIX_PATH:FILEPATH=%PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX:FILEPATH=%PREFIX%" ^
    -D "HDF5_ROOT_DIR:FILEPATH=%LIBRARY_PREFIX%/lib" ^
    -D CMAKE_POSITION_INDEPENDENT_CODE=ON ^
    -D MEDFILE_INSTALL_DOC=OFF ^
    -D MEDFILE_BUILD_PYTHON=ON ^
    -D "PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib" ^
    -D "PYTHON_INCLUDE_DIR:FILEPATH=%PREFIX%\include" ^
    -D SIZEOF_LONG_LONG=8

if errorlevel 1 exit 1
ninja
if errorlevel 1 exit 1
ninja install