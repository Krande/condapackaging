#!/usr/bin/env bash

# Exit immediately if any command exits with a non-zero status
set -e

# Run this to compile all dependencies locally and finally code-aster
# Useful for iterating version changes to compilers and flags that needs to stay consistent
# across all packages

mpi=true
pyver=3.11

# Function to build a package
build_package() {
  package=$1
  pyver=$2
  conda mambabuild $package --python=$pyver
}

# No-MPI group
build_package "asrun" $pyver &
build_package "mgis" $pyver &
build_package "metis" $pyver &
build_package "mfront" $pyver &
build_package "homard" $pyver &

conda mambabuild scotch --python=$pyver

conda mambabuild metis --python=$pyver

conda mambabuild homard --python=$pyver

conda mambabuild parmetis --python=$pyver

conda mambabuild libmed --python=$pyver

conda mambabuild mfront --python=$pyver

conda mambabuild mumps --python=$pyver

conda mambabuild mgis --python=$pyver

conda mambabuild petsc --python=$pyver

conda mambabuild medcoupling --python=$pyver

conda mambabuild build code_aster --python=$pyver