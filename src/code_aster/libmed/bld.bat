@echo OFF

setlocal ENABLEDELAYEDEXPANSION

mkdir build
cd build
:: LLVM Flang support will have to be patched into libmed source code
:: set FC=flang-new

if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
)

set BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set CFLAGS=%CFLAGS% /Od /Zi
    if "%FC%" == "flang-new" (
        set FFLAGS=%FFLAGS% -g -cpp
    ) else (
        set FFLAGS=%FFLAGS% /Od /Zi
    )
)

:: This updates the symbols to lowercase and adds an underscore
xcopy %RECIPE_DIR%\medfwrap_symbols.def %SRC_DIR%\src\medfwrap_symbols.def.in /Y

set FFLAGS=%FFLAGS% /nologo /fpp /fixed /dll /MD /real-size:64 /integer-size:64

set CFLAGS=%CFLAGS%

cmake -G "Ninja" ^
  %CMAKE_ARGS% ^
  -D CMAKE_BUILD_TYPE="%BUILD_TYPE%" ^
  -D Python_FIND_STRATEGY:STRING=LOCATION ^
  -D Python_FIND_REGISTRY:STRING=NEVER ^
  -D Python3_ROOT_DIR:FILEPATH="%PREFIX%" ^
  -D HDF5_ROOT_DIR:FILEPATH="%LIBRARY_PREFIX%" ^
  -D MEDFILE_INSTALL_DOC=OFF ^
  -D MEDFILE_BUILD_PYTHON=ON ^
  -D MEDFILE_BUILD_TESTS=OFF ^
  -D MEDFILE_BUILD_SHARED_LIBS=ON ^
  -D MEDFILE_BUILD_STATIC_LIBS=OFF ^
  -D MEDFILE_USE_UNICODE=OFF ^
  -D MED_MEDINT_TYPE="long long" ^
  -Wno-dev ^
  ..

if errorlevel 1 exit 1

ninja

if errorlevel 1 exit 1

mkdir %SP_DIR%\med

if errorlevel 1 exit 1

ninja install

if errorlevel 1 exit 1

copy %LIBRARY_BIN%\mdump4.exe %LIBRARY_BIN%\mdump.exe

if errorlevel 1 exit 1

copy %LIBRARY_BIN%\xmdump4 %LIBRARY_BIN%\xmdump

if errorlevel 1 exit 1

endlocal
