@echo off

setlocal enabledelayedexpansion

set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data\

:: MSVC is preferred.
set CC=clang-cl.exe
set CXX=clang-cl.exe
@REM set FC=flang-new
:: Needed by IFX
set "LIB=%BUILD_PREFIX%\Library\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\opt\compiler\include\intel64;%INCLUDE%"
set "CMAKE_ARGS=!CMAKE_ARGS! -D HDF5_BUILD_FORTRAN:BOOL=ON"

set TGT_BUILD_TYPE=Release
set CMAKE_DEBUG_INFO_FORMAT=
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    if "%FC%" == "flang-new" (
        set FCFLAGS=%FCFLAGS% -g -cpp
    ) else (
        rem Embed debug info in .obj to avoid external PDB requirements (/Z7 instead of /Zi)
        set FCFLAGS=%FCFLAGS% /Od /debug /Z7 /traceback
    )
    set CFLAGS=%CFLAGS% /Od /Z7
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
    set CMAKE_DEBUG_INFO_FORMAT=-D CMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded
)

set CFLAGS=%CFLAGS% /nologo
if "%FC%" == "flang-new" (
    set FCFLAGS=%FCFLAGS% -cpp
    if "%int_type%" == "64" (
        set FCFLAGS=%FCFLAGS% -fdefault-real-8
    )
) else (
    set FCFLAGS=%FCFLAGS% /nologo /fpp /TP
    if "%int_type%" == "64" (
        set FCFLAGS=%FCFLAGS% /integer-size:64 /4I8
    )
)

echo "Build type: %TGT_BUILD_TYPE%, INT_TYPE: %int_type%"
echo "CFLAGS: %CFLAGS%"
echo "FCFLAGS: %FCFLAGS%"
echo "LDFLAGS: %LDFLAGS%"

cmake ^
  -G "Ninja" ^
  -D CMAKE_BUILD_TYPE=%TGT_BUILD_TYPE% ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D SCOTCH_METIS_PREFIX=ON ^
  -D BUILD_SHARED_LIBS=OFF ^
  -D INTSIZE=%int_type% ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  %CMAKE_DEBUG_INFO_FORMAT% ^
  -D MPI_THREAD_MULTIPLE=%USE_MPI% ^
  -D BUILD_PTSCOTCH=%USE_MPI% ^
  -B build ^
  %SRC_DIR%

if errorlevel 1 exit 1

cmake --build ./build --config %TGT_BUILD_TYPE%
if errorlevel 1 exit 1
cmake --install ./build --component=libscotch
if errorlevel 1 exit 1
