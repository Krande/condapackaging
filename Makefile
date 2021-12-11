env:
	conda env create -f environment.gmsh.yml

pre:
	choco install visualstudio2017buildtools -y && choco install vswhere --pre -y