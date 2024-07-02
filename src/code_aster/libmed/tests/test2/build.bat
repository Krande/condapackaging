@echo off

echo "Building test1.exe"

setlocal ENABLEDELAYEDEXPANSION

set THIS_DIR=%~dp0
set ROOT_DIR=%THIS_DIR%..\..
echo ROOT_DIR=%ROOT_DIR%

echo "RECIPE_DIR=%RECIPE_DIR%"
if not "%FC%" == "flang-new" (
    call %ROOT_DIR%\activate_ifx.bat
)

set FC=ifx
set INCLUDE_DIRS=%INCLUDE_DIRS% /I"%CONDA_PREFIX%\Library\include"
set LIB_DIRS=%LIB_DIRS% /LIBPATH:"%CONDA_PREFIX%\Library\lib" /LIBPATH:"%CONDA_PREFIX%\Library\bin"
set SHARED_FLAGS=/nologo /fpp /4I8 /double-size:64 /real-size:64 /integer-size:64 /assume:nobscc /DMKL_ILP64 /DEBUG /0d /Zi

ifx -c subr1.F90 %SHARED_FLAGS% %INCLUDE_DIRS%
ifx test1.F90 subr1.obj %SHARED_FLAGS% %INCLUDE_DIRS% /link /DEFAULTLIB:libucrt /OUT:test1.exe %LIB_DIRS% medfwrap.lib medC.lib med.lib hdf5.lib hdf5_hl.lib hdf5_cpp.lib hdf5_hl_cpp.lib hdf5_fortran.lib hdf5_hl_fortran.lib

if errorlevel 1 (
    pause
    exit 1
)

call test1.exe

if errorlevel 1 exit 1

echo "Successfully built and tested test1.exe"

endlocal