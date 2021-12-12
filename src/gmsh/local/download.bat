cd %0\..
git clone http://gitlab.onelab.info/gmsh/gmsh.git

cd gmsh

git checkout e7dcf42f7218d1cddfbd03fe95321b9b56c5d08c

git apply ../patches/occ_convert_signal.patch
git apply ../patches/fltk_nominmax.patch
git apply ../patches/disable_wmain.patch