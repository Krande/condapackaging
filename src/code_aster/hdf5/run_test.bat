@echo off

rem Verify CLI tools.
setlocal enabledelayedexpansion

set hdf5_cmds=gif2h5 h52gif h5copy h5debug h5diff h5dump h5import h5jam h5ls h5mkgrp h5repack h5repart h5stat h5unjam

for %%C in (%hdf5_cmds%) do (
    echo %%C
	where %%C || (
		echo Command not found: %%C
		exit /b 1
	)
)

rem Verify libraries.
set hdf5_libs=hdf5 hdf5_cpp hdf5_hl hdf5_hl_cpp
echo "build_type: %build_type%"

for %%L in (%hdf5_libs%) do (
    echo "Checking library: %%L"
    if "%build_type%" == "debug" (
        if not exist %PREFIX%\Library\lib\%%L_D.lib (
           echo Library not found: %PREFIX%\Library\lib\%%L_D.lib
            exit /b 1
        )
        if not exist %PREFIX%\Library\bin\%%L_D.dll (
            echo Library not found: %PREFIX%\Library\bin\%%L_D.dll
            exit /b 1
        )
    ) else (
        if not exist %PREFIX%\Library\lib\%%L.lib (
           echo Library not found: %PREFIX%\Library\lib\%%L.lib
            exit /b 1
        )
        if not exist %PREFIX%\Library\bin\%%L.dll (
            echo Library not found: %PREFIX%\Library\bin\%%L.dll
            exit /b 1
        )
    )
)

endlocal

exit /b 0
