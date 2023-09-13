REM Install metis-aster
echo "** Building METIS **"

mkdir -p %LIBRARY_PREFIX%/metis-aster
make config prefix=%LIBRARY_PREFIX%/metis-aster
make
make install

echo "METIS Build complete"