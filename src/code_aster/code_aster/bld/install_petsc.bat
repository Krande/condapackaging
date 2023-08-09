REM convert the following conde build to regular batch script
set PETSC_URL=http://hg.code.sf.net/p/prereq/petsc
set PETSC_VER=3.12.3_aster
set PETSC_DIR=deps/petsc

:: download src code using mercurial
hg clone -r $PETSC_VER %PETSC_URL% %PETSC_DIR%

:: change to the directory
cd %PETSC_DIR%

@echo off
SETLOCAL EnableDelayedExpansion

REM Get an updated config.sub and config.guess
copy %BUILD_PREFIX%\share\gnuconfig\config.* .


set PETSC_ARCH=arch-conda-c-opt

set F90=
set F77=
REM set CC=
set CXX=

REM scrub debug-prefix-map args, which cause problems in pkg-config
REM Use an alternative to 'sed' here, like 'powershell' or a custom script
set CFLAGS=%CFLAGS%
set CXXFLAGS=%CXXFLAGS%
set FFLAGS=%FFLAGS%

if "%mpi%"=="openmpi" (
  set LIBS=-Wl,-rpath,%PREFIX%\lib -lmpi_mpifh -lgfortran
) else if "%mpi%"=="mpich" (
  set LIBS=-lmpifort -lgfortran
)

if "%mpi%"=="openmpi" (
  set OMPI_MCA_plm=isolated
  set OMPI_MCA_rmaps_base_oversubscribe=yes
  set OMPI_MCA_btl_vader_single_copy_mechanism=none
  set OMPI_CC=%CC%
  set OPAL_PREFIX=%PREFIX%
) else if "%mpi%"=="mpich" (
  set HYDRA_LAUNCHER=fork
)

python ./configure ^
  AR="%AR:ar%" ^
  CC="mpicc" ^
  CXX="mpicxx" ^
  FC="mpifort" ^
  CFLAGS="%CFLAGS%" ^
  CPPFLAGS="%CPPFLAGS%" ^
  CXXFLAGS="%CXXFLAGS%" ^
  FFLAGS="%FFLAGS%" ^
  LDFLAGS="%LDFLAGS%" ^
  LIBS="%LIBS%" ^
  --COPTFLAGS=-O3 ^
  --CXXOPTFLAGS=-O3 ^
  --FOPTFLAGS=-O3 ^
  --with-clib-autodetect=0 ^
  --with-cxxlib-autodetect=0 ^
  --with-fortranlib-autodetect=0 ^
  --with-debugging=0 ^
  --with-blas-lib=libblas%SHLIB_EXT% ^
  --with-lapack-lib=liblapack%SHLIB_EXT% ^
  --with-yaml=1 ^
  --with-hdf5=1 ^
  --with-fftw=1 ^
  --with-hwloc=0 ^
  --with-hypre=1 ^
  --with-metis=1 ^
  --with-mpi=1 ^
  --with-mumps=1 ^
  --with-parmetis=1 ^
  --with-pthread=1 ^
  --with-ptscotch=1 ^
  --with-shared-libraries ^
  --with-ssl=0 ^
  --with-scalapack=1 ^
  --with-superlu=1 ^
  --with-superlu_dist=1 ^
  --with-suitesparse=1 ^
  --with-x=0 ^
  --with-scalar-type=%scalar% ^
  %extra_opts% ^
  --prefix=%PREFIX%
IF ERRORLEVEL 1 (
  type configure.log
  exit /b 1
)

REM Verify that gcc_ext isn't linked
REM Continue with your script
REM ...

REM You will have to modify or find alternatives for Unix specific commands like grep, sed, uname, make, du, etc.

REM Add equivalent windows commands or utilities as needed

ENDLOCAL
