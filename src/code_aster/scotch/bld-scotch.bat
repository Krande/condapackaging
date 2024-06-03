set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data\

:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

@REM if not defined ONEAPI_ROOT (
@REM   echo "ONEAPI_ROOT is not defined"
@REM   set "ONEAPI_ROOT=C:\Program Files (x86)\Intel\oneAPI"
@REM )
@REM set "INTEL_VARS_PATH=%ONEAPI_ROOT%\compiler\latest\env"
@REM
@REM if "%FC%" == "ifx" (
@REM   echo "Already using Intel LLVM Fortran compiler"
@REM ) else (
@REM   call "%INTEL_VARS_PATH%\vars.bat" -arch intel64
@REM   set FC=ifx
@REM )
@REM if "%mpi%" == "nompi" (
@REM     set USE_MPI=OFF
@REM ) else (
@REM     set USE_MPI=ON
@REM )

set FC=flang-new
set CFLAGS=%CFLAGS% /nologo -DINTSIZE=64

cmake ^
  -G "Ninja" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D BUILD_SHARED_LIBS=OFF ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D MPI_THREAD_MULTIPLE=%USE_MPI% ^
  -D BUILD_PTSCOTCH=%USE_MPI% ^
  -D THREADS_PTHREADS_INCLUDE_DIR="%LIBRARY_INC%" ^
  -D THREADS_PTHREADS_WIN32_LIBRARY:FILEPATH="%LIBRARY_LIB%\pthread.lib" ^
  -B build ^
  %SRC_DIR%

if errorlevel 1 exit 1

cmake --build ./build --config Release
if errorlevel 1 exit 1
cmake --install ./build --component=libscotch
if errorlevel 1 exit 1
