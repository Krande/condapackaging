export _OLD_CPATH=$CPATH
export _OLD_LIBRARY_PATH=$LIBRARY_PATH
export _OLD_FORTRANFLAGS=$FORTRANFLAGS

if [ -z "$CONDA_PREFIX" ]; then
    export CPATH=$CPATH:$PREFIX/include
    export LIBRARY_PATH=$LIBRARY_PATH:$PREFIX/lib
    export FORTRANFLAGS="$FORTRANFLAGS -isystem ${CONDA_PREFIX}/include"
else
    export CPATH=$CPATH:$CONDA_PREFIX/include
    export LIBRARY_PATH=$LIBRARY_PATH:$CONDA_PREFIX/lib
    export FORTRANFLAGS="$FORTRANFLAGS -isystem ${PREFIX}/include -fdebug-prefix-map=${SRC_DIR}=/usr/local/src/conda/${PKG_NAME}-${PKG_VERSION} -fdebug-prefix-map=${PREFIX}=/usr/local/src/conda-prefix"
    export FORTRANFLAGS="$FORTRANFLAGS --sysroot=$CONDA_BUILD_SYSROOT"
fi

export FFLAGS=$FORTRANFLAGS
export Fortran_FLAGS=$FORTRANFLAGS
