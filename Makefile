mingw:
	conda env create -f environment.conda.mingw.yml

mvc:
	conda env create -f environment.conda.mvc.yml

pre:
	choco install visualstudio2017buildtools -y && \
	choco install vswhere --pre -y && \
	choco install ninja -y && \
	choco install dos2unix -y && \
	choco install mingw -y
