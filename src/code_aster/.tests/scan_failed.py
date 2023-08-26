import pathlib
import argparse
from dataclasses import dataclass


# Run all using
# run_ctest --resutest=ctest -L submit -L sequential -LE need_data --timefactor=5.0 --only-failed-results
# Rerun all failed using
# run_ctest --resutest=ctest -L submit -L sequential -LE need_data --timefactor=5.0 --only-failed-results --rerun-failed

@dataclass
class FailedJob:
    num_failed: int
    jobs_failed: list[str]


def get_number_of_jobs(test_dir: pathlib.Path):
    last_failed = test_dir / "Testing/Temporary/CTestCheckpoint.txt"
    if not last_failed.exists():
        return 2182

    with open(last_failed) as f:
        return len(f.readlines())


def get_last_failed(test_dir: pathlib.Path, aster_ver):
    last_failed = test_dir / "Testing/Temporary/LastTestsFailed.log"
    if not last_failed.exists():
        return None

    list_of_failed = []
    with open(last_failed) as f:
        for line in f:
            failed = line.split(f'{aster_ver}_')[-1].strip()
            list_of_failed.append(test_dir / f"{failed}.mess")

    return list_of_failed


def get_current_failed(test_dir: pathlib.Path):
    return list(test_dir.glob("*.mess"))


def fail_checker(test_dir, aster_ver):
    test_dir = pathlib.Path(test_dir).resolve()
    if not test_dir.exists():
        raise ValueError(f'{test_dir} does not exist')
    last_failed = get_last_failed(test_dir, aster_ver)
    if last_failed is None:
        last_failed = get_current_failed(test_dir)

    fail_messages = [
        # Missing xmgrace
        ("Le fichier xmgrace n'existe pas",),
        # Missing scipy
        ("ModuleNotFoundError: No module named 'scipy'",),
        # missing miss3d
        ("run_miss3d: not found",),
        # Related to numpy >1.20
        ("AttributeError: module 'numpy' has no attribute 'float'.", 'MacroCommands/post_endo_fiss_ops.py", line 831'),
        ("AttributeError: module 'numpy' has no attribute 'complex'.", 'zzzz313a.comm.changed.py", line 44'),
        # Uncategorized
        ("<F> <DVP_1>", "La commande CALC_ERC_DYN ne peut fonctionner que sur des maillages ne contenant que des SEG2"),
        ("<F> <DVP_1>", "dmax .gt. 0.d0"),
        ("<EXCEPTION> <DVP_1>", "dmax .gt. 0.d0"),
        ("<F> <DVP_1>", "ier .eq. 0"),
        ("<F> <HHO1_4>", "Échec de la factorisation de Cholesky: la matrice n'est pas symétrique définie positive"),
        ("<F> <DVP_2>", "Erreur numérique (floating point exception)"),
        ("<EXCEPTION> <DVP_2>", "Erreur numérique (floating point exception)"),
        ("Fortran runtime error: Unit number in I/O statement too large", "acearp.F90"),
        ("<F> <UTILITAI6_77>",),
        ("<F> <ELEMENTS2_57>", "La modélisation T3G ne permet pas de bien"),
        ("AttributeError: 'libaster.Function' object has no attribute 'getMaterialNames'",),
        ("TypeError: 'float' object cannot be interpreted as an integer",),
        ("<F> <FERMETUR_13>", "libumat.so: cannot open shared object file"),
        ("No module named 'asrun'",),
        ("Fatal Python error: Segmentation fault", "=139"),
        # ("Fatal Python error: Aborted",),
        ("JeveuxCollection.h", "ABORT - exit code 17", "seems empty"),
        ("Killed", '137'),
        ("NOOK_TEST_RESU",)
    ]

    failed_termination_msg = '_ERROR'
    abnormal_termination_msg = '_ABNORMAL_ABORT'
    not_ok_result = 'NOOK_TEST_RESU'

    tot_num_jobs = 2182  # get_number_of_jobs(test_dir)
    num_identified_failed = 0

    num_failed_tot = 0
    unidentified_failures = []
    fail_map: dict[str, FailedJob] = {}

    for failed_mess in last_failed:
        if not failed_mess.exists():
            continue
        has_failed = False
        is_identified = False
        for fail_msg in fail_messages:
            data = failed_mess.read_text(encoding='utf-8')

            if failed_termination_msg in data or abnormal_termination_msg in data or not_ok_result in data:
                has_failed = True

            if all([msg in data for msg in fail_msg]):
                mess_name = failed_mess.name.split('.')[0].strip()
                is_identified = True
                if fail_msg not in fail_map:
                    fail_map[fail_msg] = FailedJob(1, [mess_name])
                else:
                    fail_map[fail_msg].num_failed += 1
                    fail_map[fail_msg].jobs_failed.append(mess_name)

        if has_failed is True:
            num_failed_tot += 1
            if is_identified:
                num_identified_failed += 1
            else:
                unidentified_failures.append(failed_mess)
        else:
            print(f'{failed_mess} did not fail')

    print('\nFailures due to:\n')
    for fail_msg, failed_job in fail_map.items():
        failed_seq = " & ".join([f"'{x}'" for x in fail_msg])
        print(f'"{failed_seq}": {failed_job.num_failed} jobs failed')
        print('|'.join(failed_job.jobs_failed))
        print()

    # 96% tests passed, 81 tests failed out of 2182
    print(
        f'{(tot_num_jobs - num_failed_tot) / tot_num_jobs * 100:.2f}% tests passed, {num_failed_tot} tests failed out of {tot_num_jobs}')
    print(
        f'{num_identified_failed} failures identified out of {num_failed_tot} jobs -> {num_identified_failed / num_failed_tot * 100:.2f}%')

    print(f'{num_failed_tot} failures out of {tot_num_jobs} jobs -> {num_failed_tot / tot_num_jobs * 100:.2f}%')

    print('Unidentified failures:')
    for fail_mess in unidentified_failures:
        print(fail_mess)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--test_dir', default='temp/ctest', type=str, help='Path to the test directory')
    parser.add_argument('--aster_ver', type=str, default='16.4.2', help='Code_Aster version')

    args = parser.parse_args()
    fail_checker(args.test_dir, args.aster_ver)
