REM CP %BUILD_PREFIX%\Library\usr\bin\mingw32-make %BUILD_PREFIX%\Library\mingw-w64\bin\make
make lib
if errorlevel 1 exit 1

cd MT\src\
make
if errorlevel 1 exit 1

mkdir -p %LIBRARY_PREFIX%\mingw-w64\lib
cp *.a %LIBRARY_PREFIX%\mingw-w64\lib\
if errorlevel 1 exit 1

cd ..\..
cp *.a %LIBRARY_PREFIX%\mingw-w64\lib\
if errorlevel 1 exit 1

mkdir %LIBRARY_PREFIX%\mingw-w64\include\spooles
if errorlevel 1 exit 1

xcopy /s .\*.h %LIBRARY_PREFIX%\mingw-w64\include\spooles
