mkdir build
cd build
set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /Od /Zi -DSWIG_PYTHON_INTERPRETER_NO_DEBUG=1
    set CXXFLAGS=%CFLAGS% /Od /Zi -DSWIG_PYTHON_INTERPRETER_NO_DEBUG=1
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)
cmake -G "Ninja" ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_BUILD_TYPE:STRING=%TGT_BUILD_TYPE% ^
    -D Python3_FIND_STRATEGY:STRING=LOCATION ^
    -D Python3_FIND_REGISTRY:STRING=NEVER ^
    -D SWIG_HIDE_WARNINGS:BOOL=ON ^
    -D PYTHONOCC_MESHDS_NUMPY=ON ^
    ..

if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
