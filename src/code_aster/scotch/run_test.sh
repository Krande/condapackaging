#!/bin/bash
set -xeuo pipefail

if [[ "${PKG_NAME}" == "scotch" ]]
then

  mord -V
  gmap -V
  gord -V
  gotst -V
  gpart -V
  gscat -V

fi # scotch


if [[ "${PKG_NAME}" == "ptscotch" ]]
then

  MPIEXEC="${RECIPE_DIR}/mpiexec.sh"
  mpiexec() { $MPIEXEC $@; }

  # These `dg*` tools do not call MPI_Finalize() in some cases and then
  # Open MPI's mpiexec complain about that. Let them run in singleton
  # mode, outside of mpiexec's control, with a quick workaround for
  # docker images without `ssh`/`rsh` commands.
  export OMPI_MCA_plm_rsh_agent=false

  dggath -V
  dgmap -V
  dgord -V
  dgpart -V
  dgscat -V
  dgtst -V

  mpic++ $CXXFLAGS $LDFLAGS "-I$PREFIX/include" "-L$PREFIX/lib" "${RECIPE_DIR}/test/test_ptscotch.cxx" -o test_ptscotch -DSCOTCH_PTSCOTCH -lptscotch -lptscotcherr
  mpiexec -n 1 ./test_ptscotch

fi # ptscotch
