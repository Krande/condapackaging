@echo off

mkdir build
cd build

set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /Od /Z7
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

cmake ^
    -G "Ninja" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=%TGT_BUILD_TYPE% ^
    -D SHARED=ON ^
    -D intsize=64 ^
    -D realsize=64 ^
    ..

if errorlevel 1 exit 1

ninja

if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1
