if not exist gmsh\ (
    call download.bat
) || goto :EOF

cd gmsh

git checkout e7dcf42f7218d1cddfbd03fe95321b9b56c5d08c
git apply ../patches/occ_convert_signal.patch
git apply ../patches/fltk_nominmax.patch
git apply ../patches/disable_wmain.patch

mkdir build
cd build

cmake -G "NMake Makefiles" ^
    -D ENABLE_OPENMP=0 ^
    -D ENABLE_BUILD_DYNAMIC=ON ^
    -D ENABLE_HXT=1 ^
    -D GMSH_RELEASE=1 ^
    ..

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
