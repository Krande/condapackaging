set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /Od /Zi
    set CXXFLAGS=%CFLAGS% /Od /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

cmake -S . -B build  -G Ninja ^
    -D CMAKE_BUILD_TYPE="%TGT_BUILD_TYPE%" ^
    -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
    -D CMAKE_LIBRARY_PATH:FILEPATH="%LIBRARY_PREFIX%/lib" ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -D BUILD_SHARED_LIBS=ON


if errorlevel 1 exit 1

cmake --build build -- -v install

if errorlevel 1 exit 1