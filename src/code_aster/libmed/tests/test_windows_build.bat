@echo off

setlocal enabledelayedexpansion

SET DLL_PATH="%LIBRARY_PREFIX%\bin\medfwrap.dll"
if "%LIBRARY_PREFIX%"=="" (
    echo Error: LIBRARY_PREFIX is not set.
    SET DLL_PATH="%CONDA_PREFIX%\Library\bin\medfwrap.dll"
)

SET SYMBOL=mseipw_

dumpbin /EXPORTS %DLL_PATH%

dumpbin /EXPORTS %DLL_PATH% | findstr %SYMBOL%

IF ERRORLEVEL 1 (
    echo Error: Symbol %SYMBOL% not found in %DLL_PATH%.
    exit /b 1
) ELSE (
    echo Success: Symbol %SYMBOL% found in %DLL_PATH%.
)

endlocal