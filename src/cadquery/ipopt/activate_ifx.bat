if not defined ONEAPI_ROOT (
    echo "ONEAPI_ROOT is not defined"
    set "ONEAPI_ROOT=C:\Program Files (x86)\Intel\oneAPI"
)

set "INTEL_VARS_PATH=%ONEAPI_ROOT%\compiler\latest\env"
echo "INTEL_VARS_PATH: %INTEL_VARS_PATH%"

if "%FC%" == "ifx" (
    echo "Already using Intel LLVM Fortran compiler. But forcing to set compiler env vars again"
    call "%INTEL_VARS_PATH%\vars.bat" -arch intel64
) else (
    echo "Setting compiler env vars"
    call "%INTEL_VARS_PATH%\vars.bat" -arch intel64
)

set FC=ifx.exe