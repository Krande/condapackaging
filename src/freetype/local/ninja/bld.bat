
if not exist ..\freetype-2.8\ (
    call download.bat
) || goto :EOF

set CXXFLAGS=
set CFLAGS=

cd %cd%

mkdir build
cd build

cmake -G "Ninja" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX:/=\\%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%:/=\\" ^
      -DCMAKE_SYSTEM_PREFIX_PATH="%LIBRARY_PREFIX:/=\\%" ^
      -DBUILD_SHARED_LIBS:BOOL=false ^
      -DFT_WITH_BZIP2=False ^
      -DFT_WITH_HARFBUZZ=False ^
      -DCMAKE_DISABLE_FIND_PACKAGE_BZip2=True ^
      -DCMAKE_DISABLE_FIND_PACKAGE_HarfBuzz=True ^
      -DFT_WITH_ZLIB=True ^
      -DFT_WITH_PNG=True ^
      ..
if errorlevel 1 exit 1

:: Build.
ninja install
if errorlevel 1 exit 1

:: Test.
ctest -C Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
