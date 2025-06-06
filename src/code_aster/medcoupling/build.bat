@echo off

setlocal enabledelayedexpansion

mkdir build
cd build

:: Needed by IFX
set "LIB=%BUILD_PREFIX%\Library\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\opt\compiler\include\intel64;%INCLUDE%"
set "CMAKE_ARGS=!CMAKE_ARGS! -D HDF5_BUILD_FORTRAN:BOOL=ON"

REM currently fails with debug build
set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=RelWithDebInfo
    set CFLAGS=%CFLAGS% /Od /Zi -DSWIG_PYTHON_INTERPRETER_NO_DEBUG=1
    set CXXFLAGS=%CFLAGS% /Od /Zi -DSWIG_PYTHON_INTERPRETER_NO_DEBUG=1
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
    if "%FC%" == "flang-new" (
        set FFLAGS=%FFLAGS% -g -cpp
    ) else (
        set FFLAGS=%FFLAGS% /Od /Zi /debug /traceback
    )
)

set MED_INT_IS_LONG=OFF

if "%int_type%" == "64" (
    set MED_INT_IS_LONG=ON
)

echo "Building as BUILD_TYPE: %build_type%, INT_TYPE: %int_type%, MED_INT_IS_LONG: %MED_INT_IS_LONG%"
echo "FFLAGS: %FFLAGS%"

cmake -G "Ninja" .. ^
    -Wno-dev ^
    -D CMAKE_INSTALL_PREFIX="%PREFIX%\Library" ^
    -D CMAKE_PROGRAM_PATH="%BUILD_PREFIX%\bin;%BUILD_PREFIX%\Scripts;%BUILD_PREFIX%\Library\bin;%PREFIX%\bin;%PREFIX%\Scripts;%PREFIX%\Library\bin" ^
    -D CMAKE_BUILD_TYPE="%TGT_BUILD_TYPE%" ^
    -D PYTHON_ROOT_DIR="%PREFIX%" ^
    -D CMAKE_CXX_FLAGS="/bigobj /EHs" ^
    -D PYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -D CONFIGURATION_ROOT_DIR="%SRC_DIR%/deps/config" ^
    -D SALOME_CMAKE_DEBUG=OFF ^
    -D SALOME_USE_MPI=OFF ^
    -D MEDCOUPLING_BUILD_STATIC=OFF ^
    -D MEDCOUPLING_BUILD_TESTS=OFF ^
    -D MEDCOUPLING_BUILD_DOC=OFF ^
    -D MED_INT_IS_LONG:BOOL=%MED_INT_IS_LONG% ^
    -D MEDCOUPLING_USE_64BIT_IDS:BOOL=%MED_INT_IS_LONG% ^
    -D MEDCOUPLING_USE_MPI=OFF ^
    -D MEDCOUPLING_MEDLOADER_USE_XDR=OFF ^
    -D MEDCOUPLING_INSTALL_PYTHON=%SP_DIR% ^
    -D XDR_INCLUDE_DIRS="" ^
    -D MEDCOUPLING_ENABLE_PYTHON=ON ^
    -D MEDCOUPLING_ENABLE_PARTITIONER=ON ^
    -D MEDCOUPLING_PARTITIONER_PARMETIS=OFF ^
    -D MEDCOUPLING_PARTITIONER_METIS=OFF ^
    -D MEDCOUPLING_PARTITIONER_SCOTCH=OFF ^
    -D MEDCOUPLING_PARTITIONER_PTSCOTCH=OFF

if errorlevel 1 exit 1
ninja
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1

:: Move dll files from %PREFIX%/Library/Lib to %PREFIX%/Library/Bin
:: This is needed for the python bindings to work
echo "Moving dll files to %LIBRARY_BIN%"
for %%f in ("%LIBRARY_LIB%\*.dll") do move "%%f" "%LIBRARY_BIN%"

:: Move python files from bin to sp_dir
echo "Moving python files to %SP_DIR%"
for %%f in ("%LIBRARY_BIN%\*.py") do move "%%f" "%SP_DIR%"

if "%build_type%" == "debug" (
    :: Move the pdb files to the library bin directory
    echo "Moving pdb files to %LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\MEDLoader\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\MEDCoupling\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\INTERP_KERNEL\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\ICoCo\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\MEDPartitioner\*.pdb") do move "%%f" "%LIBRARY_BIN%"
    for %%f in ("%SRC_DIR%\build\src\RENUMBER\*.pdb") do move "%%f" "%LIBRARY_BIN%"
)

if errorlevel 1 exit 1

endlocal