# LibMed Notes
Here are a few notes on the compilation of libmed.

## General
The conda-forge variants of HDF5 (latest 1.10.x on conda-forge is 1.10.6) for linux seems to be working as intended.

When attempting to compile `libmed` on windows with the conda-forge hdf5 variant (without fortran support) 
the following error is thrown:

```bash
[1255/1568] Linking CXX shared library src\libmedC.dll
FAILED: src/libmedC.dll src/libmedC.dll.a
cmd.exe /C "cd . && %BUILD_PREFIX%\Library\mingw-w64\bin\c++.exe -O3 -DNDEBUG   -shared -o src\libmedC.dll -Wl,--out-implib,src\libmedC.dll.a -Wl,--major-image-version,11,--minor-image-version,1 "Warning: corrupt .drectve at end of def file
Warning: corrupt .drectve at end of def file
Warning: corrupt .drectve at end of def file
... (this is printed a lot of times)
C:/work/mambaforge/envs/mamba-build/conda-bld/libmed_1695368212328/_h_env/Library/lib/libhdf5.lib(src/CMakeFiles/hdf5-static.dir/H5Spoint.c.obj):(.text$mn+0x249): undefined reference to `__securi'
```

As a result, we'll have to dig a bit deeper into the HDF5 requirements by `libmed`. 

It is also observed a number of failing code_aster validation tests using the mpi-variant. May this be a result 
of the HDF5 compilation?

In the official code-aster dependencies that are compiled from scratch, 
shows hdf5 is compiled with only default flags. Ie. might the thread-safety option interfere with how Code_Aster 
communicates with the hdf5 data?

## HDF5 requirements

* 1.10.2 <= HDF5 < 1.11
* HDF5 must be compiled with FORTRAN support

The windows variant on conda-forge is NOT compiled with fortran. Consequently, we'll have to compile it ourselves
and make a PR for a variant supporting fortran

### Windows compilation

#### Compilers

*Mingw64-toolchain GCC + gfortran*
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

*VS2022 + Intel Fortran Rt*
Hm, it seems these does not distribute the actual ifort.exe binaries... 
https://anaconda.org/conda-forge/intel-fortran-rt

*VS2022 + flang*
https://github.com/llvm/llvm-project/tree/main/flang/

* It seems flang classic (which I believe supports intrinsic functions) is not distributed on conda-forge?
* Flang-new is distributed as release candidates https://anaconda.org/conda-forge/flang/files]. Could test these out
* Must use a different linker than link.exe. Lld-link.exe is distributed with the llvm package

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

## Libmed Windows compilation
Once the HDF5 compilation is fixed by switching off thread safety, the compilation can proceed.

At first an issue regarding swigpy:

```
[1523/1568] Swig compile medfamily_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medfamily_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medfamily_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%SRC_DIR%\python\medfamily_module.i(26) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%SRC_DIR%\python\medfamily_module.i(27) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1524/1568] Swig compile medfilter_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medfilter_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medfilter_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1525/1568] Swig compile medlink_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medlink_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medlink_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1526/1568] Swig compile medinterp_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medinterp_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medinterp_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').

%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),

%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').

[1527/1568] Swig compile medequivalence_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medequivalence_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medequivalence_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%SRC_DIR%\python\medequivalence_module.i(36) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%SRC_DIR%\python\medequivalence_module.i(37) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1528/1568] Swig compile medfield_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medfield_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medfield_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1529/1568] Swig compile medlibrary_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medlibrary_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medlibrary_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1530/1568] Swig compile medfile_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medfile' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medfile'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1531/1568] Swig compile medlocalization_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medlocalization_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medlocalization_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1532/1568] Swig compile medparameter_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medparameter_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medparameter_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1533/1568] Swig compile medprofile_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medprofile_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medprofile_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
[1534/1568] Swig compile medmesh_module.i for python
%BUILD_PREFIX%\Library\bin\Lib\python\pyiterators.swg(0) : Warning 302: Identifier 'SwigPyIterator_medmesh_module' redefined (ignored),
%SRC_DIR%\python\pyiterators_881.i(0) : Warning 302: previous definition of 'SwigPyIterator_medmesh_module'.
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(98) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').
%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(99) : Warning 302: Identifier 'MEDCHAR' redefined (ignored) (Renamed from 'vector< char >'),

%BUILD_PREFIX%\Library\bin\Lib\std\std_alloc.i(97) : Warning 302: previous definition of 'MEDCHAR' (Renamed from 'vector< char >').

[1535/1568] Building CXX object python/CMakeFiles/_medenum.dir/med/medenum_modulePYTHON_wrap.cxx.obj
[1536/1568] Building CXX object python/CMakeFiles/_medenumtest.dir/med/medenumtest_modulePYTHON_wrap.cxx.obj
[1537/1568] Linking CXX shared module python\_medenum.pyd
FAILED: python/_medenum.pyd
cmd.exe /C "cd . && %BUILD_PREFIX%\Library\mingw-w64\bin\c++.exe -O3 -DNDEBUG   -shared -o python\_medenum.pyd -Wl,--major-image-version,0,--minor-image-version,0 python/CMakeFiles/_medenum.dir/med/medenum_modulePYTH"python/CMakeFiles/_medenum.dir/med/medenum_modulePYTHON_wrap.cxx.obj:medenum_modulePYTHON_wrap.cxx:(.text+0x23): undefined reference to `__imp_PyExc_RuntimeError'
```

Will try to recompile with a newer swig version (currently pinned to 3.0.12)