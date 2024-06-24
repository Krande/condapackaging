@echo OFF

setlocal ENABLEDELAYEDEXPANSION

mkdir build
cd build
:: LLVM Flang support will have to be patched into libmed source code
:: set FC=flang-new

if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
)

set TGT_BUILD_TYPE=Release

if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /Od /Zi
    set CXXFLAGS=%CFLAGS% /Od /Zi /EHsc
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
    if "%FC%" == "flang-new" (
        set FFLAGS=%FFLAGS% -g -cpp
    ) else (
        set FFLAGS=%FFLAGS% /Od /debug /Zi
    )
)

:: This updates the symbols to lowercase and adds an underscore
xcopy %RECIPE_DIR%\medfwrap_symbols.def %SRC_DIR%\src\medfwrap_symbols.def.in /Y

set FFLAGS=%FFLAGS% /nologo /fpp /fixed /dll /MD /real-size:64 /integer-size:64

echo "FFLAGS: %FFLAGS%"
echo "CFLAGS: %CFLAGS%"
echo "LDFLAGS: %LDFLAGS%"

cmake -G "Ninja" ^
  %CMAKE_ARGS% ^
  -D CMAKE_BUILD_TYPE="%TGT_BUILD_TYPE%" ^
  -D CMAKE_Fortran_FLAGS:STRING="%FFLAGS%" ^
  -D CMAKE_C_FLAGS:STRING="%CFLAGS%" ^
  -D CMAKE_CXX_FLAGS:STRING="%CXXFLAGS%" ^
  -D CMAKE_EXE_LINKER_FLAGS:STRING="%LDFLAGS%" ^
  -D Python_FIND_STRATEGY:STRING=LOCATION ^
  -D Python_FIND_REGISTRY:STRING=NEVER ^
  -D Python3_ROOT_DIR:FILEPATH="%PREFIX%" ^
  -D HDF5_ROOT_DIR:FILEPATH="%LIBRARY_PREFIX%" ^
  -D MEDFILE_INSTALL_DOC=OFF ^
  -D MEDFILE_BUILD_PYTHON=ON ^
  -D MEDFILE_BUILD_TESTS=OFF ^
  -D MEDFILE_BUILD_SHARED_LIBS=ON ^
  -D MEDFILE_BUILD_STATIC_LIBS=OFF ^
  -D MEDFILE_USE_UNICODE=ON ^
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
