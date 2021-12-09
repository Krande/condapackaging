set occt_v=7_6_0
curl -L -o occt.tgz "http://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V%occt_v%;sf=tgz"
tar zxf occt.tgz
cd occt-V%occt_v%

mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_MODULE_Draw=0 -DBUILD_MODULE_Visualization=0 -DBUILD_MODULE_ApplicationFramework=0 ..

:: # Notes:
:: # * if you installed dependencies (e.g. Freetype) in non-standard locations, add the option -DCMAKE_PREFIX_PATH=path-of-installed-dependencies
:: # * if you don't have root access, add -DCMAKE_INSTALL_PREFIX=path-to-install
:: # * to build static libraries, add -DBUILD_LIBRARY_TYPE=Static
:: make
:: sudo make install
:: # Notes:
:: # * if you don't have root access, remove "sudo"
::