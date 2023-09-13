mkdir build
cd build

REM Configure step
cmake -G "Ninja" ^
    -Wno-dev ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -D PYTHONOCC_BUILD_TYPE:STRING=Release ^
    -D Python3_FIND_STRATEGY:STRING=LOCATION ^
    -D Python3_FIND_REGISTRY:STRING=NEVER ^
    -D SWIG_HIDE_WARNINGS:BOOL=ON ^
    -D PYTHONOCC_MESHDS_NUMPY=ON ^
    ..

if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1