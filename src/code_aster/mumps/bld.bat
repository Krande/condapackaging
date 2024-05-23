@echo off

setlocal EnableDelayedExpansion


mkdir build
cd build

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


:: Configure using the CMakeFiles
cmake -G "Ninja" ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_BUILD_TYPE:STRING=Release ^
      -D MUMPS_UPSTREAM_VERSION:STRING=5.6.2 ^
      -D MKL_DIR:PATH=%LIBRARY_PREFIX%/lib ^
      -D LAPACK_VENDOR:STRING=MKL ^
      -D intsize64:BOOL=ON ^
      -D gemmt:BOOL=OFF ^
      -D metis:BOOL=ON ^
      -D scotch:BOOL=ON ^
      -D parallel:BOOL=OFF ^
      -D THREADS_PTHREADS_INCLUDE_DIR="%LIBRARY_INC%" ^
      -D THREADS_PTHREADS_WIN32_LIBRARY:FILEPATH="%LIBRARY_LIB%\pthread.lib" ^
      ..

if errorlevel 1 exit 1
cmake --build . --config Release --target install

endlocal
