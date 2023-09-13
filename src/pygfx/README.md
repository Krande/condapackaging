# Converting pypi packages to conda

## Install required packages for making conda recipe's

```bash
mamba env update -f environment.gfx.yml
```

## Create conda recipe's using grayskull

```bash
grayskull pypi pygfx pylinalg wgpu
```