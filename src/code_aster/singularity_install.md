# Logs from singularity installatino

## salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif

Using the recipe from https://gitlab.com/codeaster-opensource-documentation/opensource-installation-development/-/blob/main/devel/compile.md?ref_type=heads#working-within-the-container
in the container `salome_meca-lgpl-2022.1.0-1-20221225-scibian-9.sif` I got the following config and install logs:

```bash
Singularity> ./waf configure
waf install -j 4

checking environment... loading /opt/public/scibian9_mpi.sh
executing: ./waf.engine configure --out=build/mpi --jobs=4
Setting top to                           : /home/kristoffer/dev/codeaster/src
Setting out to                           : /home/kristoffer/dev/codeaster/src/build/mpi
Setting prefix to                        : /home/kristoffer/dev/codeaster/install/mpi
Checking for 'gcc' (C compiler)          : mpicc
Checking for 'g++' (C++ compiler)        : mpicxx
Checking for 'gfortran' (Fortran compiler) : mpif90
Checking C compiler package (collect configuration flags) : yes
Checking Fortran compiler package (collect configuration flags) : yes
Checking for header mpi.h                : yes
Checking for C compiler version          : gcc 8.3.0
Checking for Fortran compiler version    : gfortran 8.3.0
fortran link verbose flag                : -v
Checking for OpenMP flag -fopenmp        : yes
Checking for program 'python'            : /opt/python/3.6.5/bin/python3
Checking for python version >= 3.5.0     : 3.6.5
python-config                            : /opt/python/3.6.5/bin/python3-config
Asking python-config for pyembed '--cflags --libs --ldflags --embed' flags : not found
Asking python-config for pyembed '--cflags --libs --ldflags' flags : yes
Testing pyembed configuration            : yes
Asking python-config for pyext '--cflags --libs --ldflags' flags : yes
Testing pyext configuration              : yes
Checking for python module 'yaml'        : not found
Checking for python module 'numpy'       : 1.15.1
Checking for numpy include               : ['/opt/numpy/1.15.1/lib/python3.6/site-packages/numpy-1.15.1-py3.6-linux-x86_64.egg/numpy/core/include']
Checking for python module 'asrun'       : 2021.0
Checking for python module 'mpi4py'      : 3.0.3
Getting platform                         : ASTER_PLATFORM_LINUX64
Checking for 'gfortran' (Fortran compiler) : mpif90
Compiling a simple fortran app           : yes
Detecting whether we need a dummy main   : yes main
Checking for fortran option              : yes (-fPIC)
Checking for fortran option              : yes (-fdefault-double-8 -fdefault-integer-8 -fdefault-real-8)
Checking for fortran option              : yes (-Wimplicit-interface)
Checking for fortran option              : yes (-Wintrinsic-shadow)
Checking for fortran option              : yes (-fno-aggressive-loop-optimizations)
Checking for fortran option              : yes (-ffree-line-length-none)
Fortran compiler flags                   : ['-fPIC', '-fdefault-double-8', '-fdefault-integer-8', '-fdefault-real-8', '-Wimplicit-interface', '-Wintrinsic-shadow', '-fno-aggressive-loop-optimizations', '-ffree-line-length-none']
Getting fortran mangling scheme          : ok ('_', '', 'lower-case')
Checking size of integer4                : 4
Checking the matching C type             : int
Checking size of default integer         : 8
Checking the matching C type             : long
Checking size of logical                 : 1
Checking size of simple precision real   : 4
Checking the matching C type             : float
Checking size of double precision real   : 8
Checking the matching C type             : double
Checking size of double complex          : 16
Setting type for fortran string length   : unsigned int
Setting size of blas/lapack integers     : 4
Checking size of MPI_Fint integers       : 4
Checking fpp stringify using #           : no
Checking fpp stringify using ""          : yes
Checking compilation with long lines     : yes
Check for backtrace feature              : yes
Check for tracebackqq feature            : no
Checking for 'g++' (C++ compiler)        : mpicxx
Checking for C++ option                  : yes (-fPIC)
Checking for C++ option                  : yes (-std=c++17)
Checking for C++ option                  : yes (-Wno-attributes)
C++ compiler flags                       : ['-fPIC', '-std=c++17', '-Wno-attributes']
Checking for library stdc++              : yes
Checking size of C++ bool                : 1
Checking for 'gcc' (C compiler)          : mpicc
Checking for C option                    : yes (-fPIC)
C compiler flags                         : ['-fPIC']
Checking for library m                   : yes
Checking for library z                   : yes
Checking for number of cores             : 12
Checking for program 'ldd'               : /usr/bin/ldd
Checking for library openblas            : yes
Checking for a program using blas/lapack : yes
Checking for library scalapack           : yes
Checking for library cblas               : not found
Checking for a program using blas/lapack : yes
Checking for a program using blacs       : yes
Checking for a program using omp thread  : yes (on 12 threads)
Detected math libraries                  : ['openblas', 'scalapack']
Setting libm after files                 : nothing done
Checking for library hdf5                : yes
Checking for header hdf5.h               : yes
Checking hdf5 version                    : 1.10.9
Checking for API hdf5 v18                : default v18
Checking size of hid_t integers          : 8
Checking for library med                 : yes
Checking for header med.h                : yes
Checking size of med_int integers        : 8
Checking size of med_idt integers        : 8
Checking med version                     : 4.1.1
Checking for python module 'med'         : ok
Checking for python module 'medcoupling' : unknown
Checking for library metis               : yes
Checking for header metis.h              : yes
Checking for header GKlib.h              : yes
Checking metis version                   : 5.1.0
Checking for library parmetis            : yes
Checking parmetis version                : 4.0.3
Checking for smumps_struc.h              : yes
Checking for dmumps_struc.h              : yes
Checking for cmumps_struc.h              : yes
Checking for zmumps_struc.h              : yes
Checking for mpif.h                      : yes
Checking mumps version                   : 5.5.1c
Checking size of Mumps integer           : 4
Checking for library dmumps              : yes
Checking for library zmumps              : yes
Checking for library smumps              : yes
Checking for library cmumps              : yes
Checking for library mumps_common        : yes
Checking for library pord                : yes
Checking for header scotch.h             : yes
Checking scotch version                  : 7.0.1
Checking for library ['esmumps', 'scotch', 'scotcherr', 'ptscotch', 'ptscotcherr'] : yes
Checking for library ml                  : yes
Checking for library HYPRE               : yes
Checking for library superlu             : yes
Checking for library slepc               : yes
Checking for library hpddm_petsc         : yes
Checking for library stdc++              : yes
Checking for library petsc               : yes
Checking for header petsc.h              : yes
Checking for header petscconf.h          : yes
Checking petsc version                   : 3.17.1p0
Checking size of PETSc integer           : 4
Checking value of ASTER_PETSC_64BIT_INDICES : no
Checking value of ASTER_PETSC_HAVE_ML    : 1
Checking value of ASTER_PETSC_HAVE_HYPRE : 1
Checking value of ASTER_PETSC_HAVE_SUPERLU : 1
Checking value of ASTER_PETSC_HAVE_MUMPS : 1
Checking for python module 'petsc4py'    : 3.17.1
Reading user prefs from /home/kristoffer/.config/aster/config.yaml : not found
Reading user prefs from /home/kristoffer/.config/aster/config.json : not found
Reading user prefs from /home/kristoffer/.hgrc : not found
Checking for program 'git'               : /usr/bin/git
Checking for header MGIS/Config-c.h      : yes
Checking for header MGIS/Behaviour/Behaviour.hxx : yes
Checking for header MGIS/Behaviour/BehaviourData.hxx : yes
Checking for header MGIS/Behaviour/Integrate.hxx : yes
Checking for code snippet                : yes
Checking for program 'mpiexec'           : /usr/bin/mpiexec
Check for mpiexec flag '-n N'            : yes
Check for mpiexec flag '--tag-output'    : yes
Check for mpiexec flag '-print-rank-map' : no
Check for mpiexec flag '-prepend-rank'   : no
Check for mpiexec flag '-ordered-output' : no
Check for MPI rank variable              : echo ${OMPI_COMM_WORLD_RANK}
Checking for code snippet                : yes
Checking for code snippet                : no
Checking for code snippet                : no
Checking for code snippet                : yes
Checking for code snippet                : yes
Checking for code snippet                : yes
'configure' finished successfully (43.131s)
Singularity> ./waf install -j 4
checking environment... loading /opt/public/scibian9_mpi.sh
executing: ./waf.engine install -j 4 --out=build/mpi --jobs=4
```
