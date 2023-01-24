# CondaPackaging

A repo for testing conda packaging using various compilers and methods.

## Goal
Improve understanding of the c++ compilation process and linking with python code.

## Packages subject for testing

* gmsh
* pythonocc-core
* occt
* fltk
* freetype
* ifcopenshell

 
# Resources

* http://www.johnlees.me/blog/2018/10/15/creating-a-conda-package-with-compilation-and-dependencies/

## Hunk errors related to patches on windows

Caused by git checkout on windows automatically modifying code somehow thus affecting git patches.

Error is usually reflected in patching fails with "Hunk #1 FAILED at 5 (different line endings)."

The solution seems to be 

* https://github.com/actions/checkout/issues/135 