if not exist fltk\ (
    call download.bat
) || goto :EOF
cd fltk
mkdir build
cd build
:: Notes:
:: * by default FLTK is compiled as a static library, which has been reported to cause issues with OpenGL libraries on some systems; to build a shared library, add -DOPTION_BUILD_SHARED_LIBS=ON
:: * if you don't have root access, add -DCMAKE_INSTALL_PREFIX=path-to-install
cmake -DCMAKE_POSITION_INDEPENDENT_CODE=ON ..
make
make install
:: Notes:
:: * if you don't have root access, remove "sudo"
