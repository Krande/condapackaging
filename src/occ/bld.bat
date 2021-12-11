set occt_v=7_5_1
set OCC_DIR=occt-V%occt_v%
if not exist %OCC_DIR%\ (
    call download.bat
) || goto :EOF

cd %OCC_DIR%

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_MODULE_Draw=0 -DBUILD_MODULE_Visualization=0 -DBUILD_MODULE_ApplicationFramework=0 ..

:: # Notes:
:: # * if you installed dependencies (e.g. Freetype) in non-standard locations, add the option -DCMAKE_PREFIX_PATH=path-of-installed-dependencies
:: # * if you don't have root access, add -DCMAKE_INSTALL_PREFIX=path-to-install
:: # * to build static libraries, add -DBUILD_LIBRARY_TYPE=Static
call build.bat
call install.bat
:: # Notes:
:: # * if you don't have root access, remove "sudo"
::