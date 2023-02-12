# Need to specify bash in order for conda activate to work.
SHELL=/bin/bash
# Note that the extra activate is needed to ensure that the activate floats env to the front of PATH
ACTIVATE=source ${HOME}/mambaforge/etc/profile.d/conda.sh ; conda activate ;
CONDA_BUILD_ACTIVATE=$(ACTIVATE) conda activate mfront-dev;
VERSION_TFEL=3.4.0

define mktemp
if [ ! -d temp ]; then \
    mkdir -p temp; \
fi
endef

dev:
	mamba env update -f environment.local.yml --prune

get:
	$(mktemp) && wget --no-check-certificate \
    https://github.com/thelfer/tfel/archive/TFEL-${VERSION_TFEL}.tar.gz \
    -O tfel.tar.gz && tar xf tfel.tar.gz -C temp && rm tfel.tar.gz

build:
	$(CONDA_BUILD_ACTIVATE) cp ./build.sh temp/tfel-TFEL-${VERSION_TFEL}/build.sh && cd temp/tfel-TFEL-${VERSION_TFEL} && ./build.sh
