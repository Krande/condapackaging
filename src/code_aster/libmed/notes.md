# LibMed Notes

## General


`The HDF5 library version used by med-fichier4.y.z MUST NOT be > 1.10 and have to be at least HDF5-1.10.2.`



## Windows Compilation

Combination of cxx,c++ and fortran compilers:

### VS2022 + Mingw64-gfortran

### VS2022 + Intel Fortran Rt
Hm, it seems these does not distribute the actual ifort.exe binaries... 
https://anaconda.org/conda-forge/intel-fortran-rt

### VS2022 + flang

https://github.com/llvm/llvm-project/tree/main/flang/

From compilation of HDF5 1.10.9*
```

-- Found Threads: TRUE
-- The Fortran compiler identification is Flang 99.99.1
-- Detecting Fortran compiler ABI info
-- Detecting Fortran compiler ABI info - done
-- Check for working Fortran compiler: C:/work/mambaforge/envs/mamba-build/conda-bld/hdf5_1695298476924/_build_env/Library/bin/flang.exe - skipped
-- Detecting Fortran/C Interface
-- Detecting Fortran/C Interface - Found GLOBAL and MODULE mangling
-- Performing Test H5_FORTRAN_HAVE_SIZEOF
-- Performing Test H5_FORTRAN_HAVE_SIZEOF - Failed
-- Performing Test H5_FORTRAN_HAVE_C_SIZEOF
-- Performing Test H5_FORTRAN_HAVE_C_SIZEOF - Failed
-- Performing Test H5_FORTRAN_HAVE_STORAGE_SIZE
-- Performing Test H5_FORTRAN_HAVE_STORAGE_SIZE - Failed
-- Performing Test H5_HAVE_ISO_FORTRAN_ENV
-- Performing Test H5_HAVE_ISO_FORTRAN_ENV - Failed
-- Performing Test H5_FORTRAN_DEFAULT_REAL_NOT_DOUBLE
-- Performing Test H5_FORTRAN_DEFAULT_REAL_NOT_DOUBLE - Failed
-- Performing Test H5_FORTRAN_HAVE_ISO_C_BINDING
-- Performing Test H5_FORTRAN_HAVE_ISO_C_BINDING - Failed
-- Performing Test FORTRAN_HAVE_C_LONG_DOUBLE
-- Performing Test FORTRAN_HAVE_C_LONG_DOUBLE - Failed
-- Performing Test FORTRAN_C_LONG_DOUBLE_IS_UNIQUE
-- Performing Test FORTRAN_C_LONG_DOUBLE_IS_UNIQUE - Failed
CMake Error at config/cmake/HDF5UseFortran.cmake:121 (message):
  Fortran compiler requires either intrinsic functions SIZEOF or STORAGE_SIZE
Call Stack (most recent call first):
  CMakeLists.txt:1054 (include)
```