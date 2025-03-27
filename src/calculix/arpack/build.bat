set CC=clang-cl
set CXX=clang-cl

if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
)
set "CFLAGS= -fcomplex-arithmetic %CFLAGS%"
mkdir build && cd build

::  Shared build - configure.
cmake -G "Ninja" ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX:\=/% ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX:\=/% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DICB=ON ^
  ..
if errorlevel 1 exit 1

:: Build.
ninja install -j %CPU_COUNT%
if errorlevel 1 exit 1
