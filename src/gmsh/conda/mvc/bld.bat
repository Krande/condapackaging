:: Needed so we can find stdint.h from msinttypes.
set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

mkdir build
cd build

:: Configure.
cmake -G "Ninja" ^
    -D ENABLE_OPENMP=0 ^
    -D GMSH_HOST=gmsh.info ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D ENABLE_OS_SPECIFIC_INSTALL=0 ^
    -D ENABLE_BUILD_DYNAMIC=1 ^
    -D ENABLE_HXT=1 ^
    -D GMSH_RELEASE=1 ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
ninja
if errorlevel 1 exit 1

:: Test.
:: ctest
:: if errorlevel 1 exit 1

:: Install.
ninja install
if errorlevel 1 exit 1

python3 setup-wheel.py build bdist_wheel --plat-name win_amd64 --universal

mkdir -p %SP_DIR%\gmsh
move %LIBRARY_PREFIX%\lib\gmsh.py %SP_DIR%\gmsh\__init__.py
move %LIBRARY_PREFIX%\lib\gmsh.dll %LIBRARY_PREFIX%\bin\