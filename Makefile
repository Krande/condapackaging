gcc:
	conda env create -f environment.conda.gcc.yml

msvc:
	conda env create -f environment.conda.msvc.yml

msvc17:
	conda env create -f environment.conda.msvc17.yml

msvc19:
	conda env create -f environment.conda.msvc19.yml

pre:
	choco install visualstudio2017buildtools -y && \
	choco install vswhere --pre -y && \
	choco install ninja -y && \
	choco install dos2unix -y && \
	choco install mingw -y
