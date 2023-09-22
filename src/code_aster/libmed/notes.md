# LibMed Notes

## General


`The HDF5 library version used by med-fichier4.y.z MUST NOT be > 1.10 and have to be at least HDF5-1.10.2.`


Compiling with the conda-forge hdf5 variant results in the following error:

```bash
[1255/1568] Linking CXX shared library src\libmedC.dll
FAILED: src/libmedC.dll src/libmedC.dll.a
cmd.exe /C "cd . && %BUILD_PREFIX%\Library\mingw-w64\bin\c++.exe -O3 -DNDEBUG   -shared -o src\libmedC.dll -Wl,--out-implib,src\libmedC.dll.a -Wl,--major-image-version,11,--minor-image-version,1 "Warning: corrupt .drectve at end of def file
Warning: corrupt .drectve at end of def file
Warning: corrupt .drectve at end of def file
... (this is printed a lot of times)
C:/work/mambaforge/envs/mamba-build/conda-bld/libmed_1695368212328/_h_env/Library/lib/libhdf5.lib(src/CMakeFiles/hdf5-static.dir/H5Spoint.c.obj):(.text$mn+0x249): undefined reference to `__securi'
```

## Windows Compilation

Combination of cxx,c++ and fortran compilers:

### Mingw64-toolchain GCC + gfortran
This seems to be the most promising combination.

I was able to compile HDF5 1.10.9* with this toolchain, however it was only possible by changing
the following cmake options:

```bash
# cmake args
-D HDF5_ENABLE_THREADSAFE:BOOL=ON ^ ->  -D HDF5_ENABLE_THREADSAFE:BOOL=OFF ^
```

OR 

```bash
# cmake args
-D HDF5_ENABLE_THREADSAFE:BOOL=ON ^
```



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