@echo off
setlocal

set PREFIX=%PREFIX%\Library

:: Libraries
for %%L in (scotch scotcherr scotcherrexit esmumps) do (
    if exist %PREFIX%\lib\%%L.lib (
        echo Found %PREFIX%\lib\%%L.lib
    ) else (
        echo Missing %PREFIX%\lib\%%L.lib
        exit /b 1
    )
)

:: Include files
for %%I in (scotch.h scotchf.h esmumps.h) do (
    if exist %PREFIX%\include\%%I (
        echo Found %PREFIX%\include\%%I
    ) else (
        echo Missing %PREFIX%\include\%%I
        exit /b 1
    )
)

:: metis.h should NOT exist
if exist %PREFIX%\include\metis.h (
    echo Unexpected file found: %PREFIX%\include\metis.h
    exit /b 1
)

:: scotch/metis.h should exist
if exist %PREFIX%\include\scotch\metis.h (
    echo Found %PREFIX%\include\scotch\metis.h
) else (
    echo Missing %PREFIX%\include\scotch\metis.h
    exit /b 1
)

:: gord.exe should NOT exist
if exist %PREFIX%\bin\gord.exe (
    echo Unexpected file found: %PREFIX%\bin\gord.exe
    exit /b 1
)

echo All tests passed.
exit /b 0
