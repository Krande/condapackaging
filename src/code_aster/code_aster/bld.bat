@echo off
:: delayed expansion is needed for the if statement
setlocal EnableDelayedExpansion

echo "Setting compiler env vars"
set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

if not defined ONEAPI_ROOT (
  echo "ONEAPI_ROOT is not defined"
  set "ONEAPI_ROOT=C:\Program Files (x86)\Intel\oneAPI"
)
set "INTEL_VARS_PATH=%ONEAPI_ROOT%\compiler\latest\env"

if "%FC%" == "ifx" (
  echo "Already using Intel LLVM Fortran compiler"
) else (
  call "%INTEL_VARS_PATH%\vars.bat" -arch intel64
  echo "Setting Fortran compiler to Intel LLVM"
  set FC=ifx
)

where python
where "%CC%"
where "%FC%"

set ASTER_PLATFORM_MSVC=1
set ASTER_PLATFORM_WINDOWS=1

set MKLROOT=%LIBRARY_PREFIX%

set LIBPATH_HDF5=%LIBRARY_PREFIX%/lib
set INCLUDES_HDF5=%LIBRARY_PREFIX%/include

set LIBPATH_MED=%LIBRARY_PREFIX%/lib
set INCLUDES_MED=%LIBRARY_PREFIX%/include

set LIBPATH_METIS=%LIBRARY_PREFIX%/lib
set INCLUDES_METIS=%LIBRARY_PREFIX%/include

set LIBPATH_MUMPS=%LIBRARY_PREFIX%/lib
set "INCLUDES_MUMPS=%LIBRARY_PREFIX%/include"

set LIBPATH_SCOTCH=%LIBRARY_PREFIX%/lib
set INCLUDES_SCOTCH=%LIBRARY_PREFIX%/include

set TFELHOME=%LIBRARY_PREFIX%

set LIBPATH_MGIS=%LIBRARY_PREFIX%/bin
set INCLUDES_MGIS=%LIBRARY_PREFIX%/include

REM Compiler flags
@REM set LIBPATH=%%LIBRARY_PREFIX%%/libs %LIBPATH%

REM /MD link with MSVCRT.lib. /FS allow for c compiler calls to vc140.pdb on multiple threads (for cl.exe only)

set CFLAGS=%CFLAGS% /FS /MD
set CXXFLAGS=%CXXFLAGS% /MD
set FCFLAGS=%FCFLAGS% /fpp /MD
set FCFLAGS=%FCFLAGS% /names:lowercase /assume:underscore /assume:nobscc

:: Add lib paths
set LDFLAGS=%LDFLAGS% /LIBPATH:%LIBRARY_PREFIX%/lib /LIBPATH:%LIBRARY_PREFIX%/bin /LIBPATH:%%LIBRARY_PREFIX%%/libs

:: Add Math libs
set LDFLAGS=%LDFLAGS% mkl_intel_lp64_dll.lib mkl_intel_thread_dll.lib mkl_core_dll.lib libiomp5md.lib

:: Add threading libs
set LDFLAGS=%LDFLAGS% pthread.lib

:: Add hdf5 libs
@REM set LDFLAGS=%LDFLAGS% hdf5.lib hdf5_hl.lib

:: Add mumps libs
@REM set LDFLAGS=%LDFLAGS% dmumps_seq.lib zmumps_seq.lib smumps_seq.lib cmumps_seq.lib mumps_common_seq.lib pord.lib

:: Add libmed libs
set LDFLAGS=%LDFLAGS% med.lib medC.lib medfwrap.lib medimport.lib

set INCLUDES_BIBC=%%LIBRARY_PREFIX%%/include %SRC_DIR%/bibfor/include %INCLUDES_BIBC%

set DEFINES=H5_BUILT_AS_DYNAMIC_LIB PYBIND11_NO_ASSERT_GIL_HELD_INCREF_DECREF

python conda\update_version.py

set BUILD=std

REM Install for standard sequential
waf configure ^
  --check-fortran-compiler=ifort ^
  --use-config-dir=%SRC_DIR%config/ ^
  --med-libs="med medC medfwrap medimport" ^
  --prefix=%LIBRARY_PREFIX% ^
  --out=%OUTPUT_DIR% ^
  --disable-mpi ^
  --maths-libs=auto ^
  --install-tests ^
  --without-hg

if errorlevel 1 exit 1

waf install_debug -v

if errorlevel 1 exit 1

endlocal