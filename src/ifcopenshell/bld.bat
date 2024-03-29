set CLICOLOR_FORCE=1

mkdir build && cd build

set MY_PY_VER=%PY_VER:.=%
set LIBXML2="%LIBRARY_PREFIX%/lib/libxml2.lib"

rem Overwrite the CMakeLists.txt file with the one from the config folder (which has a fix for finding hdf5 and zlibs)
set FILE1="%RECIPE_DIR%\config\CMakeLists.txt"
set FILE2="%SRC_DIR%\cmake\CMakeLists.txt"
xcopy "%FILE1%" "%FILE2%" /Y

echo %CC%
echo %CXX%
echo "VS_VERSION=%VS_VERSION%
echo "VS_MAJOR=%VS_MAJOR%
echo "VS_YEAR=%VS_YEAR%
echo "CL_FULL_PATH=%CL_FULL_PATH%

cmake -G "Ninja" ^
 -Wno-dev ^
 -D SCHEMA_VERSIONS="2x3;4;4x1;4x3_add1" ^
 -D CMAKE_BUILD_TYPE:STRING=Release ^
 -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D CMAKE_SYSTEM_PREFIX_PATH:FILEPATH="%LIBRARY_PREFIX%" ^
 -D OCC_INCLUDE_DIR:FILEPATH="%LIBRARY_INC%\opencascade" ^
 -D OCC_LIBRARY_DIR:FILEPATH="%LIBRARY_LIB%" ^
 -D CGAL_INCLUDE_DIR:FILEPATH="%LIBRARY_INC%" ^
 -D GMP_INCLUDE_DIR:FILEPATH="%LIBRARY_INC%" ^
 -D GMP_LIBRARY_DIR:FILEPATH="%LIBRARY_LIB%" ^
 -D MPFR_LIBRARY_DIR:FILEPATH="%LIBRARY_LIB%" ^
 -D COLLADA_SUPPORT=OFF ^
 -D HDF5_SUPPORT=ON ^
 -D HDF5_INCLUDE_DIR="%LIBRARY_INC%" ^
 -D HDF5_LIBRARY_DIR="%LIBRARY_LIB%" ^
 -D JSON_INCLUDE_DIR="%LIBRARY_INC%" ^
 -D PYTHON_INCLUDE_DIR=%PREFIX%\include ^
 -D PYTHON_EXECUTABLE:FILEPATH=%PREFIX%\python.exe ^
 -D PYTHON_LIBRARY:FILEPATH="%PREFIX%"\libs/python%MY_PY_VER%.lib ^
 -D BUILD_IFCPYTHON=ON ^
 -D BUILD_IFCGEOM=ON ^
 -D COLLADA_SUPPORT:BOOL=OFF ^
 -D BUILD_EXAMPLES:BOOL=OFF ^
 -D BUILD_GEOMSERVER:BOOL=OFF ^
 -D GLTF_SUPPORT:BOOL=ON ^
 -D BUILD_CONVERT:BOOL=ON ^
 -D BUILD_IFCMAX:BOOL=OFF ^
 -D IFCXML_SUPPORT:BOOL=ON ^
 -D Boost_LIBRARYDIR:FILEPATH="%LIBRARY_LIB%" ^
 -D Boost_INCLUDEDIR:FILEPATH="%LIBRARY_INC%" ^
 -D Boost_USE_STATIC_LIBS:BOOL=OFF ^
 %SRC_DIR%/cmake

if errorlevel 1 exit 1

:: Build and install
cmake --build . -- install

if errorlevel 1 exit 1