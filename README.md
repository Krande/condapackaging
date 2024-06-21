# CondaPackaging

A repo for testing/developing conda packages.

## Goals
Enable faster iteration cycles for conda package development. 

Improve understanding of the c++/fortran compilation process and linking with python code using conda.

## Running locally using boa

Assuming you have pixi or Miniforge installed.

In the top level directory install the necessary pre-requisites by simply

```bash
mamba env update -f environment.conda.yml
```

To compile the package run using

```bash
conda mambabuild build . --python=3.11
```

Note that `--python` and `--croot` are optional flags. The latter comes in handy if you want to quickly browse the
work, build and test directories of your packages in your IDE. But keep the `temp` dir out of the build dir. 

## Running locally using pixi and rattler-build (experimental)

Assuming you have pixi installed.

In the top level directory install the necessary pre-requisites by simply

```bash
pixi install
```

To compile a package using run using

```bash
pixi run rmumps
```

This will try to first convert the meta.yaml to recipe.yaml (if it doesn't exist). Then try to run rattler-build on that recipe.yaml.
From experience, it rarely manages to successfully convert the meta.yaml to recipe.yaml. So you will for the most part make manual modifications on the recipe.yaml files
before trying to run rattler-build.

You can also run regular conda build commands using pixi. For example

```bash
pixi run mumps
```

Will run the regular `conda mambabuild .` command.