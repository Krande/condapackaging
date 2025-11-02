@echo off

setlocal enabledelayedexpansion

mkdir build
cd build

set CFLAGS=%CFLAGS% /nologo

set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    rem Embed debug info in .obj to avoid external PDB requirements (/Z7 instead of /Zi)
    set CFLAGS=%CFLAGS% /Od /Z7
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)
echo "Build type: %TGT_BUILD_TYPE%, INT_TYPE: %int_type%"

cmake ^
    -G "Ninja" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D CMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE=%TGT_BUILD_TYPE% ^
    -D CMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
    -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON ^
    -D BUILD_TESTING:BOOL=ON ^
    -D BUILD_SHARED_LIBS=OFF ^
    -D CMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded ^
    -D intsize=%int_type% ^
    -D realsize=%int_type% ^
    ..

if errorlevel 1 exit 1

ninja

if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1
