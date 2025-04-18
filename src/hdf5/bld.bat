@echo off

setlocal ENABLEDELAYEDEXPANSION

mkdir build
cd build

:: set FC=flang-new

:: Set environment variables.
set HDF5_EXT_ZLIB=zlib.lib

set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=RelWithDebInfo
    set CFLAGS=%CFLAGS% /Od /Zi
    set CXXFLAGS=%CFLAGS% /Od /Zi
    set FCFLAGS=%FCFLAGS% /Od /debug /Zi /traceback
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

set FFLAGS=%FCFLAGS% /fpp /MD
set "LIB=%BUILD_PREFIX%\Library\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\opt\compiler\include\intel64;%INCLUDE%"

echo "FFLAGS: %FFLAGS%"
echo "CFLAGS: %CFLAGS%"

:: Configure step.
cmake -G "Ninja" ^
      -D CMAKE_BUILD_TYPE:STRING=%TGT_BUILD_TYPE% ^
      -D CMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D HDF5_BUILD_CPP_LIB:BOOL=ON ^
      -D CMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON ^
      -D BUILD_SHARED_LIBS:BOOL=ON ^
      -D BUILD_STATIC_LIBS:BOOL=OFF ^
      -D ONLY_SHARED_LIBS:BOOL=ON ^
      -D HDF5_BUILD_HL_LIB:BOOL=ON ^
      -D HDF5_BUILD_TOOLS:BOOL=ON ^
      -D HDF5_BUILD_FORTRAN:BOOL=ON ^
      -D HDF5_BUILD_HL_GIF_TOOLS:BOOL=ON ^
      -D HDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON ^
      -D HDF5_ENABLE_THREADSAFE:BOOL=ON ^
      -D HDF5_ENABLE_ROS3_VFD:BOOL=ON ^
      -D HDF5_ENABLE_SZIP_SUPPORT=ON ^
      -D ALLOW_UNSUPPORTED:BOOL=ON ^
      -D BUILD_TESTING:BOOL=OFF ^
      -D HDF5_BUILD_EXAMPLES:BOOL=OFF ^
      %SRC_DIR%

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

endlocal