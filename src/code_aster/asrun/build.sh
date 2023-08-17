#!/usr/bin/env bash


python "$RECIPE_DIR/shell_exec_fix.py"

python -m pip install . --no-deps -vv --prefix=${PREFIX}

cp ${RECIPE_DIR}/config/as_run ${PREFIX}/bin/as_run
