@echo off

setlocal enabledelayedexpansion

echo "Setting compiler env vars"

:: set FC=flang-new.exe
set FC=ifx.exe
if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
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

set CFLAGS=%CFLAGS% /FS /MD
set CXXFLAGS=%CXXFLAGS% /MD

if "%FC%" == "ifx.exe" (
    echo "Using Intel Fortran LLVM IFX compiler"
    set FC_SEARCH=ifort
    set FCFLAGS=%FCFLAGS% /fpp /MD /4I8 /4R8 /names:lowercase /assume:underscore /assume:nobscc /fpe:0
    :: Add lib paths
    set LDFLAGS=%LDFLAGS% /LIBPATH:%LIB_PATH_ROOT%/lib /LIBPATH:%LIB_PATH_ROOT%/bin /LIBPATH:%PREF_ROOT%/libs
) else (
    echo "Using LLVM Flang Fortran compiler"
    set FC_SEARCH=flang
    set FCFLAGS=%FCFLAGS% -cpp --dependent-lib=msvcrt -fdefault-double-8 -fdefault-integer-8 -fdefault-real-8 -funderscoring
    :: Add lib paths
    set LDFLAGS=%LDFLAGS% -L %LIB_PATH_ROOT%/lib -L %LIB_PATH_ROOT%/bin -L %PREF_ROOT%/libs
)
if %CC% == "cl.exe" set CFLAGS=%CFLAGS% /sourceDependencies %OUTPUT_DIR%

:: Create dll debug pdb
if "%build_type%" == "debug" (
    set FCFLAGS=%FCFLAGS% /check:stack
    set CFLAGS=%CFLAGS% /Zi
    set CXXFLAGS=%CXXFLAGS% /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
) else (
    REM set the equivalent of RelWithDebInfo
    set FCFLAGS=%FCFLAGS% /debug:full /debug-parameters:all /traceback
    set CFLAGS=%CFLAGS% /Z7
    set CXXFLAGS=%CXXFLAGS% /Z7
)

:: Add Math libs
set LDFLAGS=%LDFLAGS% mkl_intel_lp64_dll.lib mkl_intel_thread_dll.lib mkl_core_dll.lib libiomp5md.lib

:: Add threading libs
set LDFLAGS=%LDFLAGS% pthread.lib

:: Add mumps libs
set LDFLAGS=%LDFLAGS% mpiseq.lib esmumps.lib scotch.lib scotcherr.lib scotcherrexit.lib

:: Add metis libs
set LDFLAGS=%LDFLAGS% metis.lib

:: Add libmed libs
set LDFLAGS=%LDFLAGS% med.lib medC.lib medfwrap.lib medimport.lib

set INCLUDES_BIBC=%PREF_ROOT%/include %SRC_DIR%/bibfor/include %INCLUDES_BIBC%

set DEFINES=H5_BUILT_AS_DYNAMIC_LIB _CRT_SECURE_NO_WARNINGS _SCL_SECURE_NO_WARNINGS WIN32_LEAN_AND_MEAN

python conda\scripts\update_version.py

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
  --enable-metis ^
  --enable-scotch ^
  --disable-mpi ^
  --disable-openmp ^
  --disable-petsc ^
  --install-tests ^
  --maths-libs=auto ^
  --msvc-entry ^
  --without-hg ^
  --without-repo

if errorlevel 1 (
    type %SRC_DIR%/build/std/config.log
    exit 1
)

if "%build_type%" == "debug" (
    waf install_debug -v
) else (
    waf install -v
)

if errorlevel 1 exit 1

REM Move code_aster and run_aster directories (including subdirectories)
move "%LIBRARY_PREFIX%\lib\aster\code_aster" "%SP_DIR%\code_aster"
move "%LIBRARY_PREFIX%\lib\aster\run_aster" "%SP_DIR%\run_aster"

REM Move all .pyd files to %SP_DIR%
for %%f in ("%LIBRARY_PREFIX%\lib\aster\*.pyd") do move "%%f" "%SP_DIR%"

REM Move all dll/lib/pdb files to %BIN_DIR%
for %%f in ("%LIBRARY_PREFIX%\lib\aster\*.dll") do move "%%f" "%LIBRARY_BIN%"
for %%f in ("%LIBRARY_PREFIX%\lib\aster\*.lib") do move "%%f" "%LIBRARY_BIN%"
for %%f in ("%LIBRARY_PREFIX%\lib\aster\*.pdb") do move "%%f" "%LIBRARY_BIN%"

echo Files moved successfully.

endlocal