@echo off
setlocal

set CLICOLOR_FORCE=1

mkdir build
cd build

rem Set TFELHOME to the PREFIX environment variable
set TFELHOME=%PREFIX%
set python_version=%CONDA_PY:~0,1%.%CONDA_PY:~1,2%

if "%PKG_DEBUG%"=="True" (
  echo Debugging Enabled
  set CFLAGS=-g -O0 %CFLAGS%
  set CXXFLAGS=-g -O0 %CXXFLAGS%
  set FCFLAGS=-g -O0 %FCFLAGS%
  set build_type=Debug
) else (
  set build_type=Release
  echo Debugging Disabled
)

cmake .. ^
    -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=%build_type% ^
    -Denable-c-bindings=OFF ^
    -Denable-fortran-bindings=OFF ^
    -Denable-python-bindings=ON ^
    -Denable-portable-build=ON ^
    -Denable-julia-bindings=OFF ^
    -Denable-website=OFF ^
    -Denable-broken-boost-python-module-visibility-handling=ON ^
    -DPYTHONLIBS_VERSION_STRING="%CONDA_PY%" ^
    -DPython_ADDITIONAL_VERSIONS="%python_version%" ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PREFIX%/python.exe" ^
    -DPYTHON_LIBRARY:FILEPATH="%PREFIX%/libs/python%python_version%.lib" ^
    -DPYTHON_LIBRARY_PATH:PATH="%PREFIX%/libs" ^
    -DPYTHON_INCLUDE_DIRS:PATH="%PREFIX%/include" ^
    -DUSE_EXTERNAL_COMPILER_FLAGS=ON ^
    -DCMAKE_INSTALL_PREFIX:PATH="%PREFIX%"

nmake
nmake install

endlocal
