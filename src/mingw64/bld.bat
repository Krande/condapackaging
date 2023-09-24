:: Remove parts of the mingw64 build that are not needed
del /f %SRC_DIR%/mingw64/opt/*

:: Copy the binaries to the appropriate location
xcopy /E /Y %SRC_DIR%\mingw64\* %LIBRARY_PREFIX%\
