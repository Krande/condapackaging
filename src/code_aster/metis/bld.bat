@echo off

mkdir build
cd build

if "%PKG_DEBUG%" == "True" (
    set CMAKE_BUILD_TYPE=Debug
) else (
    set CMAKE_BUILD_TYPE=Release
)

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
    -DSHARED=ON ^
    -Dintsize=64 ^
    -Drealsize=64 ^
    ..

if errorlevel 1 exit 1

ninja

if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1
