gcc:
	conda env create -f environment.conda.gcc.yml

msvc:
	conda env create -f environment.conda.msvc.yml

pre:
	choco install visualstudio2017buildtools -y && \
	choco install vswhere --pre -y && \
	choco install ninja -y && \
	choco install dos2unix -y && \
	choco install mingw -y
