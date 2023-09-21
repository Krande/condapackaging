@echo off

mkdir build
cd build


set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
set FFLAGS=-fdefault-integer-8 %FFLAGS%
set MED_MEDINT_TYPE=int

:: set c int size to 8 bytes
set CMAKE_C_FLAGS=-fdefault-integer-8 %CMAKE_C_FLAGS%
set CMAKE_CXX_FLAGS=-fdefault-integer-8 %CMAKE_CXX_FLAGS%

:: Mingw-w64
if exist "%BUILD_PREFIX%\Library\mingw-w64\bin\gcc.exe" (
    echo "Mingw-w64 found"
    set CC_PATH=%BUILD_PREFIX%\Library\mingw-w64\bin\gcc.exe
    set CXX_PATH=%BUILD_PREFIX%\Library\mingw-w64\bin\g++.exe
    set GF_PATH=%BUILD_PREFIX%\Library\mingw-w64\bin\gfortran.exe
) else (
    if exist "%BUILD_PREFIX%\Library\bin\gcc.exe" (
        echo "GCC found"
        set CC_PATH=%BUILD_PREFIX%\Library\bin\gcc.exe
        set CXX_PATH=%BUILD_PREFIX%\Library\bin\g++.exe
        set GF_PATH=%BUILD_PREFIX%\Library\bin\gfortran.exe
    ) else (
        if exist "%BUILD_PREFIX%\Library\bin\clang.exe" (
            echo "Flang found!"
            set CC_PATH=%BUILD_PREFIX%\Library\bin\clang.exe
            set CXX_PATH=%BUILD_PREFIX%\Library\bin\clang++.exe
            set GF_PATH=%BUILD_PREFIX%\Library\bin\flang.exe
        )
    )
)


echo "CC_PATH=%CC_PATH%"
echo "CXX_PATH=%CXX_PATH%"
echo "GF_PATH=%GF_PATH%"

set CC=%CC_PATH%
set CXX=%CXX_PATH%
set FC=%GF_PATH%
echo "CC=%CC%"
echo "CXX=%CXX%"
echo "FC=%FC%"

set CMAKE_C_COMPILER=%CC%
set CMAKE_CXX_COMPILER=%CXX%
set CMAKE_Fortran_COMPILER=%FC%

cmake -G "Ninja" -S ..^
    -Wno-dev ^
    -D CMAKE_C_COMPILER:FILEPATH=%CMAKE_C_COMPILER% ^
    -D CMAKE_CXX_COMPILER:FILEPATH=%CMAKE_CXX_COMPILER% ^
    -D CMAKE_Fortran_COMPILER:FILEPATH=%CMAKE_Fortran_COMPILER% ^
    -D CMAKE_C_COMPILER:FILEPATH=%CMAKE_C_COMPILER% ^
    -D CMAKE_CXX_COMPILER:FILEPATH=%CMAKE_CXX_COMPILER% ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D "CMAKE_PREFIX_PATH:FILEPATH=%PREFIX%" ^
    -D "CMAKE_INSTALL_PREFIX:FILEPATH=%PREFIX%" ^
    -D "HDF5_ROOT_DIR:FILEPATH=%LIBRARY_PREFIX%/lib" ^
    -D MEDFILE_INSTALL_DOC=OFF ^
    -D MEDFILE_BUILD_PYTHON=ON ^
    -D "PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib" ^
    -D "PYTHON_INCLUDE_DIR:FILEPATH=%PREFIX%\include" ^
    -D SIZEOF_LONG_LONG=8

if errorlevel 1 exit 1
ninja
if errorlevel 1 exit 1
ninja install