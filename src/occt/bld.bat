set TGT_BUILD_TYPE=Release
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /Od /Zi
    set CXXFLAGS=%CFLAGS% /Od /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
)

if "%variant%" == "novtk" (
    set USE_VTK=OFF
) else (
    set USE_VTK=ON
)

cmake -S . -B build  -G Ninja ^
      -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_LIBRARY_PATH:FILEPATH="%LIBRARY_PREFIX%/lib" ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
      -D INSTALL_DIR_LAYOUT="Unix" ^
      -D BUILD_MODULE_Draw=OFF ^
      -D 3RDPARTY_DIR:FILEPATH="%LIBRARY_PREFIX%" ^
      -D CMAKE_BUILD_TYPE="%TGT_BUILD_TYPE%" ^
      -D USE_TBB=OFF ^
      -D BUILD_RELEASE_DISABLE_EXCEPTIONS=OFF ^
      -D USE_VTK:BOOL=%USE_VTK% ^
      -D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%/lib" ^
      -D 3RDPARTY_VTK_DLL_DIR:FILEPATH="%LIBRARY_PREFIX%/bin" ^
      -D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%/include/vtk-9.3" ^
      -D VTK_RENDERING_BACKEND:STRING="OpenGL2" ^
      -D GLEW_LIBRARY:FILEPATH="%LIBRARY_PREFIX%/lib/glew32.lib" ^
      -D TBB_LIBRARY_RELEASE:FILEPATH="%LIBRARY_PREFIX%/lib/tbb.lib" ^
      -D USE_FREEIMAGE:BOOL=ON ^
      -D USE_RAPIDJSON:BOOL=ON ^
      -D BUILD_RELEASE_DISABLE_EXCEPTIONS:BOOL=OFF

if errorlevel 1 exit 1

cmake --build build -- -v install

if errorlevel 1 exit 1

:: Move the outputs from bind and libd (or bini and libi for relwithdebuginfo) to bin and lib
if "%TGT_BUILD_TYPE%" == "Debug" (
    move /Y "%LIBRARY_PREFIX%\libd\*" "%LIBRARY_PREFIX%\lib\"
    rmdir /S /Q "%LIBRARY_PREFIX%\libd"
    move /Y "%LIBRARY_PREFIX%\bind\*" "%LIBRARY_PREFIX%\bin\"
    rmdir /S /Q "%LIBRARY_PREFIX%\bind"
) else if "%TGT_BUILD_TYPE%" == "RelWithDebInfo" (
    move /Y "%LIBRARY_PREFIX%\libi\*" "%LIBRARY_PREFIX%\lib\"
    move /Y "%LIBRARY_PREFIX%\bini\*" "%LIBRARY_PREFIX%\bin\"
)