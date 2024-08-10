#!/bin/bash

# Stop on first error
set -euxo pipefail

# Verify UNIX CLI tools.
if [ "${mpi}" == "nompi" ]; then
    h5_compilers=("h5c++" "h5cc" "h5fc")
else
    h5_compilers=("h5c++" "h5pcc" "h5pfc")
fi

hdf5_unix_cmds=("${h5_compilers[@]}" "h5redeploy")

if [ "${build_platform}" == "${target_platform}" ]; then
    hdf5_unix_cmds+=("h5perf_serial")
fi

for each_hdf5_unix_cmd in "${hdf5_unix_cmds[@]}"; do
    command -v "${each_hdf5_unix_cmd}" || exit 1
done

# Verify CLI tools.
hdf5_cmds=("gif2h5" "h52gif" "h5copy" "h5debug" "h5diff" "h5dump" "h5import" "h5jam" "h5ls" "h5mkgrp" "h5repack" "h5repart" "h5stat" "h5unjam")

for each_hdf5_cmd in "${hdf5_cmds[@]}"; do
    command -v "${each_hdf5_cmd}" || exit 1
done

# Verify libraries.
hdf5_libs=("hdf5" "hdf5_cpp" "hdf5_hl" "hdf5_hl_cpp")

for each_hdf5_lib in "${hdf5_libs[@]}"; do
    test -f "$PREFIX/lib/lib${each_hdf5_lib}${SHLIB_EXT}" || exit 1
done


exit 0