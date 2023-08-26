@echo off

mkdir "%SRC_DIR%\deps\config"

:: Specify the full path to your tar executable if it's not in the PATH
tar -xzvf "%SRC_DIR%\deps\archives\med-4.1.1.tar.gz" --strip-components=1
:: 7z x "%SRC_DIR%\deps\archives\med-4.1.1.tar.gz" -so | 7z x -si -ttar -o.

:: set FCFLAGS=-fdefault-integer-8 %FCFLAGS%
:: set FFLAGS=-fdefault-integer-8 %FFLAGS%
:: set MED_MEDINT_TYPE=long

:: GCC
for /f "delims=" %%i in ('where gfortran.exe') do set GF_PATH=%%i
for /f "delims=" %%i in ('where gcc.exe') do set CC_PATH=%%i
for /f "delims=" %%i in ('where g++.exe') do set CXX_PATH=%%i

set CC=%CC_PATH%
set CXX=%CXX_PATH%
set FC=%GF_PATH%

:: FLANG
if exist %BUILD_PREFIX%\Library\bin\flang.exe (
    echo "FLANG found"
    for /f "delims=" %%i in ('where flang.exe') do set GF_PATH=%%i
    for /f "delims=" %%i in ('where clang.exe') do set CC_PATH=%%i
    for /f "delims=" %%i in ('where clang++.exe') do set CXX_PATH=%%i
    echo "GF_PATH=%GF_PATH%"
    echo "CC_PATH=%CC_PATH%"
    echo "CXX_PATH=%CXX_PATH%"

    set CC=%BUILD_PREFIX%\Library\bin\clang.exe
    set CXX=%BUILD_PREFIX%\Library\bin\clang++.exe
    set FC=%BUILD_PREFIX%\Library\bin\flang.exe
)

echo "CC=%CC%"
echo "CXX=%CXX%"
echo "FC=%FC%"

set CMAKE_C_COMPILER=%CC%
set CMAKE_CXX_COMPILER=%CXX%
set CMAKE_Fortran_COMPILER=%FC%

cmake -G "Ninja" -S .^
    -Wno-dev ^
    -D CMAKE_C_COMPILER:FILEPATH=%CMAKE_C_COMPILER% ^
    -D CMAKE_CXX_COMPILER:FILEPATH=%CMAKE_CXX_COMPILER% ^
    -D CMAKE_Fortran_COMPILER:FILEPATH=%CMAKE_Fortran_COMPILER% ^
    -D CMAKE_C_COMPILER:FILEPATH=%CMAKE_C_COMPILER% ^
    -D CMAKE_CXX_COMPILER:FILEPATH=%CMAKE_CXX_COMPILER% ^
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