# Need to specify bash in order for conda activate to work.
SHELL=/bin/bash
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
ACTIVATE=source $HOME/mambaforge/etc/profile.d/conda.sh ; conda activate ;
CONDA_BUILD_ACTIVATE=$(ACTIVATE) conda activate conda-build;

dev:
	mamba env update -f environment.conda.yml --prune

build:
	$(CONDA_BUILD_ACTIVATE) cd src/code_aster/mfront && ./build.sh

pre:
	choco install visualstudio2017buildtools -y && \
	choco install vswhere --pre -y && \
	choco install ninja -y && \
	choco install dos2unix -y && \
	choco install mingw -y

code-aster:
	cd src/code_aster/code_aster && \
	conda build . --python 3.11 -c krande -c conda-forge