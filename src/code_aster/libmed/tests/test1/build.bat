@echo off

setlocal

set INTEL_VARS_PATH=C:\Program Files (x86)\Intel\oneAPI\compiler\latest\env
set VS_VARS_PATH=C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build

call "%VS_VARS_PATH%\vcvars64.bat"
@call "%INTEL_VARS_PATH%\vars.bat" -arch intel64

set THIS_DIR=%~dp0
set ROOT_DIR=%THIS_DIR%..\..
echo ROOT_DIR=%ROOT_DIR%

REM cmake.exe --preset win-msvc-intel-fortran -S %ROOT_DIR% -B %ROOT_DIR%\build\win-msvc-intel-fortran
cmake.exe --build "%ROOT_DIR%\build\win-msvc-intel-fortran" --target all -j 10
cmake.exe --build "%ROOT_DIR%\build\win-msvc-intel-fortran" --target install -j 10

set FC=ifx
set INCLUDE_DIRS=%INCLUDE_DIRS% /I"%CONDA_PREFIX%\Library\include"
set LIB_DIRS=%LIB_DIRS% /LIBPATH:"%CONDA_PREFIX%\Library\lib" /LIBPATH:"%CONDA_PREFIX%\Library\bin"
set SHARED_FLAGS=/nologo /fpp /4I8 /double-size:64 /real-size:64 /integer-size:64 /assume:nobscc /DMKL_ILP64 /DEBUG

ifx test1.F90 %SHARED_FLAGS% %INCLUDE_DIRS% /link /DEFAULTLIB:libucrt /OUT:test1.exe %LIB_DIRS% medfwrap.lib medC.lib med.lib hdf5.lib hdf5_hl.lib hdf5_cpp.lib hdf5_hl_cpp.lib hdf5_fortran.lib hdf5_hl_fortran.lib

call test1.exe

endlocal