@ECHO ON

mkdir build
cd build
if not defined ONEAPI_ROOT (
  echo "ONEAPI_ROOT is not defined"
  set "ONEAPI_ROOT=C:\Program Files (x86)\Intel\oneAPI"
)
set "INTEL_VARS_PATH=%ONEAPI_ROOT%\compiler\latest\env"
echo "compiler=%ONEAPI_ROOT%\compiler"
@call "%INTEL_VARS_PATH%\vars.bat" -arch intel64 vs2022

:: This updates the symbols to lowercase and adds an underscore
xcopy %RECIPE_DIR%\medfwrap_symbols.def %SRC_DIR%\src\medfwrap_symbols.def.in /Y

set FC=ifx
set FFLAGS=%FFLAGS% /nologo /fpp /fixed /dll /MD /real-size:64 /integer-size:64

cmake -G "Ninja" ^
  %CMAKE_ARGS% ^
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
  -D MED_MEDINT_TYPE=long ^
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
