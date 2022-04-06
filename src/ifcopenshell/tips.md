# Ifcopenshell Compilation

Opened [issue](https://github.com/IfcOpenShell/IfcOpenShell/issues/1949) to investigate errors in build. 

## Things to consider


### Edits to CMAKE file

Try to split up cmake using ExternalProjects and embed downloads of includes into the cmake file.

* https://cmake.org/cmake/help/latest/module/ExternalProject.html

### Conda-build slow post step on macOS


* https://github.com/pytorch/pytorch/issues/58534
* https://github.com/lief-project/LIEF/pull/579
* 
pip install [--user] --index-url https://lief.s3-website.fr-par.scw.cloud/latest lief==0.13.0.dev0