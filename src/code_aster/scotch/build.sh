#!/bin/bash


cp $RECIPE_DIR/Makefile.inc.x86-64_pc_linux2 src/Makefile.inc

cd src

make scotch
make esmumps

make install prefix=${PREFIX}
