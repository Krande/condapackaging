#!/usr/bin/env bash

pyver=3.11

# Batch 1
parallel --halt now,fail=1 ::: \
  "cd scotch && boa build . --python=$pyver" \
  "cd metis && conda mambabuild . --python=$pyver" \
  "cd libmed && conda mambabuild . --python=$pyver" \
  "cd mfront && conda mambabuild . --python=$pyver"

# Batch 2
parallel --halt now,fail=1 ::: \
  "cd mgis && boa build . --python=$pyver" \
  "cd mumps && conda mambabuild . --python=$pyver" \
  "cd medcoupling && boa build . --python=$pyver"

# Batch 3
cd homard && boa build . --python=$pyver

# Batch 4
cd code_aster && boa build . --python=$pyver
