:: Remove parts of the mingw64 build that are not needed
rmdir /s /q %SRC_DIR%\mingw64\opt

:: Copy the binaries to the appropriate location
xcopy /E /Y %SRC_DIR%\mingw64\* %LIBRARY_PREFIX%

:: If you want to use a different installation location
::mkdir %LIBRARY_PREFIX%\mingw64
::xcopy /E /Y %SRC_DIR%\mingw64\* %LIBRARY_PREFIX%\mingw64
