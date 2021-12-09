clone:
	git clone https://gitlab.onelab.info/gmsh/gmsh.git && mkdir output

lbuild:
	cp bld.bat gmsh/bld.bat && cp meta.yaml gmsh/meta.yaml && bld.bat

env:
	conda create -n condabuild -c conda-forge conda-build -y && activate condabuild

# Assuming you have activated condabuild
build:
	conda-build . --python 3.9 -c conda-forge

purge:
	conda-build purge all