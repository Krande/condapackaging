gmsh-env:
	conda env create -f environment.gmsh.yml

occ-env:
	conda env create -f environment.occ.yml

pre:
	choco install visualstudio2017buildtools -y && choco install vswhere --pre -y && choco install ninja -y