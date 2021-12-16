mkdir build && cd build

set MY_PY_VER=%PY_VER:.=%

set LIBXML2="%LIBRARY_PREFIX%/lib/libxml2.lib"

cmake -G "Ninja" ^
 -D CMAKE_BUILD_TYPE:STRING=Release ^
 -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D OCC_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include\opencascade" ^
 -D OCC_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D CGAL_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D GMP_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D MPFR_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D HDF5_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D HDF5_LIBRARY_DIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D PYTHON_EXECUTABLE:FILEPATH=%PYTHON% ^
 -D COLLADA_SUPPORT:BOOL=OFF ^
 -D BUILD_EXAMPLES:BOOL=OFF ^
 -D BUILD_GEOMSERVER:BOOL=OFF ^
 -D BUILD_CONVERT:BOOL=OFF ^
 -D BUILD_IFCMAX:BOOL=OFF ^
 -D IFCXML_SUPPORT:BOOL=ON ^
 -D LIBXML2_INCLUDE_DIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D LIBXML2_LIBRARIES:FILEPATH=%LIBXML2% ^
 -D Boost_LIBRARYDIR:FILEPATH="%LIBRARY_PREFIX%\lib" ^
 -D Boost_INCLUDEDIR:FILEPATH="%LIBRARY_PREFIX%\include" ^
 -D Boost_USE_STATIC_LIBS:BOOL=OFF ^
 %SRC_DIR%/cmake

if errorlevel 1 exit 1

:: Build and install
cmake --build . -- install

if errorlevel 1 exit 1
