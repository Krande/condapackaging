@echo off

setlocal enabledelayedexpansion

echo Build MFRONT/TFEL

set FC=flang-new
set TGT_BUILD_TYPE=Release
set tgz_file=%SRC_DIR%/mfront_%version%.tar.gz
REM check if file exists "TFEL-%version%.tar.gz"
if exist "%tgz_file%" (
    echo "%tgz_file% exists"
   REM use 7zip to extract the tarball
   7z x "%tgz_file%" -o"%SRC_DIR%"
   patch -p1 < "%RECIPE_DIR%\patches/support_llvm-flang.patch"
) else (
    echo "%tgz_file% does not exist"
)

set "CXXFLAGS=%CXXFLAGS% -Wno-error=missing-template-arg-list-after-template-kw"
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=RelWithDebInfo
    set FCFLAGS=%FCFLAGS% -g -cpp
    set CFLAGS=%CFLAGS% /Od /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

cmake -B build . -G "Ninja" -Wno-dev ^
    %CMAKE_ARGS% ^
    -D CMAKE_CXX_COMPILER=clang-cl ^
    -D CMAKE_C_COMPILER=clang-cl ^
    -D CMAKE_LINKER=lld-link ^
    -D CMAKE_NM=llvm-nm ^
    -D CMAKE_BUILD_TYPE=%TGT_BUILD_TYPE% ^
    -D enable-fortran=ON ^
    -D enable-python-bindings=ON ^
    -D enable-cyrano=ON ^
    -D enable-aster=ON ^
    -D disable-website=ON ^
    -D enable-portable-build=ON ^
    -D Python_ADDITIONAL_VERSIONS=%CONDA_PY% ^
    -D enable-python=ON ^
    -D PYTHON_EXECUTABLE:FILEPATH=%PYTHON% ^
    -D PYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib ^
    -D PYTHON_INCLUDE_DIRS:PATH=%LIBRARY_PREFIX%\include ^
    -D TFEL_PYTHON_SITE_PACKAGES_DIR:PATH=%SP_DIR% ^
    -D USE_EXTERNAL_COMPILER_FLAGS=ON

REM Adjust the parallel build command as needed; for example, you can replace $(nproc) with the number of cores on your machine
cmake --build build --target install

IF ERRORLEVEL 1 (
  type configure.log
  exit /b 1
)

echo "Moving dll files to %LIBRARY_BIN%"
for %%f in ("%LIBRARY_LIB%\*.lib") do move "%%f" "%LIBRARY_BIN%"

if errorlevel 1 exit 1

if "%build_type%" == "debug" (
    :: Move the pdb files to the library bin directory
    echo "Moving pdb files to %LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\mfront\src\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\Config\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\Exception\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\Glossary\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\Material\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\Math\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\NUMODIS\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\System\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\UnicodeSupport\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\Utilities\*.pdb") do move "%%f" "%LIBRARY_BIN%"
)

if errorlevel 1 exit 1

echo MFRONT/TFEL build complete