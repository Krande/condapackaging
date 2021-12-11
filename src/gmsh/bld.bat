if not exist gmsh\ (
    call download.bat
) || goto :EOF
git checkout e7dcf42f7218d1cddfbd03fe95321b9b56c5d08c

cd gmsh
mkdir build

cd build
cmake -G "Visual Studio 15 2017 Win64" ..

:: Notes:
:: * if you installed dependencies (e.g. OpenCASCADE and FLTK) in non-standard locations, add the option -DCMAKE_PREFIX_PATH=path-of-installed-dependencies
:: * to build the Gmsh app as well as the dynamic Gmsh library (to develop e.g. using the C++ or the Python Gmsh API), add the option -DENABLE_BUILD_DYNAMIC=1
:: * for a list of all available configuration options see http://gmsh.info/doc/texinfo/gmsh.html::Compiling-the-source-code
..\..\..\msbuild64.cmd package.vcxproj

