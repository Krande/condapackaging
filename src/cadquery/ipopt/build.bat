@echo off

setlocal enabledelayedexpansion

:: call "%RECIPE_DIR%\activate_ifx.bat"
set "LIB=C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\compiler\lib;C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\compiler\lib\intel64;%LIB%"
set "PATH=C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin;C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\bin\intel64;%PATH%"
set "INCLUDE=C:\Program Files (x86)\Intel\oneAPI\compiler\latest\windows\compiler\include;%INCLUDE%"

echo "PATH: %PATH%"
echo "LIB: %LIB%"
echo "INCLUDE: %INCLUDE%"

call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
if %ERRORLEVEL% neq 0 exit 1
