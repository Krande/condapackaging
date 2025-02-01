@echo off

echo "Running test_med_int"

setlocal enabledelayedexpansion

REM Set paths based on CONDA_PREFIX environment variable.
set INCLUDE_DIR=%CONDA_PREFIX%\Library\include
set LIB_DIR=%CONDA_PREFIX%\Library\lib

REM Compile test.cpp using cl with include and library directories.
cl /EHsc tests\test_med_int\test.cpp /I "%INCLUDE_DIR%" /link /LIBPATH:"%LIB_DIR%" /out:test_med_int.exe
if errorlevel 1 (
    echo Compilation failed.
    exit /b 1
)

REM Run the executable and capture its output.
for /f "delims=" %%i in ('test_med_int.exe') do set MED_INT_SIZE=%%i

echo MEDFile: size of med_int is "%MED_INT_SIZE%"

if "%MED_INT_SIZE%"=="8" (
    echo MED_INT_IS_LONG is TRUE.
) else (
    echo MED_INT_IS_LONG is FALSE.
)

endlocal
