@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 [replacement]
    exit /b 1
)

set REPLACEMENT=%~1
set THIS_DIR=%~dp0
:: strip trailing backslash
set THIS_DIR=%THIS_DIR:~0,-1%

set RECIPE_FILE=%THIS_DIR%/%REPLACEMENT%/recipe.yaml
if not exist %RECIPE_FILE% (
    echo Recipe file %RECIPE_FILE% does not exist
    conda-recipe-manager convert %THIS_DIR%/%REPLACEMENT%/meta.yaml -o %RECIPE_FILE%
)

set CMD=rattler-build build -r %RECIPE_FILE% -m %THIS_DIR%\win.yaml -m %THIS_DIR%/%REPLACEMENT%/conda_build_config.yaml -c https://repo.prefix.dev/code-aster -c conda-forge

:: Shift arguments
set ARGS=
shift
:loop
if "%~1"=="" goto done
set ARGS=%ARGS% %1
shift
goto loop
:done

echo Running command: %CMD% %ARGS%
%CMD% %ARGS%

endlocal
