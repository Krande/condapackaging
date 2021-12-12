if not exist ..\gmsh\ (
    call ..\download.bat
) || goto :EOF

:: Needed so we can find stdint.h from msinttypes.
set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

cd %cd%
mkdir build
cd build

cmake -G "Ninja" ^
    -D ENABLE_OPENMP=0 ^
    -D ENABLE_OS_SPECIFIC_INSTALL=OFF ^
    -D ENABLE_BUILD_DYNAMIC=ON ^
    -D ENABLE_HXT=1 ^
    -D GMSH_RELEASE=1 ^
    ..\..\gmsh

if errorlevel 1 exit 1

set CL=/MP

:: Build.
ninja
if errorlevel 1 exit 1

:: Test.
:: ctest
:: if errorlevel 1 exit 1

:: Install.
ninja install
if errorlevel 1 exit 1
