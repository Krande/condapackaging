mkdir build
cd build

:: Set environment variables.
set HDF5_EXT_ZLIB=zlib.lib

set "CXXFLAGS=%CXXFLAGS% -LTCG"
:: strip all FCFLAGS
::set FCFLAGS=""
echo "CMAKE_PREFIX_PATH: %LIBRARY_PREFIX%"

:: Use CMake to configure
cmake ^
  -G "Ninja" ^
  -Wno-strict-overflow ^
  -D CMAKE_BUILD_TYPE:STRING=RELEASE ^
  -D CMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
  -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
  -D HDF5_BUILD_CPP_LIB:BOOL=ON ^
  -D ALLOW_UNSUPPORTED:BOOL=ON ^
  -D HDF5_BUILD_FORTRAN=ON ^
  -D HDF5_ENABLE_THREADSAFE=OFF ^
  -D BUILD_SHARED_LIBS:BOOL=ON ^
  -D ONLY_SHARED_LIBS:BOOL=ON ^
  -D BUILD_STATIC_LIBS:BOOL=OFF ^
  %SRC_DIR%

:: Build and install
ninja install


