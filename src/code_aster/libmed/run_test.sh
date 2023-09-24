#!/bin/bash

if [[ -z $(nm -D $CONDA_PREFIX/lib/libmed.so | grep MEDlibraryNumVersion) ]]; then
  echo "MEDlibraryNumVersion is not present in libmed.so";
  exit 1;
fi