@echo off
echo Build MFRONT/TFEL

set FC=flang-new


set CMAKE_BUILD_TYPE=Release

if "%build_type%" == "debug" (
    set FCFLAGS=%FCFLAGS%/Od /debug:full /Z7
    set CFLAGS=%CFLAGS%/Od /debug:full /Z7
)

cmake -B build . -G "Ninja" -Wno-dev ^
    %CMAKE_ARGS% ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_LINKER=lld-link ^
    -DCMAKE_NM=llvm-nm ^
    -DCMAKE_BUILD_TYPE=%CMAKE_BUILD_TYPE% ^
    -Denable-fortran=ON ^
    -Denable-python-bindings=ON ^
    -Denable-cyrano=ON ^
    -Denable-aster=ON ^
    -Ddisable-website=ON ^
    -Denable-portable-build=ON ^
    -DPython_ADDITIONAL_VERSIONS=%CONDA_PY% ^
    -Denable-python=ON ^
    -DPYTHON_EXECUTABLE:FILEPATH=%PYTHON% ^
    -DPYTHON_LIBRARY:FILEPATH=%PREFIX%\libs\python%CONDA_PY%.lib ^
    -DPYTHON_INCLUDE_DIRS:PATH=%LIBRARY_PREFIX%\include ^
    -DSITE_PACKAGES_DIR:PATH=%SP_DIR% ^
    -DUSE_EXTERNAL_COMPILER_FLAGS=ON

REM Adjust the parallel build command as needed; for example, you can replace $(nproc) with the number of cores on your machine
cmake --build build --target install

IF ERRORLEVEL 1 (
  type configure.log
  exit /b 1
)
echo MFRONT/TFEL build complete