@echo off

mkdir build
cd build
set MY_PY_VER=%PY_VER:.=%

set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
set FFLAGS=-fdefault-integer-8 %FFLAGS%
set MED_MEDINT_TYPE=int

if exist "%BUILD_PREFIX%\Library\mingw-w64\bin\gcc.exe" (
    echo "Mingw-w64 found"
    set CC=%BUILD_PREFIX%\Library\mingw-w64\bin\gcc.exe
    set CXX=%BUILD_PREFIX%\Library\mingw-w64\bin\g++.exe
    set FC=%BUILD_PREFIX%\Library\mingw-w64\bin\gfortran.exe
    set RC=%BUILD_PREFIX%\Library\mingw-w64\bin\windres.exe
    set F77=${FC}
)

IF "%PKG_DEBUG%"=="True" (
    echo Debugging Enabled
    REM Set compiler flags for debugging, for instance
    set CFLAGS=-g -O0 %CFLAGS%
    set CXXFLAGS=-g -O0 %CXXFLAGS%
    set FCFLAGS=-g -O0 %FCFLAGS%
    set BUILD_TYPE=Debug
    REM Additional debug build steps
) ELSE (
    set BUILD_TYPE=Release
    echo Debugging Disabled
)
set INCLUDE=%LIBRARY_PREFIX%\include;%INCLUDE%

cmake -G "Ninja" -S %SRC_DIR%^
    -Wno-dev ^
    -D CMAKE_BUILD_TYPE=%BUILD_TYPE% ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX% ^
    -D CMAKE_PREFIX_PATH:FILEPATH=%LIBRARY_PREFIX% ^
    -D CMAKE_INCLUDE_PATH:FILEPATH=%LIBRARY_PREFIX%\include ^
    -D HDF5_ROOT_DIR:FILEPATH="%LIBRARY_PREFIX%" ^
    -D HDF5_INCLUDE_DIRS:FILEPATH="%LIBRARY_PREFIX%\include" ^
    -D MEDFILE_INSTALL_DOC=OFF ^
    -D MEDFILE_BUILD_PYTHON=ON ^
    -D MEDFILE_BUILD_SHARED_LIBS=ON ^
    -D MEDFILE_BUILD_STATIC_LIBS=OFF ^
    -D MEDFILE_USE_UNICODE=OFF ^
    -D PYTHON_INCLUDE_DIR=%PREFIX%\include ^
    -D PYTHON_EXECUTABLE:FILEPATH=%PREFIX%\python.exe ^
    -D PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib ^
    -D SIZEOF_LONG_LONG=8

if errorlevel 1 exit 1
ninja
if errorlevel 1 exit 1
ninja install

REM DEL /q %PREFIX%\bin\mdump %PREFIX%\bin\xmdump
COPY /y %LIBRARY_PREFIX%\bin\mdump4.exe %LIBRARY_PREFIX%\bin\mdump.exe
COPY /y %LIBRARY_PREFIX%\bin\xmdump4.exe %LIBRARY_PREFIX%\bin\xmdump.exe
MKDIR %SP_DIR%\med
MOVE %LIBRARY_PREFIX%\lib\python%PY_VER%\site-packages\med %SP_DIR%\med
MOVE %LIBRARY_PREFIX%\lib\libmedC.* %LIBRARY_PREFIX%\bin\