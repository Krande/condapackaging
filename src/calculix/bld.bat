@echo off
cd ccx*/src

rem Remove the old Makefile and copy the new one
del Makefile_MT
copy %RECIPE_DIR%\Makefile_MT_Win Makefile_MT

rem Ensure that MSVC cl and lib commands are available in the path
REM call "%VSINSTALLDIR%\VC\Auxiliary\Build\vcvars64.bat"

rem Translate Windows paths to a format understandable for the MSVC environment
REM for /F "delims=\" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX=%%i"

nmake /f Makefile_MT ^
    SPOOLES_INCLUDE_DIR="%LIBRARY_PREFIX%\include\spooles" ^
    LIB_DIR="%LIBRARY_PREFIX%\lib" ^
    LDFLAGS="/LIBPATH:%LIBRARY_PREFIX%\lib" ^
    FC="flang-new" ^
    VERSION="%PKG_VERSION%"

rem Rename the output executable to have a .exe extension
move ccx_*_conda "%LIBRARY_PREFIX%\bin\ccx.exe"

cd %SRC_DIR%
