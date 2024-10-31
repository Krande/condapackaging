@echo on

:: show CPU arch to detect slow CI agents early (rather than wait for 6h timeout)
python -c "import numpy; numpy.show_config()"

mkdir build
cd build

set "PROCESSOR_ARCHITECTURE=AMD64"

:: necessary when compiling with clang (which has a native uint128 type; msvc doesn't)
:: set "CXXFLAGS=%CXXFLAGS% -DAVOID_NATIVE_UINT128_T=1"

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DCMAKE_CXX_STANDARD=17 ^
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_MODULE_PATH=../cmake/Modules ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%;%LIBRARY_LIB%/clang/%PKG_VERSION% ^
    -DLLVM_EXTERNAL_LIT=%LIBRARY_BIN%/lit ^
    -DLLVM_LIT_ARGS=-v ^
    -DLLVM_CMAKE_DIR=%LIBRARY_LIB%/cmake/llvm ^
    -DLLVM_DIR=%LIBRARY_LIB%/cmake/llvm ^
    -DCLANG_DIR=%LIBRARY_LIB%/cmake/clang ^
    -DFLANG_INCLUDE_TESTS=OFF ^
    -DMLIR_DIR=%LIBRARY_LIB%/cmake/mlir ^
    ..\flang
if %ERRORLEVEL% neq 0 exit 1

cmake --build . -j2
if %ERRORLEVEL% neq 0 exit 1
