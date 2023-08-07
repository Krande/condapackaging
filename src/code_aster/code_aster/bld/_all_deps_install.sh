#!/bin/bash

mkdir "temp"

cd temp

wget https://www.code-aster.org/FICHIERS/prerequisites/codeaster-prerequisites-20220817-oss.tar.gz
tar xzf codeaster-prerequisites-20220817-oss.tar.gz

cd codeaster-prerequisites-20220817-oss
make ROOT=../buildg ARCH=gcc10-openblas-seq
