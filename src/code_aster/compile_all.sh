#!/usr/bin/env bash

# Exit immediately if any command exits with a non-zero status
set -e

# Run this to compile all dependencies locally and finally code-aster
# Useful for iterating version changes to compilers and flags that needs to stay consistent
# across all packages

pyver=3.11

#boa build scotch --python=$pyver

conda mambabuild metis --python=$pyver

conda mambabuild libmed --python=$pyver

boa build homard --python=$pyver

#conda mambabuild mfront --python=$pyver

boa build medcoupling --python=$pyver

conda mambabuild mumps --python=$pyver

boa build mgis --python=$pyver

boa build code_aster --python=$pyver