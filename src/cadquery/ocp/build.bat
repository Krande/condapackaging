@echo off

patch -p1 < %RECIPE_DIR%/patches/no-vtk.patch
del IVtk* /Q

python %RECIPE_DIR%/update_ocp_novtk.py

if errorlevel 1 exit 1

cmake %CMAKE_ARGS% -B build -S "." ^
	-G Ninja ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DPython3_FIND_STRATEGY=LOCATION ^
	-DPython3_ROOT_DIR=%CONDA_PREFIX% ^
	-DCMAKE_LINKER=lld-link.exe ^
	-DCMAKE_MODULE_LINKER_FLAGS="/machine:x64 /FORCE:MULTIPLE"
if errorlevel 1 exit 1

ninja -C build -v

cmake -E copy_directory "%SRC_DIR%/OCP-stubs" "%SP_DIR%/OCP"
if errorlevel 1 exit 1
