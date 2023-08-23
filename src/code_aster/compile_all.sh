#!/usr/bin/env bash

# Run this to compile all dependencies locally and finally code-aster
# Useful for iterating version changes to compilers and flags that needs to stay consistent
# across all packages

pyver=3.11

cd scotch

boa build . --python=$pyver

cd ../metis

conda mambabuild . --python=$pyver

cd ../libmed

conda mambabuild . --python=$pyver

cd ../homard

boa build . --python=$pyver

cd ../mfront

conda mambabuild . --python=$pyver

cd ../medcoupling

boa build . --python=$pyver

cd ../mumps

conda mambabuild . --python=$pyver

cd ../mgis

boa build . --python=$pyver

cd ../code_aster

boa build . --python=$pyver