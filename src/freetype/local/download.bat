curl -LO http://download.savannah.gnu.org/releases/freetype/freetype-2.8.tar.gz
tar zxvf freetype-2.8.tar.gz

cd freetype-2.8
git apply ../patches/0003-Install-the-pkg-config-file-on-Windows-too.patch