:: Needed so we can find stdint.h from msinttypes.
set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

mkdir build
cd build

:: Configure.
cmake -G "Visual Studio 16 2019" ^
    -D CMAKE_INSTALL_PREFIX=%PREFIX% ^
    -D CMAKE_PREFIX_PATH=%PREFIX% ^
    -D ENABLE_BUILD_DYNAMIC=1 ^
    -D ENABLE_HXT=1 ^
    -D ENABLE_PETSC=1 ^
    -D INSTALL_SDK_README=1 ^
    -D ENABLE_OPENMP=0 ^
    -D GMSH_RELEASE=1 ^
    ..

if errorlevel 1 exit 1

:: Build.
"C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe" package.vcxproj
if errorlevel 1 exit 1

:: Test.
:: ctest
:: if errorlevel 1 exit 1

:: Install.
make install
if errorlevel 1 exit 1

mkdir %SP_DIR%
cp api\gmsh.py %SP_DIR%\gmsh.py

rm %LIBRARY_PREFIX%\lib\gmsh.py
move %LIBRARY_PREFIX%\lib\gmsh.dll %LIBRARY_PREFIX%\bin\
