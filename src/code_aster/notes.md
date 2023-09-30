# Notes

## Current differences between singularity installation and conda

package | singularity | conda
**python**
Singularity

## Why sysroot 2.17
Basically to enable centos 7 support. See the following links for more information:
# https://conda-forge.org/docs/maintainer/knowledge_base.html#using-centos-7

## Enable Core Dumps 
First, make sure that core dumps are enabled on your system. 
You can check the current limit by running the command `ulimit -c`. 
If the value is 0, core dumps are disabled. You can enable them by running `ulimit -c unlimited`

If you're on ubuntu you might have to turn off `Apport` before running the compilation. 
Do this by entering `sudo service apport stop` (after you're done debugging you can turn 
it back off `sudo service apport start`).

## Sysroot and cross compilation
Could this be relevant?
https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots

If this is the case it would affect the following packages:

* [mgis](./mgis/build.sh)
* [mfront](./mfront/build.sh)
* [medcoupling](./medcoupling/build.sh)

## Conda Forge

### HDF5

The following Code_Aster dependencies needs HDF5:

* libmed
* medcoupling (indirectly through libmed)

The different versions used in the compilation of Code_Aster per (30/09/2023) are:
(note! Have not yet checked how consistently the different dependencies of Code_Aster interfacing with the HDF5 c api are compiled with the same version of HDF5)

| python | version | mpi   | variant       | gcc version |
|--------|---------|-------|---------------| ----------- |
| 3.11   | 1.10.6  | False | h6a2412b_1114 | 9.3.0       |
| 3.10   | 1.10.6  | False | h6a2412b_1114 | 9.3.0       |
| 3.11   | 1.10.6  | True  | hd9270da_1014 | 9.3.0       |
| 3.10   | 1.10.6  | True  | hd9270da_1014 | 9.3.0       |