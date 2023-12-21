# Notes

## Github Actions Runners

https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2204-Readme.md

*Running locally*

Use act to run Github actions locally
https://github.com/nektos/act

Once installed, you would first have to pull the act docker image (ie. `docker pull catthehacker/ubuntu:act-latest`)
due to a bug https://github.com/nektos/act/issues/1983

Then to run a single job you can do `act --workflows .github/workflows/ci-ifcopenshell.yml --pull=false --env-file=.env`

## Observations

## OpenBLAS vs MKL and dependency size

The `mkl` package is almost __200MB__ compared to OpenBLAS which is only a few kB (probably a few mb given it has some
extra dependencies). 

Use `conda-forge::blas=*=openblas` to force using OpenBLAS instead of MKL.

* https://github.com/conda-forge/numpy-feedstock/issues/84

## Hunk errors related to patches on windows

Caused by git checkout on windows automatically modifying code somehow thus affecting git patches.

Error is usually reflected in patching fails with 

    Hunk #1 FAILED at 5 (different line endings).

The solution seems to be to add a `.gitattributes` file with the  `*.patch binary` option

* https://github.com/actions/checkout/issues/135 

## Other

* http://www.johnlees.me/blog/2018/10/15/creating-a-conda-package-with-compilation-and-dependencies/

## Create a conda package from a pip package

install grayskull and do `grayskull pypi <pypi-package-name>`