set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data\

:: MSVC is preferred.
set CC=cl.exe
set CXX=cl.exe

if not defined ONEAPI_ROOT (
  echo "ONEAPI_ROOT is not defined"
  set "ONEAPI_ROOT=C:\Program Files (x86)\Intel\oneAPI"
)
set "INTEL_VARS_PATH=%ONEAPI_ROOT%\compiler\latest\env"

if "%FC%" == "ifx" (
  echo "Already using Intel LLVM Fortran compiler"
) else (
  call "%INTEL_VARS_PATH%\vars.bat" -arch intel64
  set FC=ifx
)
if "%mpi%" == "nompi" (
    set USE_MPI=OFF
) else (
    set USE_MPI=ON
)
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
