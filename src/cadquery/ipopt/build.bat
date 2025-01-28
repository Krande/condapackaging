set LDFLAGS=%LDFLAGS% mkl_intel_lp64_dll.lib mkl_intel_thread_dll.lib mkl_core_dll.lib libiomp5md.lib

call %BUILD_PREFIX%\Library\bin\run_autotools_clang_conda_build.bat
if %ERRORLEVEL% neq 0 exit 1
