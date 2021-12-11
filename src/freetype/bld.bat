if not exist freetype-2.8\ (
    call download.bat
) || goto :EOF

cd freetype-2.8
./configure
:: Notes:
:: * if you don't have root access, add --prefix==path-to-install
make
make install
:: Notes:
:: * if you don't have root access, remove "sudo"
