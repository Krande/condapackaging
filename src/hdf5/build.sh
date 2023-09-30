#!/bin/bash
set -ex

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  echo "Conda is cross compiling!"
fi

if [[ "${PKG_DEBUG}" == "True" ]]; then
    opt+=( "--enable-build-mode=debug" )
fi

if [ "${mpi}" != "nompi" ]; then
    opts=( "--enable-parallel" )
fi

# if gfortran version > 8, we need to conditionally add -fallow-argument-mismatch
# to avoid mismatch errors related to floats and integer types
major_version=$($FC -dumpversion | awk -F. '{print $1}')
if [[ $major_version -gt 9 ]]; then
  export FCFLAGS="-fallow-argument-mismatch ${FCFLAGS}"
else
  # -fallow-argument-mismatch is not supported by gfortran <= 8
#  export FCFLAGS=" ${FCFLAGS}"
  echo "FCFLAGS: $FCFLAGS"
fi

./configure "${opts[@]}" --prefix="${PREFIX}"

make -j "${CPU_COUNT}"
make install V=1