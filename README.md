# CondaPackaging

A repo for testing/developing conda packages.

## Goals
Enable faster iteration cycles for conda package development. 

Improve understanding of the c++/fortran compilation process and linking with python code using conda.

## Running locally using Boa/MambaBuild

Assuming you have mambaforge (or an equivalent conda installation).

In the top level directory install the necessary pre-requisites by simply

```bash
mamba env update -f environment.conda.yml
```

Go to the subdirectory of choice and find whichever subdirectory with a `recipe.yaml` file 
(or if it only has a meta.yaml file you might be able to convert it by simply doing `boa convert meta.yaml>recipe.yaml`)

To compile the package run using

```bash
boa build . --python=3.11
```

or

```bash
conda mambabuild . --python=3.11
```

Note that `--python` and `--croot` are optional flags. The latter comes in handy if you want to quickly browse the
work, build and test directories of your packages in your IDE. But keep the `temp` dir out of the build dir. 
