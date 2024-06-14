@echo off

setlocal enabledelayedexpansion

echo "Setting compiler env vars"

:: set FC=flang-new.exe
set FC=ifx.exe
if not defined GITHUB_ACTIONS (
    if not "%FC%" == "flang-new" (
        call %RECIPE_DIR%\activate_ifx.bat
    )
)

set CC=clang-cl.exe
set CXX=clang-cl.exe

SET OUTPUT_DIR=%SRC_DIR%/build/std
echo "OUTPUT_DIR: %OUTPUT_DIR%"

set ASTER_PLATFORM_MSVC64=1
set ASTER_PLATFORM_WINDOWS=1

set MKLROOT=%LIBRARY_PREFIX%
SET MKLROOT=%MKLROOT:\=/%

SET LIB_PATH_ROOT=%LIBRARY_PREFIX:\=/%
SET PREF_ROOT=%PREFIX:\=/%

set LIBPATH_HDF5=%LIB_PATH_ROOT%/lib
set INCLUDES_HDF5=%LIB_PATH_ROOT%/include

set LIBPATH_MED=%LIB_PATH_ROOT%/lib
set INCLUDES_MED=%LIB_PATH_ROOT%/include

set LIBPATH_METIS=%LIB_PATH_ROOT%/lib
set INCLUDES_METIS=%LIB_PATH_ROOT%/include

set LIBPATH_MUMPS=%LIB_PATH_ROOT%/lib
set "INCLUDES_MUMPS=%LIB_PATH_ROOT%/include %LIB_PATH_ROOT%/include/mumps_seq"

set LIBPATH_SCOTCH=%LIB_PATH_ROOT%/lib
set INCLUDES_SCOTCH=%LIB_PATH_ROOT%/include

set TFELHOME=%LIB_PATH_ROOT%

set LIBPATH_MGIS=%LIB_PATH_ROOT%/bin
set INCLUDES_MGIS=%LIB_PATH_ROOT%/include

REM Compiler flags
set LIBPATH=%PREF_ROOT%/libs %LIBPATH%

REM /MD link with MSVCRT.lib. /FS allow for c compiler calls to vc140.pdb on multiple threads (for cl.exe only)

set CFLAGS=%CFLAGS% /FS /MD /DMKL_ILP64
set CXXFLAGS=%CXXFLAGS% /MD /DMKL_ILP64
set FCFLAGS=%FCFLAGS% /fpp /MD /4I8 /double-size:64 /real-size:64 /integer-size:64 /names:lowercase /assume:underscore /assume:nobscc

if %CC% == "cl.exe" set CFLAGS=%CFLAGS% /sourceDependencies %OUTPUT_DIR%

:: Add lib paths
set LDFLAGS=%LDFLAGS% /LIBPATH:%LIB_PATH_ROOT%/lib /LIBPATH:%LIB_PATH_ROOT%/bin /LIBPATH:%PREF_ROOT%/libs

if %build_type% == "debug" (
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

:: Add Math libs
set LDFLAGS=%LDFLAGS% mkl_intel_ilp64_dll.lib mkl_intel_thread_dll.lib mkl_core_dll.lib libiomp5md.lib

:: Add threading libs
set LDFLAGS=%LDFLAGS% pthread.lib

:: Add mumps libs
set LDFLAGS=%LDFLAGS% mpiseq.lib esmumps.lib scotch.lib scotcherr.lib scotcherrexit.lib

:: Add metis libs
set LDFLAGS=%LDFLAGS% metis.lib

:: Add libmed libs
set LDFLAGS=%LDFLAGS% med.lib medC.lib medfwrap.lib medimport.lib

set INCLUDES_BIBC=%PREF_ROOT%/include %SRC_DIR%/bibfor/include %INCLUDES_BIBC%

set DEFINES=H5_BUILT_AS_DYNAMIC_LIB PYBIND11_NO_ASSERT_GIL_HELD_INCREF_DECREF

python conda\update_version.py

set BUILD=std

python %RECIPE_DIR%\config\set_env_var.py %SRC_DIR%

REM Install for standard sequential
waf configure ^
  --safe ^
  --check-fortran-compiler=ifort ^
  --use-config-dir=%SRC_DIR%/config/ ^
  --med-libs="med medC medfwrap medimport" ^
  --prefix=%LIB_PATH_ROOT% ^
  --out=%SRC_DIR%/build/std ^
  --enable-med ^
  --enable-hdf5 ^
  --enable-mumps ^
  --enable-openmp ^
  --enable-metis ^
  --enable-scotch ^
  --disable-mpi ^
  --disable-petsc ^
  --install-tests ^
  --maths-libs=auto ^
  --without-hg ^
  --without-repo

if errorlevel 1 exit 1

if %build_type% == "debug" (
    waf install_debug -v
) else (
    waf install -v
)

if errorlevel 1 exit 1

endlocal