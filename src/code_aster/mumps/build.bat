@echo off

setlocal enabledelayedexpansion

mkdir build
cd build

:: Set compilers
set CC=cl
set CXX=cl
:: set FC=flang-new
:: Needed by IFX
set "LIB=%BUILD_PREFIX%\Library\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\opt\compiler\include\intel64;%INCLUDE%"
set "CMAKE_ARGS=!CMAKE_ARGS! -D HDF5_BUILD_FORTRAN:BOOL=ON"


set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /nologo /Od /debug /Zi
    set FCFLAGS=%FCFLAGS% /nologo /Od /debug /Zi /debug-parameters:all /traceback
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

:: Needed for the pthread library when linking with scotch
set LDFLAGS=%LDFLAGS% /LIBPATH:%LIBRARY_LIB%
set CFLAGS=%CFLAGS% /Dtry_null_space /DUSE_SCHEDAFFINITY
set FCFLAGS=%FCFLAGS% /4L132 -Dtry_null_space -DUSE_SCHEDAFFINITY -DUSE_MPI3

set INTSIZE_BOOL=OFF
set MKL_VENDOR=MKL

if "%int_type%" == "64" (
    echo "Using 64-bit integers"
    set CFLAGS=%CFLAGS% -DPORD_INTSIZE64
    set FCFLAGS=%FCFLAGS% -DPORD_INTSIZE64 /integer-size:64 /4I8
    set INTSIZE_BOOL=ON
    set MKL_VENDOR=MKL64
)
echo "Build type: %TGT_BUILD_TYPE%, int size: %int_type%, MKL vendor: %MKL_VENDOR%"
echo "FFLAGS: %FFLAGS%"
echo "CFLAGS: %CFLAGS%"
echo "LDFLAGS: %LDFLAGS%"

:: Configure using the CMakeFiles
cmake -G "Ninja" ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE:STRING=%TGT_BUILD_TYPE% ^
      -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      -D MUMPS_UPSTREAM_VERSION:STRING=5.7.2 ^
      -D MKL_DIR:PATH=%LIBRARY_PREFIX%/lib ^
      -D LAPACK_VENDOR:STRING=%MKL_VENDOR% ^
      -D intsize64:BOOL=%INTSIZE_BOOL% ^
      -D gemmt:BOOL=ON ^
      -D metis:BOOL=ON ^
      -D scotch:BOOL=ON ^
      -D openmp:BOOL=OFF ^
      -D parallel:BOOL=OFF ^
      -D BUILD_SHARED_LIBS:BOOL=OFF ^
      -D BUILD_SINGLE:BOOL=ON ^
      -D BUILD_DOUBLE:BOOL=ON ^
      -D BUILD_COMPLEX:BOOL=ON ^
      -D BUILD_COMPLEX16:BOOL=ON ^
      ..

if errorlevel 1 exit 1
cmake --build . --config %TGT_BUILD_TYPE% --target install

if errorlevel 1 exit 1

if "%int_type%" == "32" (
    python %RECIPE_DIR%/make_integers_explicit.py
)

if errorlevel 1 exit 1

endlocal