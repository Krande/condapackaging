if not exist fltk\ (
    call download.bat
) || goto :EOF

cd fltk
mkdir build
cd build

:: Notes:
:: * by default FLTK is compiled as a static library, which has been reported to cause
:: issues with OpenGL libraries
:: __ on some systems; to build a shared library, add -DOPTION_BUILD_SHARED_LIBS=ON
:: * if you don't have root access, add -DCMAKE_INSTALL_PREFIX=path-to-install
cmake -G "Ninja" ^
 -D CMAKE_POSITION_INDEPENDENT_CODE=ON ^
 -D OPTION_BUILD_SHARED_LIBS=ON ^
 ..
if errorlevel 1 exit 1

:: Build.
ninja install
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Notes:
:: * if you don't have root access, remove "sudo"
