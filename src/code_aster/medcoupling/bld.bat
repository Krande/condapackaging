@echo off

mkdir build
cd build

REM currently fails with debug build
set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=RelWithDebInfo
    set CFLAGS=%CFLAGS% /Od /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
    if "%FC%" == "flang-new" (
        set FFLAGS=%FFLAGS% -g -cpp
    ) else (
        set FFLAGS=%FFLAGS% /Od /Zi
    )
)

cmake -G "Ninja" .. ^
    -Wno-dev ^
    -D CMAKE_BUILD_TYPE="%TGT_BUILD_TYPE%" ^
    -D PYTHON_ROOT_DIR="%PREFIX%" ^
    -D CMAKE_CXX_FLAGS="/bigobj /EHsc" ^
    -D PYTHON_EXECUTABLE:FILEPATH="%PYTHON%" ^
    -D CONFIGURATION_ROOT_DIR="%SRC_DIR%/deps/config" ^
    -D SALOME_CMAKE_DEBUG=ON ^
    -D SALOME_USE_MPI=OFF ^
    -D MEDCOUPLING_BUILD_STATIC=OFF ^
    -D MEDCOUPLING_BUILD_TESTS=OFF ^
    -D MEDCOUPLING_BUILD_DOC=OFF ^
    -D MED_INT_IS_LONG=ON ^
    -D MEDCOUPLING_USE_64BIT_IDS=ON ^
    -D MEDCOUPLING_USE_MPI=OFF ^
    -D MEDCOUPLING_MEDLOADER_USE_XDR=OFF ^
    -D MEDCOUPLING_INSTALL_PYTHON=%SP_DIR% ^
    -D XDR_INCLUDE_DIRS="" ^
    -D MEDCOUPLING_ENABLE_PYTHON=ON ^
    -D MEDCOUPLING_ENABLE_PARTITIONER=ON ^
    -D MEDCOUPLING_PARTITIONER_PARMETIS=OFF ^
    -D MEDCOUPLING_PARTITIONER_METIS=OFF ^
    -D MEDCOUPLING_PARTITIONER_SCOTCH=OFF ^
    -D MEDCOUPLING_PARTITIONER_PTSCOTCH=OFF ^
    %CMAKE_ARGS%

if errorlevel 1 exit 1
ninja
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1

:: Move dll files from %PREFIX%/Library/Lib to %PREFIX%/Library/Bin
:: This is needed for the python bindings to work

cd %LIBRARY_LIB%
move *.dll %LIBRARY_BIN%
