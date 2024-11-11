@echo off

make CC=x86_64-w64-mingw32-cc AR=x86_64-w64-mingw32-ar lib
if errorlevel 1 exit 1

cd MT\src\
make CC=x86_64-w64-mingw32-cc AR=x86_64-w64-mingw32-ar
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
