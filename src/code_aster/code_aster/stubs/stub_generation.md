# Stubs

To ensure proper type hints in your IDE, one way could be to manually generate stubs for the code_aster
using either mypy stubgen or the pybind11 stubgen.

## pybind11 stubgen
Building on the work in https://github.com/sizmailov/pybind11-stubgen 

With the recent release of v1.1 it works wonderfully.

Will only add pyi for the binary modules, such as (a work in progress list):

* libaster

Will make this a part of the build process.