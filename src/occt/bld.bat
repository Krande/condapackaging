set TGT_BUILD_TYPE=Release
set USE_TBB=OFF
set USE_MMGR_TYPE=""
if "%build_type%" == "debug" (
    set TGT_BUILD_TYPE=Debug
    set CFLAGS=%CFLAGS% /Od /Zi
    set CXXFLAGS=%CFLAGS% /Od /Zi
    set LDFLAGS=%LDFLAGS% /DEBUG /INCREMENTAL:NO
    :: for some reason, debug builds results in memory leaks without an alternative memory manager
    set USE_TBB=ON
    set USE_MMGR_TYPE=TBB
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
      -D USE_TBB=%USE_TBB% ^
      -D USE_MMGR_TYPE=%USE_MMGR_TYPE% ^
      -D USE_VTK:BOOL=%USE_VTK% ^
      -D 3RDPARTY_VTK_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%/lib" ^
      -D 3RDPARTY_VTK_DLL_DIR:FILEPATH="%LIBRARY_PREFIX%/bin" ^
      -D 3RDPARTY_VTK_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%/include/vtk-9.3" ^
      -D GLEW_LIBRARY:FILEPATH="%LIBRARY_PREFIX%/lib/glew32.lib" ^
      -D 3RDPARTY_TBB_DIR:FILEPATH="%LIBRARY_PREFIX%" ^
      -D VTK_RENDERING_BACKEND:STRING="OpenGL2" ^
      -D USE_FREEIMAGE:BOOL=ON ^
      -D USE_RAPIDJSON:BOOL=ON ^
      -D BUILD_RELEASE_DISABLE_EXCEPTIONS:BOOL=OFF

if errorlevel 1 exit 1

cmake --build build -- -v install

if errorlevel 1 exit 1
