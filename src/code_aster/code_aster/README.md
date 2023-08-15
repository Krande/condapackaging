# Compiling Code Aster

# V15.8.0



## Official deps

* [v15.8.0 Singularity env](https://gitlab.com/codeaster/src/-/blob/15.8.0/env.d/scibian9_std.sh?ref_type=tags)
* v16.4.2:

```
VERSION="20221225"

HDF5="1.10.9"
MED="4.1.1"
METIS="5.1.0_aster4"
PARMETIS="4.0.3_aster3"
MFRONT="4.1.0" # prefix 'TFEL-' added in build script
# MFRONT_SHA=""
MGIS="2.1-dev" # prefix 'MFrontGenericInterfaceSupport-' added in build script
MGIS_SHA="995ea8d"
HOMARD="11.12_aster2"
SCOTCH="7.0.1" # prefix 'v' added in build script
SCALAPACK="2.1.0"
MUMPS="5.5.1_consortium_aster1"
MUMPS_GPL="5.5.1_aster1"
PETSC="3.17.1_aster"
_HPDDM="b9ae0dc6cf88af52b1572b990f8b1731cabceaaf"
_HYPRE="v2.24.0"
_ML="v13.2.0"
_SOWING="v1.1.26-p4"
_SPLEC="aa5f86854e5d457ce6ff5041b1c308588ba71c25"
_SUPERLU="v5.3.0"
MISS3D="6.7_aster7"
MPI4PY="3.1.3"
MEDCOUPLING="V9_10_0"
_CONFIGURATION="V9_10_0"
ECREVISSE="3.2.2"
ECREVISSE_GPL="None"
GMSH="4.10.5-Linux64"
GRACE="0.0.1"
ASRUN="2021.0.0-1"
```

```
VERSION="20220817"

HDF5="1.10.9"
MED="4.1.1"
METIS="5.1.0_aster4"
PARMETIS="4.0.3_aster3"
MFRONT="3.4.3" # prefix 'TFEL-' added in build script
HOMARD="11.12_aster2"
SCOTCH="6.1.2" # prefix 'v' added in build script
SCALAPACK="2.1.0"
MUMPS="5.4.1_consortium_aster2"
MUMPS_GPL="5.4.1_aster"
PETSC="3.17.1_aster"
_HPDDM="b9ae0dc6cf88af52b1572b990f8b1731cabceaaf"
_HYPRE="v2.24.0"
_ML="v13.2.0"
_SOWING="v1.1.26-p4"
_SPLEC="aa5f86854e5d457ce6ff5041b1c308588ba71c25"
_SUPERLU="v5.3.0"
MISS3D="6.7_aster7"
MPI4PY="3.1.3"
MEDCOUPLING="V9_9_0a2"
_CONFIGURATION="V9_9_0a2"
ECREVISSE="3.2.2"
ECREVISSE_GPL="None"
GMSH="4.10.5-Linux64"
GRACE="0.0.1"
ASRUN="2021.0.0-1"

RESTRICTED=0
```

## Enable Core Dumps 
First, make sure that core dumps are enabled on your system. 
You can check the current limit by running the command ulimit -c. 
If the value is 0, core dumps are disabled. You can enable them by running ulimit -c unlimited

If you're on ubuntu you might have to turn off `Apport` before running the compilation. 
Do this by entering `sudo service apport stop` (after you're done debugging you can turn 
it back off `sudo service apport start`).
