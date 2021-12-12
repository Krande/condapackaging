compile_cmd=conda activate condabuild && conda-build . --python 3.9.7 -c conda-forge

build-env:
	conda env create -f environment.yml

gmsh-env:
	conda env create -f environment.gmsh.yml

occ-env:
	conda env create -f environment.occ.yml

pre:
	choco install visualstudio2017buildtools -y && \
	choco install vswhere --pre -y && \
	choco install ninja -y && \
	choco install dos2unix -y

compile:
	cd src/freetype/conda && $(compile_cmd) && \
	cd ..\..\fltk/conda && $(compile_cmd) && \
	cd ..\..\occ/conda && $(compile_cmd) && \
	cd ..\..\gmsh/conda_alt && $(compile_cmd)