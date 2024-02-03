# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2024 - EDF R&D - www.code-aster.org
# This file is part of code_aster.
#
# code_aster is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# code_aster is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with code_aster.  If not, see <http://www.gnu.org/licenses/>.
# --------------------------------------------------------------------

"""
This is the main entry point for the users.

:py:mod:`code_aster.Commands` is the high level user interface.
It provides the *Commands*.

:py:mod:`code_aster.CA` is a lower level interface that gives access the
*DataStructure* objects (and also *Commands* for convenience).

Standard users should use the high level interface:

.. code-block:: python

    >>> import code_aster
    >>> from code_aster.Commands import *
    >>> DEBUT()
    >>> mesh = LIRE_MAILLAGE(...)

Note::
    The first two lines that import :py:mod:`code_aster` and all commands from
    :py:mod:`code_aster.Commands` are automatically inserted in the user commands
    file by `run_aster`.

The lower level user interface is used as:

.. code-block:: python

    >>> import code_aster
    >>> from code_aster import CA
    >>> mesh = CA.Mesh()
    >>> mesh.readMedFile(...)

See :py:mod:`code_aster.rc` object to adjust the initialization parameters.

Here is the diagram of the package organization:

.. image:: ../../img/diagr_code_aster.png
   :align: center

"""

# image generated with:
#   diagr_import --pkg --grp -g doc/img/diagr_code_aster.png \
#       code_aster/**/*.py

import os

# To eliminate need for activation scripts during conda runtime
_CONDA_PREFIX = os.getenv('CONDA_PREFIX', None)
_CONDA_BUILD = os.getenv('COMPILING_CONDA', None)
if _CONDA_PREFIX is not None and _CONDA_BUILD != "True":
    os.environ['ASTER_ELEMENTSDIR'] = os.getenv('CONDA_PREFIX') + '/lib/aster'

try:
    # embedded modules must be imported before libaster
    # because there are set up by initAsterModules
    import aster
    import aster_core
    import aster_fonctions
    import med_aster
    import libaster

    # setup, do not keep references here...
    del aster, aster_core, aster_fonctions, med_aster, libaster

    # ... except for rc and package info
    from .Utilities.rc import rc
    from .Utilities.version import __version__
except ImportError as e:
    print(f"ImportErrors: '{e}'")
    # AsterStudy only uses code_aster/Cata without the extensions modules (.so).
    # So, the exception is only raised during the building process.
    if os.environ.get("WAFLOCK"):
        raise

del os
