if not exist ..\gmsh\ (
    call ..\download.bat
) || goto :EOF

cd %cd%

set LIBRARY_PREFIX=%cd%/output

mkdir build
cd build

cmake -G "NMake Makefiles" ^
    -D ENABLE_OPENMP=0 ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D ENABLE_BUILD_DYNAMIC=ON ^
    -D ENABLE_HXT=1 ^
    -D GMSH_RELEASE=1 ^
    ..\..\gmsh

if errorlevel 1 exit 1

set CL=/MP

:: Build.
nmake package
if errorlevel 1 exit 1

:: Test.
:: ctest
:: if errorlevel 1 exit 1

:: Install.
nmake install
if errorlevel 1 exit 1
