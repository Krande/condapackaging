dev:
	mamba env update -f environment.conda.yml --prune

pre:
	choco install visualstudio2017buildtools -y && \
	choco install vswhere --pre -y && \
	choco install ninja -y && \
	choco install dos2unix -y && \
	choco install mingw -y
