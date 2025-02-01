@echo off
setlocal enabledelayedexpansion

:: Ensure required tools are available
where cmake >nul 2>nul
if errorlevel 1 (
    echo cmake not found, ensure it is installed.
    exit /b 1
)

:: Libraries to check
set PREFIX=%PREFIX%\Library

for %%L in (ptscotch ptscotcherr ptscotcherrexit ptesmumps) do (
    if exist %PREFIX%\lib\%%L.lib (
        echo Found %PREFIX%\lib\%%L.lib
    ) else (
        echo Missing %PREFIX%\lib\%%L.lib
        exit /b 1
    )
)

:: Include files
for %%I in (ptscotch.h ptscotchf.h ptesmumps.h) do (
    if exist %PREFIX%\include\%%I (
        echo Found %PREFIX%\include\%%I
    ) else (
        echo Missing %PREFIX%\include\%%I
        exit /b 1
    )
)

:: parmetis.h should exist in scotch but not globally
if exist %PREFIX%\include\scotch\parmetis.h (
    echo Found %PREFIX%\include\scotch\parmetis.h
) else (
    echo Missing %PREFIX%\include\scotch\parmetis.h
    exit /b 1
)

if exist %PREFIX%\include\parmetis.h (
    echo Unexpected file found: %PREFIX%\include\parmetis.h
    exit /b 1
)

:: dgord.exe should NOT exist
if exist %PREFIX%\bin\dgord.exe (
    echo Unexpected file found: %PREFIX%\bin\dgord.exe
    exit /b 1
)

echo All tests passed.
exit /b 0
