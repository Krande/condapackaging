mkdir build && cd build

REM Remove dot from PY_VER for use in library name
REM From https://github.com/tpaviot/pythonocc-core/blob/master/ci/conda/bld.bat
set MY_PY_VER=%PY_VER:.=%

set LIBXML2="%LIBRARY_PREFIX%/lib/libxml2.lib"

cmake -G "Ninja" ^
 -D CMAKE_BUILD_TYPE:STRING=Release ^
 -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D Boost_LIBRARYDIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D Boost_INCLUDEDIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D Boost_USE_STATIC_LIBS:BOOL=OFF ^
 -D OCC_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include\opencascade" ^
 -D OCC_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D COLLADA_SUPPORT:BOOL=OFF ^
 -D BUILD_EXAMPLES:BOOL=OFF ^
 -D BUILD_GEOMSERVER:BOOL=OFF ^
 -D BUILD_CONVERT:BOOL=OFF ^
 -D BUILD_IFCMAX:BOOL=OFF ^
 -D IFCXML_SUPPORT:BOOL=ON ^
 -D LIBXML2_LIBRARIES:FILEPATH=%LIBXML2% ^
 -D PYTHON_EXECUTABLE:FILEPATH=%PREFIX%/python ^
 -D PYTHON_LIBRARY:FILEPATH="%PREFIX%/libs/python%MY_PY_VER%.lib" ^
 -D GMP_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D GMP_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D HDF5_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D HDF5_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D MPFR_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 ../cmake
 
if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1