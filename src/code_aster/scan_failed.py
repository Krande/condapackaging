import pathlib

resutest_dir = pathlib.Path(__file__).parent / "resutest"
last_failed = resutest_dir / "Testing/Temporary/LastTestsFailed.log"
aster_ver = '16.4.2'


fail_messages = [
    "Le fichier xmgrace n'existe pas",
    "La commande CALC_ERC_DYN ne peut fonctionner que sur des maillages ne contenant que des SEG2",
    "tldlg3.F90, ligne 356",
    "Échec de la factorisation de Cholesky: la matrice n'est pas symétrique définie positive"
]


for fail_msg in fail_messages:
    num = 0
    failed_due_to = []
    with open(last_failed) as f:
        for line in f:
            failed = line.split(f'{aster_ver}_')[-1].strip()
            with open(resutest_dir / f"{failed}.mess") as f_fail:
                data = f_fail.read()
                if fail_msg in data:
                    num += 1
                    failed_due_to.append(failed)

    print(f'{num} failures containing "{fail_msg}"')
    print('|'.join(failed_due_to))
