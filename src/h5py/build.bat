set HDF5_VERSION=%hdf5%
set HDF5_DIR="%LIBRARY_PREFIX%"

REM tell setup.py to not 'pip install' exact package requirements
set H5PY_SETUP_REQUIRES=0

@REM dir "%RECIPE_DIR%/config"
@REM dir "%SRC_DIR%"

copy /Y "%RECIPE_DIR%\config\setup_configure.py" "%SRC_DIR%\setup_configure.py"
copy /Y "%RECIPE_DIR%\config\version.py" "%SRC_DIR%\h5py\version.py"
copy /Y "%RECIPE_DIR%\config\__init__.py" "%SRC_DIR%\h5py\__init__.py"
copy /Y "%RECIPE_DIR%\config\test_file.py" "%SRC_DIR%\h5py\tests\test_file.py"

"%PYTHON%" -m pip install . --no-deps --ignore-installed --no-cache-dir -vv
if errorlevel 1 exit 1
