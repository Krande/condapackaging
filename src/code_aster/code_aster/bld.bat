@echo off

set "CONDA_INCLUDE_PATH=%CONDA_PREFIX%\include"
set "CONDA_LIBRARY_PATH=%CONDA_PREFIX%\lib"

set "TFELHOME=%LIBRARY_PREFIX%"
set "LIBPATH=%LIBRARY_PREFIX%\lib;%LIBPATH%"
set "INCLUDES=%LIBRARY_PREFIX%\include;%INCLUDES%"

set "LIBPATH_METIS=%LIBRARY_PREFIX%\metis-aster\lib"
set "INCLUDES_METIS=%LIBRARY_PREFIX%\metis-aster\include"

REM Install for standard sequential
waf_std ^
  --use-config=wafcfg_conda ^
  --use-config-dir="%RECIPE_DIR%\config" ^
  --prefix=%LIBRARY_PREFIX% ^
  --libdir=%LIBRARY_PREFIX%\lib ^
  --pythondir=%LIBRARY_PREFIX%\lib ^
  --install-tests ^
  --embed-metis ^
  --without-ptsc ^
  --without-hg ^
  configure

if errorlevel 1 exit 1

waf_std install

if errorlevel 1 exit 1