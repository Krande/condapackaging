@echo off
setlocal

set CLICOLOR_FORCE=1

rem Set TFELHOME to the PREFIX environment variable
set TFELHOME=%PREFIX%

cmake -B build . -G "Ninja" ^
    %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=%build_type% ^
    -Denable-c-bindings=OFF ^
    -Denable-fortran-bindings=OFF ^
    -Denable-python-bindings=ON ^
    -Denable-portable-build=ON ^
    -Denable-julia-bindings=OFF ^
    -Denable-website=OFF ^
    -Denable-broken-boost-python-module-visibility-handling=ON ^
    -DPYTHONLIBS_VERSION_STRING="%CONDA_PY%" ^
    -DPython_ADDITIONAL_VERSIONS="%python_version%" ^
    -DPYTHON_EXECUTABLE:FILEPATH="%PREFIX%/python.exe" ^
    -DPYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib ^
    -DPYTHON_LIBRARY_PATH:PATH="%PREFIX%/libs" ^
    -DPYTHON_INCLUDE_DIRS:PATH="%PREFIX%/include" ^
    -DUSE_EXTERNAL_COMPILER_FLAGS=ON ^
    -DSITE_PACKAGES_DIR:PATH=%SP_DIR%

cmake --build build --target install

IF ERRORLEVEL 1 (
  type configure.log
  exit /b 1
)
endlocal
