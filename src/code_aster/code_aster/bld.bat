@echo off

set "CONDA_INCLUDE_PATH=%CONDA_PREFIX%\include"
set "CONDA_LIBRARY_PATH=%CONDA_PREFIX%\lib"

copy "%RECIPE_DIR%\bld\*" .

pip install ./deps/asrun
call install_metis.bat
call install_tfel.bat
rem call install_petsc.bat

set "TFELHOME=%LIBRARY_PREFIX%"
set "LIBPATH=%LIBRARY_PREFIX%\lib;%LIBPATH%"
set "INCLUDES=%LIBRARY_PREFIX%\include;%INCLUDES%"

set "LIBPATH_METIS=%LIBRARY_PREFIX%\metis-aster\lib"
set "INCLUDES_METIS=%LIBRARY_PREFIX%\metis-aster\include"

REM Install for standard sequential
waf ^
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

waf install

REM Not sure what these do
REM You may need to adapt the following commands to your Windows environment, using tools like findstr or PowerShell.
REM find %LIBRARY_PREFIX% -name "profile.sh" -exec sed -i 's/PYTHONHOME=/#PYTHONHOME=/g' {} \;
REM find %LIBRARY_PREFIX% -name "profile.sh" -exec sed -i 's/export PYTHONHOME/#export PYTHONHOME/g' {} \;
