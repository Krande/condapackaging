@echo off

mkdir "%SRC_DIR%\deps\config"
tar -xzvf "%SRC_DIR%\deps\archives\med-4.1.1.tar.gz" -C . --strip-components=1

set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
set FFLAGS=-fdefault-integer-8 %FFLAGS%

set CMAKE_C_COMPILER=%PREFIX%\mingw-w64\bin\gcc.exe
set CMAKE_CXX_COMPILER=%PREFIX%\mingw-w64\bin\g++.exe
set CMAKE_Fortran_COMPILER=%PREFIX%\mingw-w64\bin\gfortran.exe

cmake -G "Ninja" ^
      -Wno-dev ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D "CMAKE_PREFIX_PATH:FILEPATH=%PREFIX%" ^
      -D "CMAKE_INSTALL_PREFIX:FILEPATH=%PREFIX%" ^
      -D "HDF5_ROOT_DIR:FILEPATH=%LIBRARY_PREFIX%" ^
      -D MEDFILE_INSTALL_DOC=OFF ^
      -D MEDFILE_BUILD_PYTHON=ON ^
      -D "PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib" ^
      -D "PYTHON_INCLUDE_DIR:FILEPATH=%PREFIX%\include" -S . -B build

if errorlevel 1 exit 1
cmake --build .\build --config Release
if errorlevel 1 exit 1
cmake --install .\build

DEL /q %PREFIX%\bin\mdump %PREFIX%\bin\xmdump
COPY /y %PREFIX%\bin\mdump4 %PREFIX%\bin\mdump
COPY /y %PREFIX%\bin\xmdump4 %PREFIX%\bin\xmdump
MKDIR %SP_DIR%\med
MOVE %PREFIX%\lib\python%PY_VER%\site-packages\med %SP_DIR%\med
MOVE %PREFIX%\lib\medC.* %LIBRARY_BIN%


REM ninja test
REM if errorlevel 1 exit 1

REM move %LIBRARY_PREFIX%\lib\medC.dll %LIBRARY_PREFIX%\bin
REM move %LIBRARY_PREFIX%\lib\medimport.dll %LIBRARY_PREFIX%\bin