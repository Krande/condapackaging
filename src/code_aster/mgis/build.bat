@echo off

setlocal enabledelayedexpansion

set CLICOLOR_FORCE=1

rem Set TFELHOME to the PREFIX environment variable
set TFELHOME=%PREFIX%
set FC=flang-new

set TGT_BUILD_TYPE=Release

if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=RelWithDebInfo
    set FCFLAGS=%FCFLAGS%/Od /debug:full /Zi
    set CFLAGS=%CFLAGS%/Od /debug:full /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

cmake -B build . -G "Ninja" ^
    -D CMAKE_INSTALL_PREFIX="%PREFIX%\Library" ^
    -D CMAKE_PROGRAM_PATH="%BUILD_PREFIX%\bin;%BUILD_PREFIX%\Scripts;%BUILD_PREFIX%\Library\bin;%PREFIX%\bin;%PREFIX%\Scripts;%PREFIX%\Library\bin" ^
    -D CMAKE_BUILD_TYPE=%TGT_BUILD_TYPE% ^
    -D enable-c-bindings=ON ^
    -D enable-fortran-bindings=ON ^
    -D enable-python-bindings=ON ^
    -D enable-portable-build=ON ^
    -D enable-julia-bindings=OFF ^
    -D enable-website=OFF ^
    -D enable-broken-boost-python-module-visibility-handling=ON ^
    -D PYTHONLIBS_VERSION_STRING="%CONDA_PY%" ^
    -D Python_ADDITIONAL_VERSIONS="%python_version%" ^
    -D PYTHON_EXECUTABLE:FILEPATH="%PREFIX%/python.exe" ^
    -D PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib ^
    -D PYTHON_LIBRARY_PATH:PATH="%PREFIX%/libs" ^
    -D PYTHON_INCLUDE_DIRS:PATH="%PREFIX%/include" ^
    -D USE_EXTERNAL_COMPILER_FLAGS=ON ^
    -D MGIS_PYTHON_SITE_PACKAGES_DIRECTORY:PATH=%SP_DIR%

cmake --build build --target install

IF ERRORLEVEL 1 (
  type configure.log
  exit /b 1
)

echo "Moving lib files to %LIBRARY_BIN%"
for %%f in ("%LIBRARY_BIN%\*.lib") do move "%%f" "%LIBRARY_LIB%"

if errorlevel 1 exit 1

if "%build_type%" == "debug" (
    :: Move the pdb files to the library bin directory
    echo "Moving pdb files to %LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\bindings\fortran\src\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\bindings\c\src\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\bindings\python\src\*.pdb") do move "%%f" "%LIBRARY_BIN%"
)

if errorlevel 1 exit 1

endlocal