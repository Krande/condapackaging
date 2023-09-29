@echo off
setlocal enabledelayedexpansion

mkdir build
cd build
:: if "%CXX%" == "cl.exe" (
::     set "CXXFLAGS=%CXXFLAGS% -LTCG"
:: )

:: Set environment variables.
set HDF5_EXT_ZLIB=zlib.lib

echo "ONEAPI_ROOT=%ONEAPI_ROOT%"
:: run the setvars.bat for oneAPI to initialize the necessary env variables
call "%ONEAPI_ROOT%\setvars.bat"

echo "IFORT_COMPILER23=%IFORT_COMPILER23%"

set "LONG_PATH=%IFORT_COMPILER23%"
for %%A in ("!LONG_PATH!") do set "SHORT_PATH=%%~sA"

echo Long Path:  !LONG_PATH!
echo Short Path: !SHORT_PATH!

set FC=!SHORT_PATH!bin\intel64\ifx.exe


echo CC=%CC%
echo CXX=%CXX%
echo FC=%FC%
echo FCFLAGS=%FCFLAGS%
echo CXXFLAGS=%CXXFLAGS%

:: Configure step.
cmake -G "Ninja" ^
      -Wno-dev ^
      -D CMAKE_BUILD_TYPE:STRING=RELEASE ^
      -D CMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D HDF5_BUILD_CPP_LIB:BOOL=ON ^
      -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON ^
      -D BUILD_SHARED_LIBS:BOOL=ON ^
      -D BUILD_STATIC_LIBS:BOOL=OFF ^
      -D ONLY_SHARED_LIBS:BOOL=ON ^
      -D HDF5_BUILD_HL_LIB:BOOL=ON ^
      -D BUILD_TESTING:BOOL=ON ^
      -D HDF5_BUILD_TOOLS:BOOL=ON ^
      -D HDF5_BUILD_DOC:BOOL=OFF ^
      -D HDF5_ENABLE_THREADSAFE:BOOL=OFF ^
      -D ALLOW_UNSUPPORTED:BOOL=ON ^
      -D HDF5_BUILD_FORTRAN=ON ^
      ..

if errorlevel 1 exit 1

:: Build C libraries and tools.
ninja
if errorlevel 1 exit 1

:: Install step.
ninja install
if errorlevel 1 exit 1

:: Remove extraneous COPYING file that gets installed automatically
:: https://github.com/conda-forge/hdf5-feedstock/issues/87
del /f %PREFIX%\Library\COPYING
if errorlevel 1 exit 1
del /f %PREFIX%\Library\RELEASE.txt
if errorlevel 1 exit 1


:: The CMake Build process adds a -shared at the end of every exe when you don't
:: build the static libraries.
:: We copy the shared executables to a name withtout the -shared prefix to ensure
:: they are found by programs that expect them in the standard location
:: We cannot move the files since the generated CMake files from HDF5 still
:: expect them to exists with the -shared suffix
:: https://github.com/conda-forge/hdf5-feedstock/pull/188
echo Copying %LIBRARY_PREFIX%\bin\h5repart-shared.exe %LIBRARY_PREFIX%\bin\h5repart.exe
copy %LIBRARY_PREFIX%\bin\h5repart-shared.exe %LIBRARY_PREFIX%\bin\h5repart.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5debug-shared.exe %LIBRARY_PREFIX%\bin\h5debug.exe
copy %LIBRARY_PREFIX%\bin\h5debug-shared.exe %LIBRARY_PREFIX%\bin\h5debug.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5jam-shared.exe %LIBRARY_PREFIX%\bin\h5jam.exe
copy %LIBRARY_PREFIX%\bin\h5jam-shared.exe %LIBRARY_PREFIX%\bin\h5jam.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5unjam-shared.exe %LIBRARY_PREFIX%\bin\h5unjam.exe
copy %LIBRARY_PREFIX%\bin\h5unjam-shared.exe %LIBRARY_PREFIX%\bin\h5unjam.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5clear-shared.exe %LIBRARY_PREFIX%\bin\h5clear.exe
copy %LIBRARY_PREFIX%\bin\h5clear-shared.exe %LIBRARY_PREFIX%\bin\h5clear.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h52gif-shared.exe %LIBRARY_PREFIX%\bin\h52gif.exe
copy %LIBRARY_PREFIX%\bin\h52gif-shared.exe %LIBRARY_PREFIX%\bin\h52gif.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5mkgrp-shared.exe %LIBRARY_PREFIX%\bin\h5mkgrp.exe
copy %LIBRARY_PREFIX%\bin\h5mkgrp-shared.exe %LIBRARY_PREFIX%\bin\h5mkgrp.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5format_convert-shared.exe %LIBRARY_PREFIX%\bin\h5format_convert.exe
copy %LIBRARY_PREFIX%\bin\h5format_convert-shared.exe %LIBRARY_PREFIX%\bin\h5format_convert.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\gif2h5-shared.exe %LIBRARY_PREFIX%\bin\gif2h5.exe
copy %LIBRARY_PREFIX%\bin\gif2h5-shared.exe %LIBRARY_PREFIX%\bin\gif2h5.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5copy-shared.exe %LIBRARY_PREFIX%\bin\h5copy.exe
copy %LIBRARY_PREFIX%\bin\h5copy-shared.exe %LIBRARY_PREFIX%\bin\h5copy.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5stat-shared.exe %LIBRARY_PREFIX%\bin\h5stat.exe
copy %LIBRARY_PREFIX%\bin\h5stat-shared.exe %LIBRARY_PREFIX%\bin\h5stat.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5import-shared.exe %LIBRARY_PREFIX%\bin\h5import.exe
copy %LIBRARY_PREFIX%\bin\h5import-shared.exe %LIBRARY_PREFIX%\bin\h5import.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5watch-shared.exe %LIBRARY_PREFIX%\bin\h5watch.exe
copy %LIBRARY_PREFIX%\bin\h5watch-shared.exe %LIBRARY_PREFIX%\bin\h5watch.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5diff-shared.exe %LIBRARY_PREFIX%\bin\h5diff.exe
copy %LIBRARY_PREFIX%\bin\h5diff-shared.exe %LIBRARY_PREFIX%\bin\h5diff.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5repack-shared.exe %LIBRARY_PREFIX%\bin\h5repack.exe
copy %LIBRARY_PREFIX%\bin\h5repack-shared.exe %LIBRARY_PREFIX%\bin\h5repack.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5ls-shared.exe %LIBRARY_PREFIX%\bin\h5ls.exe
copy %LIBRARY_PREFIX%\bin\h5ls-shared.exe %LIBRARY_PREFIX%\bin\h5ls.exe
if errorlevel 1 exit 1

echo Copying %LIBRARY_PREFIX%\bin\h5dump-shared.exe %LIBRARY_PREFIX%\bin\h5dump.exe
copy %LIBRARY_PREFIX%\bin\h5dump-shared.exe %LIBRARY_PREFIX%\bin\h5dump.exe
if errorlevel 1 exit 1
