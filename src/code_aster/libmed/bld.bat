@echo off

mkdir build
cd build
set MY_PY_VER=%PY_VER:.=%

set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
set FFLAGS=-fdefault-integer-8 %FFLAGS%

if exist "%PREFIX%\Library\mingw-w64\bin\gcc.exe" (
    echo "Mingw-w64 found"
    set CC=%PREFIX%\Library\mingw-w64\bin\gcc.exe
    set CXX=%PREFIX%\Library\mingw-w64\bin\g++.exe
    set FC=%PREFIX%\Library\mingw-w64\bin\gfortran.exe
    set RC=%PREFIX%\Library\mingw-w64\bin\windres.exe
    set F77=${FC}
)

IF "%PKG_DEBUG%"=="True" (
    echo Debugging Enabled
    REM Set compiler flags for debugging, for instance
    set CFLAGS=-g -O0 %CFLAGS%
    set CXXFLAGS=-g -O0 %CXXFLAGS%
    set FCFLAGS=-g -O0 %FCFLAGS%
    REM Additional debug build steps
) ELSE (
    echo Debugging Disabled
)


cmake -G "Ninja" -S %SRC_DIR%^
    -D CMAKE_BUILD_TYPE=Debug ^
    -D CMAKE_Fortran_FLAGS=-fdefault-integer-8 %CMAKE_Fortran_FLAGS% ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_C_COMPILER:FILEPATH="%CC%" ^
    -D CMAKE_CXX_COMPILER:FILEPATH="%CXX%" ^
    -D CMAKE_Fortran_COMPILER:FILEPATH="%FC%" ^
    -D CMAKE_RC_COMPILER:FILEPATH="%RC%" ^
    -D MED_INT_TYPE:STRING=int ^
    -D MEDFILE_INSTALL_DOC=OFF ^
    -D MEDFILE_BUILD_PYTHON=ON ^
    -D MEDFILE_BUILD_SHARED_LIBS=ON ^
    -D MEDFILE_BUILD_STATIC_LIBS=OFF ^
    -D MEDFILE_USE_UNICODE=OFF ^
    -D PYTHON_INCLUDE_DIR=%PREFIX%\include ^
    -D PYTHON_EXECUTABLE:FILEPATH=%PREFIX%\python.exe ^
    -D PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib ^
    -D SIZEOF_LONG_LONG=8

if errorlevel 1 exit 1
ninja -v
if errorlevel 1 exit 1
ninja install -v