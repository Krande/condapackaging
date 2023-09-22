mkdir build
cd build

:: Set environment variables.
set HDF5_EXT_ZLIB=zlib.lib

set "CXXFLAGS=%CXXFLAGS% -LTCG"

:: will have to remove the VS flags from FCFLAGS given that we are using flang
set FCFLAGS=-fdefault-integer-8
set FFLAGS=-fdefault-integer-8

echo "CMAKE_PREFIX_PATH: %LIBRARY_PREFIX%"
if exist "%BUILD_PREFIX%\Library\bin\flang-new.exe" (
    echo "Flang NEW found"

    set CC=%BUILD_PREFIX%\Library\bin\clang-cl.exe
    set CXX=%BUILD_PREFIX%\Library\bin\clang-cl.exe
    set FC=%BUILD_PREFIX%\Library\bin\flang-new.exe
)
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


