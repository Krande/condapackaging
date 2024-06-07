set BISON_PKGDATADIR=%BUILD_PREFIX%\Library\share\winflexbison\data\

:: MSVC is preferred.
set CC=clang-cl.exe
set CXX=clang-cl.exe
@REM set FC=flang-new

if not "%FC%" == "flang-new" (
    call %RECIPE_DIR%\activate_ifx.bat
)

set CMAKE_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set CMAKE_BUILD_TYPE=Debug
)

set CFLAGS=%CFLAGS% /nologo

cmake ^
  -G "Ninja" ^
  -D CMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -D BUILD_SHARED_LIBS=OFF ^
  -D INTSIZE=64 ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
  -D MPI_THREAD_MULTIPLE=%USE_MPI% ^
  -D BUILD_PTSCOTCH=%USE_MPI% ^
  -D THREADS_PTHREADS_INCLUDE_DIR="%LIBRARY_INC%" ^
  -D THREADS_PTHREADS_WIN32_LIBRARY:FILEPATH="%LIBRARY_LIB%\pthread.lib" ^
  -B build ^
  %SRC_DIR%

if errorlevel 1 exit 1

cmake --build ./build --config %CMAKE_BUILD_TYPE%
if errorlevel 1 exit 1
cmake --install ./build --component=libscotch
if errorlevel 1 exit 1
