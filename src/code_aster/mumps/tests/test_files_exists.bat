@echo off
setlocal

set files=dmumps.lib mumps_common.lib mpiseq.lib pord.lib smumps.lib zmumps.lib cmumps.lib
:: These are apparently not created on windows?
:: zmumps.lib
:: cmumps.lib

set "missing_files="

for %%f in (%files%) do (
    if not exist "%LIBRARY_PREFIX%\lib\%%f" (
        echo File not found: %LIBRARY_PREFIX%\lib\%%f
        set "missing_files=1"
    )
)

set header_files=cmumps_c.h

for %%f in (%header_files%) do (
    if not exist "%LIBRARY_PREFIX%\include\%%f" (
        echo File not found: %LIBRARY_PREFIX%\include\%%f
        set "missing_files=1"
    )
)

if defined missing_files (
    echo One or more files are missing.
    exit /b 1
)

echo All files are present.
exit /b 0
