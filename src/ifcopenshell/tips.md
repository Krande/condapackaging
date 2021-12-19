# Ifcopenshell Compilation

Opened [issue](https://github.com/IfcOpenShell/IfcOpenShell/issues/1949) to investigate errors in build. 

## Things to consider


### Edits to CMAKE file

Try to split up cmake using ExternalProjects and embed downloads of includes into the cmake file.

* https://cmake.org/cmake/help/latest/module/ExternalProject.html
