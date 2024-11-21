# CondaPackaging

A repository for testing/developing conda packages related to ada-py and hub for building debug-variants of conda packages otherwise
found on conda-forge.

## Build conda packages locally

Assuming you have pixi installed. From the root directory;

To compile a package using rattler-build (in this example [mumps](src/code_aster/mumps)) you can use

```bash
pixi run -e rattler mumps
``` 

Or to compile using boa (`conda mambabuild`) use

```bash
pixi run -e boa mumps
```