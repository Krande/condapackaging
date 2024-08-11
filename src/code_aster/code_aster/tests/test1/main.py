# coding=utf-8

import pathlib
import time
THIS_DIR = pathlib.Path(__file__).parent

# cleanup previous files
def clean():
    for f in pathlib.Path(__file__).parent.iterdir():
        if f.name.endswith(".rmed"):
            f.unlink()
        if f.name.startswith("fort."):
            f.unlink()
        if f.name == "glob.1":
            f.unlink()
        if f.name.startswith('pick.code'):
            f.unlink()
        if f.name == "vola.1":
            f.unlink()
    # time.sleep(2)
    remaining_files = list(pathlib.Path(__file__).parent.iterdir())
    print("Remaining files:")
    for f in remaining_files:
        print(f)
    print("Cleaned up previous files")


clean()
from code_aster import CA
from code_aster.Commands import *

from math import *

# Read the Mesh
med_file = THIS_DIR / "Cantilever_CA_EIG_sh.med"
rmed_file = med_file.with_suffix(".rmed")

mesh = CA.Mesh()
mesh.readMedFile(med_file.as_posix())

# Assign mechanical properties to the different mesh groups
sh_sets = ('elMyBeam_e1_top_fl_sh', 'elMyBeam_e2_top_fl_sh', 'elMyBeam_e3_web_sh', 'elMyBeam_e4_top_fl_sh',
           'elMyBeam_e5_top_fl_sh',)
model = CA.Model(mesh)
for sh_set in sh_sets:
    model.addModelingOnGroupOfCells(CA.Physics.Mechanics, CA.Modelings.DKT, sh_set)
model.build()

# Materials
steel = CA.Material()
steel.addProperties("ELAS", E=210000000000.0, NU=0.3, RHO=7850.0)

material = CA.MaterialField(mesh)
material.addMaterialOnGroupOfCells(steel, sh_sets)
material.build()

# Shell elements:
#   EPAIS: thickness
#   VECTEUR: a direction of reference in the tangent plan

element = AFFE_CARA_ELEM(
    MODELE=model,
    COQUE=(
        _F(
            GROUP_MA=("elMyBeam_e1_top_fl_sh"),
            EPAIS=0.0135,
            VECTEUR=(0.66896473, 0.74329415, 0.0),
        ),
        _F(
            GROUP_MA=("elMyBeam_e2_top_fl_sh"),
            EPAIS=0.0135,
            VECTEUR=(0.66896473, 0.74329415, 0.0),
        ),
        _F(
            GROUP_MA=("elMyBeam_e3_web_sh"),
            EPAIS=0.0086,
            VECTEUR=(0.99583004, 0.0, 0.09122789),
        ),
        _F(
            GROUP_MA=("elMyBeam_e4_top_fl_sh"),
            EPAIS=0.0135,
            VECTEUR=(-0.66896473, 0.74329415, 0.0),
        ),
        _F(
            GROUP_MA=("elMyBeam_e5_top_fl_sh"),
            EPAIS=0.0135,
            VECTEUR=(-0.66896473, 0.74329415, 0.0),
        ),

    ),
    POUTRE=(),
)

# Boundary Conditions
# I believe bc can replace fix. But using bc in ASSEMBLAGE fails :(
bc = CA.MechanicalDirichletBC(model)
for comp in ["Dx", "Dy", "Dz", "Drx", "Dry", "Drz"]:
    bc.addBCOnNodes(getattr(CA.PhysicalQuantityComponent, comp), 0.0, "bc_nodes")
bc.build()

# fix is returned as a MechanicalLoadReal object though.. So maybe I need to do something else?
fix: CA.MechanicalLoadReal = AFFE_CHAR_MECA(
    MODELE=model, DDL_IMPO=_F(
        GROUP_NO="bc_nodes",
        DX=0, DY=0, DZ=0, DRX=0, DRY=0, DRZ=0,
    )
)

# Step Information

# How can I add shell thickness and vectors to elem_char?
elem_char = CA.ElementaryCharacteristics("elem_char", model)

# Maybe this can replace ASSEMBLAGE?
study = CA.PhysicalProblem(model, material, elem_char)
study.addDirichletBC(bc)
study.computeDOFNumbering()

# modal analysis
ASSEMBLAGE(
    MODELE=model,
    CHAM_MATER=material,
    CARA_ELEM=element,
    CHARGE=fix,
    NUME_DDL=CO('dofs_eig'),
    MATR_ASSE=(
        _F(MATRICE=CO('stiff'), OPTION='RIGI_MECA', ),
        _F(MATRICE=CO('mass'), OPTION='MASS_MECA', ),
    ),
)

# Using Subspace Iteration method ('SORENSEN' AND 'PLUS_PETITE')
# See https://www.code-aster.org/V2/UPLOAD/DOC/Formations/01-modal-analysis.pdf for more information
# Can I instantiate ModeResult directly somehow?
modes: CA.ModeResult = CALC_MODES(
    CALC_FREQ=_F(NMAX_FREQ=10, ),
    SOLVEUR_MODAL=_F(METHODE='SORENSEN'),
    MATR_MASS=mass,
    MATR_RIGI=stiff,
    OPTION='PLUS_PETITE',
    VERI_MODE=_F(STOP_ERREUR='NON')
)

num_modes = modes.getNumberOfDynamicModes()

# Is IMPR_RESU really necessary?
IMPR_RESU(
    RESU=_F(RESULTAT=modes, TOUT_CHAM='OUI'),
    UNITE=80,
    VERSION_MED="4.1.0"
)
modes.printMedFile(rmed_file.as_posix())
# Results Information

CA.close()
