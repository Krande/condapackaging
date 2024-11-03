@echo off

call "C:\Program Files (x86)\Intel\oneAPI\compiler\latest\env\vars.bat" -arch intel64
if errorlevel 1 (
    echo "Failed to activate Intel environment."
    exit /b 1
)
@REM where ifx.exe
if errorlevel 1 exit /b 1
