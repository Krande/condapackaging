# Gmsh Compilation Study

* https://gitlab.onelab.info/gmsh/gmsh/-/wikis/Gmsh-compilation


## Windows

### Using Ninja

### Using NMake

### Using Cygwin
Requires the re-compilation of `occt` (opencascade) using mingw64_x86_64-gcc-g++

### Making a Python package out of it

**hints**
- GMSH_SETUP_DIR=../utils/pypi/gmsh 
- GMSH_SDK_DIR=_CPack_Packages/CYGWIN/ZIP/gmsh-${VERSION}-Windows64-sdk/ 
- python3 setup-wheel.py build bdist_wheel --plat-name win_amd64 --universal
