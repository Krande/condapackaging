@echo off

setlocal enabledelayedexpansion

:: Needed by IFX
set "LIB=%BUILD_PREFIX%\Library\lib;%LIB%"
set "INCLUDE=%BUILD_PREFIX%\opt\compiler\include\intel64;%INCLUDE%"
set "CMAKE_ARGS=!CMAKE_ARGS! -D HDF5_BUILD_FORTRAN:BOOL=ON"
if errorlevel 1  exit 1

echo "Running test_med_int"
echo "CONDA_PREFIX: %CONDA_PREFIX%"
REM Set paths based on CONDA_PREFIX environment variable.
set INCLUDE_DIR=%CONDA_PREFIX%\Library\include
set LIB_DIR=%CONDA_PREFIX%\Library\lib
set this_dir=%~dp0

REM Compile test.f90 using cl with include and library directories.
ifx.exe /fpp /nologo /I"%INCLUDE_DIR%" /I"%LIB_DIR%" /4I8 /o %~dp0test_med_int.exe %~dp0test.f90
REM flang-new.exe -cpp -fuse-ld=lld -I%INCLUDE_DIR% -L%LIB_DIR% -o %~dp0test_med_int.exe %~dp0test.f90
if errorlevel 1 (
    echo Compilation failed.
    exit /b 1
)

REM Run the executable and capture its output.
for /f "delims=" %%i in ('%~dp0test_med_int.exe') do set MED_INT_SIZE=%%i
REM strip the trailing spaces
set MED_INT_SIZE=%MED_INT_SIZE: =%

echo MEDFile: size of med_int is "%MED_INT_SIZE%"

if "%MED_INT_SIZE%"=="8" (
    echo MED_INT_IS_LONG is TRUE.
) else (
    echo MED_INT_IS_LONG is FALSE.
)

endlocal
