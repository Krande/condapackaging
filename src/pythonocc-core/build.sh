#!/bin/bash
# make an in source build do to some problems with install


# Configure step
cmake -G Ninja \
  -DPYTHONOCC_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_LIBRARY_PATH:FILEPATH="$PREFIX/lib" \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_SYSTEM_PREFIX_PATH=$PREFIX \
  ${CMAKE_PLATFORM_FLAGS[@]} \
  -DPYTHONOCC_MESHDS_NUMPY=ON \
  -DPython3_FIND_STRATEGY=LOCATION \
  -DPython3_FIND_FRAMEWORK=NEVER \
  -DSWIG_HIDE_WARNINGS=ON \
  -Wno-dev \
  -DPYTHONOCC_VERSION=$OCCT_VERSION \
  .

# Build step
ninja

# Install step
ninja install
