COPY /y %RECIPE_DIR%\config\setup_homard.py %SRC_DIR%\setup_homard.py

python setup_homard.py -en --prefix=${LIBRARY_PREFIX}/bin -vmax # [win]