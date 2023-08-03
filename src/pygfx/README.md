# Copying pypi packages to conda

## Install needed packages

```bash
mamba env update -f environment.gfx.yml
```

## Build the packages using grayskull

```bash
grayskull pypi pygfx pylinalg wgpu
```