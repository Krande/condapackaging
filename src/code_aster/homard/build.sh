#!/bin/bash

set -ex

export CLICOLOR_FORCE=1

python setup_homard.py -en --prefix=${PREFIX}/bin -vmax