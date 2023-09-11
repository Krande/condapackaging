#!/usr/bin/env bash

# Exit immediately if any command exits with a non-zero status
set -e

# Run this to compile all dependencies locally and finally code-aster
# Useful for iterating version changes to compilers and flags that needs to stay consistent
# across all packages

mpi=true
pyver=3.11

conda mambabuild scotch --python=$pyver

conda mambabuild metis --python=$pyver

if [[ $mpi ]]; then
  conda mambabuild parmetis --python=$pyver
fi

conda mambabuild libmed --python=$pyver

conda mambabuild homard --python=$pyver

conda mambabuild mfront --python=$pyver

conda mambabuild medcoupling --python=$pyver

conda mambabuild mumps --python=$pyver

conda mambabuild mgis --python=$pyver

conda mambabuild build code_aster --python=$pyver