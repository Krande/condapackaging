@echo off

mkdir build
cd build

set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /nologo /Od /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

cmake ^
    -G "Ninja" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=%TGT_BUILD_TYPE% ^
    -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
    -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON ^
    -D BUILD_TESTING:BOOL=ON ^
    -D BUILD_SHARED_LIBS=OFF ^
    -D intsize=64 ^
    -D realsize=64 ^
    ..

if errorlevel 1 exit 1

ninja

if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1
