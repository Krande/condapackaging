@echo off

setlocal enabledelayedexpansion

echo "Setting compiler env vars"

:: set FC=flang-new.exe

if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
)

set CC=clang-cl.exe
set CXX=clang-cl.exe

SET OUTPUT_DIR=%SRC_DIR%/build/std
echo "OUTPUT_DIR: %OUTPUT_DIR%"

set ASTER_PLATFORM_MSVC=1
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

set CFLAGS=%CFLAGS% /FS /MD
set CXXFLAGS=%CXXFLAGS% /MD
set FCFLAGS=%FCFLAGS% /fpp /MD
set FCFLAGS=%FCFLAGS% /names:lowercase /assume:underscore /assume:nobscc

if %CC% == "cl.exe" set CFLAGS=%CFLAGS% /sourceDependencies %OUTPUT_DIR%

:: Add lib paths
set LDFLAGS=%LDFLAGS% /LIBPATH:%LIB_PATH_ROOT%/lib /LIBPATH:%LIB_PATH_ROOT%/bin /LIBPATH:%PREF_ROOT%/libs

if %build_type% == "debug" (
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

:: Add Math libs
set LDFLAGS=%LDFLAGS% mkl_intel_lp64_dll.lib mkl_intel_thread_dll.lib mkl_core_dll.lib libiomp5md.lib

:: Add threading libs
set LDFLAGS=%LDFLAGS% pthread.lib

:: Add hdf5 libs
@REM set LDFLAGS=%LDFLAGS% hdf5.lib hdf5_hl.lib

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
  --disable-mpi ^
  --maths-libs=auto ^
  --install-tests ^
  --without-hg

if errorlevel 1 exit 1

if %build_type% == "debug" (
    waf install_debug -v
) else (
    waf install -v
)

if errorlevel 1 exit 1

endlocal