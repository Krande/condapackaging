@echo off

mkdir "%SRC_DIR%\deps\config"

:: Specify the full path to your tar executable if it's not in the PATH
tar -xzvf "%SRC_DIR%\deps\archives\med-4.1.1.tar.gz" --strip-components=1

::set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
::set FFLAGS=-fdefault-integer-8 %FFLAGS%

:: GCC
::set CMAKE_C_COMPILER=%PREFIX%\mingw-w64\bin\gcc.exe
::set CMAKE_CXX_COMPILER=%PREFIX%\mingw-w64\bin\g++.exe
set CMAKE_CXX_COMPILER=%PREFIX%\mingw-w64\bin\gfortran.exe

:: FLANG
@REM set CMAKE_Fortran_COMPILER=%LIBRARY_PREFIX%\bin\flang.exe
@REM set FC=%LIBRARY_PREFIX%\bin\flang.exe

echo "CC=%CC%"
echo "CXX=%CXX%"
echo "FC=%FC%"

cmake -G "Ninja" -S .^
      -Wno-dev ^
      -D MED_MEDINT_TYPE:STRING=long ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D "CMAKE_PREFIX_PATH:FILEPATH=%PREFIX%" ^
      -D "CMAKE_INSTALL_PREFIX:FILEPATH=%PREFIX%" ^
      -D "HDF5_ROOT_DIR:FILEPATH=%LIBRARY_PREFIX%/lib" ^
      -D MEDFILE_INSTALL_DOC=OFF ^
      -D MEDFILE_BUILD_PYTHON=ON ^
      -D "PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib" ^
      -D "PYTHON_INCLUDE_DIR:FILEPATH=%PREFIX%\include"

if errorlevel 1 exit 1
ninja
if errorlevel 1 exit 1
ninja install

rem DEL /q %PREFIX%\bin\mdump %PREFIX%\bin\xmdump
rem COPY /y %PREFIX%\bin\mdump4 %PREFIX%\bin\mdump
rem COPY /y %PREFIX%\bin\xmdump4 %PREFIX%\bin\xmdump
rem MKDIR %SP_DIR%\med
rem MOVE %PREFIX%\lib\python%PY_VER%\site-packages\med %SP_DIR%\med
rem MOVE %PREFIX%\lib\medC.* %LIBRARY_BIN%


REM ninja test
REM if errorlevel 1 exit 1

REM move %LIBRARY_PREFIX%\lib\medC.dll %LIBRARY_PREFIX%\bin
REM move %LIBRARY_PREFIX%\lib\medimport.dll %LIBRARY_PREFIX%\bin