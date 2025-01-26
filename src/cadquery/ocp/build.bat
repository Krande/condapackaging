@echo off

patch -p1 < %RECIPE_DIR%/patches/no-vtk.patch
cd OCP
del IVtk* /Q

for %%module in (IVtk IVtkOCC IVtkTools IVtkVTK) do (
    powershell -Command "(Get-Content OCP/OCP.cpp) -notmatch '/register_IVtk/' | Set-Content OCP/OCP.cpp"
)
cd ..
if errorlevel 1 exit 1

cmake %CMAKE_ARGS% -B build -S "." ^
	-G Ninja ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DPython3_FIND_STRATEGY=LOCATION ^
	-DPython3_ROOT_DIR=%CONDA_PREFIX% ^
	-DCMAKE_LINKER=lld-link.exe ^
	-DCMAKE_MODULE_LINKER_FLAGS="/machine:x64 /FORCE:MULTIPLE"
if errorlevel 1 exit 1

cmake --build build -v -- -k 0
cmake --build build -v -j 1 -- -k 0
if errorlevel 1 exit 1

cmake --install build --prefix "%STDLIB_DIR%"
if errorlevel 1 exit 1

cmake -E copy_directory "%SRC_DIR%/src/OCP-stubs" "%SP_DIR%/OCP-stubs"
if errorlevel 1 exit 1
