# coding=utf-8
# --------------------------------------------------------------------
# Copyright (C) 1991 - 2023 - EDF R&D - www.code-aster.org
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
import os

conda_prefix = os.getenv('CONDA_PREFIX')

os.environ['ASTER_LIBDIR'] = conda_prefix + "/lib/aster"
os.environ['ASTER_DATADIR'] = conda_prefix + "/share/aster"
os.environ['ASTER_LOCALEDIR'] = conda_prefix + "/share/locale/aster"
os.environ['ASTER_ELEMENTSDIR'] = conda_prefix + "/lib/aster"

# import shutil
# shutil.copy('efica01a.mail', 'fort.20')

import cmath
floc = cmath.__file__
print(floc)

from code_aster.Cata.Language.SyntaxObjects import _F
import code_aster
code_aster.init()

# ----------------------------------------------------------------------------------------------------
# Possible Error-related
#
# If I enable this I will get floating point precision errors
from code_aster.Commands import *

# By enabling these explicitly, it somehow works
# from code_aster.Cata.Commands.test_fonction import TEST_FONCTION
# from code_aster.Commands import DEBUT, DEFI_LIST_ENTI, DEFI_FONCTION, FIN

# import cmath
# floc = cmath.__file__
# print(floc)

#
# End of Error-related area
# ----------------------------------------------------------------------------------------------------


DEBUT(CODE=_F(NIV_PUB_WEB="INTERNET"), DEBUG=_F(SDVERI="OUI"))

#######################################################################
# cas test du superviseur                                             #
# Il valide aussi la recuperation en poursuite des parametres python  #
# de la premiere execution en plus des concepts ASTER standards       #
#######################################################################

# import aster

# MA = LIRE_MAILLAGE(FORMAT="ASTER")
MA = code_aster.Mesh()
MA.readAsterFile('efica01a.mail')

coord = MA.getCoordinates().getValues()
assert (min(coord) == 0.0, coord)
assert (max(coord) == 0.1, coord)

conn = MA.getConnectivity()
assert MA.getNumberOfCells() == 1
assert (conn[0] == (1, 2), conn)

nommai = MA.getGroupsOfCells()
assert (nommai == ("ELN1",), nommai)

nomno = MA.getGroupsOfNodes()
assert (nomno == ("NO1", "NO2"), nomno)

UN = 1
DEUX = 2
TUP = (10.0, 11.0, 12.0, 13.0)

I02 = DEFI_LIST_ENTI(VALE=UN)
I03 = DEFI_LIST_ENTI(VALE=(5, 6, 7))

vale = I02.getValues()
assert (vale == (1,), vale)

FO3 = DEFI_FONCTION(NOM_PARA="X", NOM_RESU="Y", VALE=TUP)

# on teste la methode Valeurs de la SD fonction
# (on fait un traitement pour retrouver l'ordre du VALE)
lx, ly = FO3.Valeurs()
lv = []
for i in range(len(lx)):
    lv.append(lx[i])
    lv.append(ly[i])

# F04 est une fonction identique a F03
FO4 = DEFI_FONCTION(NOM_PARA="X", NOM_RESU="Y", VALE=lv)

TEST_FONCTION(
    VALEUR=(
        _F(VALE_CALC=11.0, VALE_PARA=10.0, FONCTION=FO4),
        _F(VALE_CALC=13.0, VALE_PARA=12.0, FONCTION=FO4),
    )
)

# on passe dans la programmation de la methode Parametres de la SD fonction
# on ne teste pas les valeurs retournees
dicpara = FO4.Parametres()
assert dicpara["PROL_DROITE"] == "EXCLU", dicpara
assert dicpara["NOM_PARA"] == "X", dicpara
assert dicpara["INTERPOL"] == ["LIN", "LIN"], dicpara

# on vérifie que la variable x sera accessible en POURSUITE
x = 34.5

FIN()
# code_aster.close()
