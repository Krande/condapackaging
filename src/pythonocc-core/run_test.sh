#!/bin/bash
if [ "$(uname)" == "Linux" ]; then
    cd test
    pytest -sv
    mypy test_mypy_classic_occ_bottle.py
fi
