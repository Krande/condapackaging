@echo off

setlocal enabledelayedexpansion

mkdir build
cd build

:: Set compilers
set CC=cl
set CXX=cl
:: set FC=flang-new

if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
)

:: Needed for the pthread library when linking with scotch
set LDFLAGS=%LDFLAGS% /LIBPATH:%LIBRARY_LIB% pthread.lib
set CFLAGS=%CFLAGS% /Dtry_null_space /DUSE_SCHEDAFFINITY
set FCFLAGS=%FCFLAGS% -Dtry_null_space -DUSE_SCHEDAFFINITY

:: Configure using the CMakeFiles
cmake -G "Ninja" ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE:STRING=Release ^
      -D MUMPS_UPSTREAM_VERSION:STRING=5.6.2 ^
      -D MKL_DIR:PATH=%LIBRARY_PREFIX%/lib ^
      -D LAPACK_VENDOR:STRING=MKL64 ^
      -D intsize64:BOOL=ON ^
      -D gemmt:BOOL=ON ^
      -D metis:BOOL=ON ^
      -D scotch:BOOL=ON ^
      -D openmp:BOOL=ON ^
      -D parallel:BOOL=OFF ^
      -D BUILD_SHARED_LIBS:BOOL=OFF ^
      -D BUILD_SINGLE:BOOL=ON ^
      -D BUILD_DOUBLE:BOOL=ON ^
      -D BUILD_COMPLEX:BOOL=ON ^
      -D BUILD_COMPLEX16:BOOL=ON ^
      ..

if errorlevel 1 exit 1
cmake --build . --config Release --target install

if errorlevel 1 exit 1

endlocal