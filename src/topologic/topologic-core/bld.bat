@echo on

set CLICOLOR_FORCE=1

set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=RelWithDebInfo
    set CFLAGS=%CFLAGS% /Od /Zi
    set CXXFLAGS=%CFLAGS% /Od /Zi
    set FCFLAGS=%FCFLAGS% /Od /debug /Zi /traceback
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

cmake -B "build" -G "Ninja" ^
 -D CMAKE_BUILD_TYPE:STRING=%TGT_BUILD_TYPE% ^
 -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D USE_CONDA_PYBIND11:BOOL=ON ^
 -D OCC_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include\opencascade" ^
 -D OCC_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D PYTHON_INCLUDE_DIR=%PREFIX%\include ^
 -D PYTHON_EXECUTABLE:FILEPATH=%PREFIX%\python.exe ^
 -D PYTHON_LIBRARY:FILEPATH="%PREFIX%"\libs/python%MY_PY_VER%.lib ^
 ../TopologicCore

if errorlevel 1 exit 1

cmake --build "build" --config %TGT_BUILD_TYPE%

if errorlevel 1 exit 1

cmake --install "build" --config %TGT_BUILD_TYPE%

if errorlevel 1 exit 1

REM move the output files to the appropriate directories
move /Y %LIBRARY_LIB%\TopologicCore\*.dll %LIBRARY_PREFIX%\bin
move /Y %LIBRARY_LIB%\TopologicCore\*.lib %LIBRARY_PREFIX%\lib
move /Y %LIBRARY_LIB%\TopologicPythonBindings\*.pyd %PREFIX%\DLLs
