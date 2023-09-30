import argparse
import logging
import pathlib
from dataclasses import dataclass

from colorama import Fore

logger = logging.getLogger(__name__)


# Run all using
# run_ctest --resutest=ctest -L submit -L sequential -LE need_data --timefactor=5.0 --only-failed-results
# Rerun all failed using
# run_ctest --resutest=ctest -L submit -L sequential -LE need_data --timefactor=5.0 --only-failed-results --rerun-failed


@dataclass
class FailedJob:
    num_failed: int
    jobs_failed: list[str]


def get_last_failed(test_dir: pathlib.Path, aster_ver):
    last_failed = test_dir / "Testing/Temporary/LastTestsFailed.log"
    if not last_failed.exists():
        return None

    list_of_failed = []
    with open(last_failed) as f:
        for line in f:
            failed = line.split(f"{aster_ver}_")[-1].strip()
            list_of_failed.append(test_dir / f"{failed}.mess")

    return list_of_failed


def get_current_failed(test_dir: pathlib.Path):
    return list(test_dir.glob("*.mess"))


@dataclass
class TestStats:
    fail_map: dict[tuple[str], FailedJob]
    num_failed_tot: int
    num_identified_failed: int
    unidentified_failures: list[str]
    no_signs_of_failure: list[str]
    missing_packages: list[tuple[str]]
    numpy_failures: list[tuple[str]]
    unclassified_fail_messages: list[tuple[str]]
    mpi: bool

    def __post_init__(self):
        self._not_failures_num = len(self.no_signs_of_failure)
        self._unidentified_failures_num = len(self.unidentified_failures)
        self._mis_pkg_n = self._calc_sum_failed(self.missing_packages)
        self._numpy_n = self._calc_sum_failed(self.numpy_failures)
        self._unclassified_n = self._calc_sum_failed(self.unclassified_fail_messages)

    def _calc_sum_failed(self, packages: list[tuple[str]]) -> int:
        return sum([len(self.fail_map.get(nf, FailedJob(0, [])).jobs_failed) for nf in packages])

    def print_non_failures(self) -> None:
        # Not actual failures

        print(
            Fore.BLUE
            + f"No signs of failure ({self._not_failures_num}) (Likely due to timeouts, insufficient memory etc.):\n"
        )
        print("|".join([str(f) for f in self.no_signs_of_failure]))

    def print_missing_packages(self) -> int:
        res = self._mis_pkg_n
        print(Fore.RED + f"\nMissing packages Errors ({res}):")

        for mis_pack in self.missing_packages:
            mis_packs = self.fail_map.get(mis_pack, FailedJob(0, [])).jobs_failed
            if len(mis_packs) == 0:
                continue
            print(f"\n  errors=({len(mis_packs)}), missing_package(s): {mis_pack[0]}:\n")
            print("    " + "|".join(mis_packs))
        return res

    def print_numpy_errors(self):
        res = self._numpy_n
        print(Fore.RED + f"\nNumpy Errors ({res}):\n")
        for error_code in self.numpy_failures:
            for failure in self.fail_map.get(error_code, FailedJob(0, [])).jobs_failed:
                print(f"    {failure} due to '{error_code}'")

        return res

    def print_unidentified_failures(self):
        print(Fore.RED + f"\nUnidentified failures {self._unidentified_failures_num}:\n")
        print("     " + "|".join(self.unidentified_failures))

    def print_unclassified_failures(self):
        res = self._unclassified_n
        print(Fore.RED + f"\nUnclassified Errors ({res}):")
        for error_code in self.unclassified_fail_messages:
            errors = self.fail_map.get(error_code, FailedJob(0, [])).jobs_failed
            if len(errors) == 0:
                continue
            print(f"\n  errors=({len(errors)}), error_code(s): {error_code}:\n")
            print("    " + "|".join(errors))

    def check_for_jobs_in_multiple_categories(self):
        # Check if there exists overlap
        tot_reported = self._unidentified_failures_num + self._mis_pkg_n + self._numpy_n + self._unclassified_n
        if self.num_failed_tot != tot_reported:
            print(
                f"\nNumber of failures {self.num_failed_tot=} does not match total {tot_reported=}. "
                f"Likely overlap errors\n"
            )

        jobs = dict()
        for error_code, failed_jobs in self.fail_map.items():
            for job in failed_jobs.jobs_failed:
                if job not in jobs:
                    jobs[job] = [error_code]
                else:
                    jobs[job].append(error_code)

        for key, value in jobs.items():
            if len(value) == 1:
                continue

            print(f"{key} in multiple categories: {value}")

    def print_summary(self):
        tot_num_jobs = 2182 if not self.mpi else 2256

        not_failures_num = self._not_failures_num
        num_identified_failed = self.num_identified_failed
        unidentified_failures_num = self._unidentified_failures_num
        num_failed_tot = self.num_failed_tot

        print(Fore.GREEN + "\n")

        perc_tests_passed = (tot_num_jobs - num_failed_tot) / tot_num_jobs * 100
        perc_tests_all_passed = (tot_num_jobs - num_failed_tot - not_failures_num) / tot_num_jobs * 100
        perc_identified = num_identified_failed / num_failed_tot * 100
        all_reported_failed = num_failed_tot + not_failures_num

        print(f"{perc_tests_all_passed:.2f}% reported by ctest passing [{all_reported_failed}/{tot_num_jobs}].")
        print(f"{perc_tests_passed:.2f}% tests likely passed [{num_failed_tot}/{tot_num_jobs}].")
        print(
            f"{num_identified_failed}/{num_failed_tot} failures identified. "
            f"Remaining: {unidentified_failures_num} ({perc_identified:.2f}%)."
        )

    def print_all(self):
        print("\n")

        self.print_non_failures()
        self.print_missing_packages()
        if self._numpy_n > 0:
            self.print_numpy_errors()

        self.print_unclassified_failures()
        self.check_for_jobs_in_multiple_categories()
        self.print_unidentified_failures()

        self.print_summary()


def fail_checker(test_dir, aster_ver, mpi, print=True) -> TestStats:
    test_dir = pathlib.Path(test_dir).resolve()
    if not test_dir.exists():
        raise ValueError(f"{test_dir} does not exist")
    last_failed = get_last_failed(test_dir, aster_ver)
    if last_failed is None:
        last_failed = get_current_failed(test_dir)

    missing_packages = [
        ("Le fichier xmgrace n'existe pas",),
        ("ModuleNotFoundError: No module named 'scipy'",),
        ("run_miss3d: not found",),
        ("No module named 'asrun'",),
        ("No module named 'petsc4py'",),
        ("Le fichier homard est inconnu.",),  # 18 tests!
    ]

    numpy_failures = [
        (
            "AttributeError: module 'numpy' has no attribute 'float'.",
            'MacroCommands/post_endo_fiss_ops.py", line 831',
        ),
        (
            "AttributeError: module 'numpy' has no attribute 'complex'.",
            'zzzz313a.comm.changed.py", line 44',
        ),
    ]
    unclassified_fail_messages = [
        # Uncategorized
        # mpi-related
        ("sysmalloc: Assertion `(old_top == initial_top (av)",),
        ("malloc(): invalid size (unsorted)", "=134", "<F>_ABNORMAL_ABORT"),
        ("malloc(): mismatching next->prev_size (unsorted)",),
        ("PETSC ERROR", "Caught signal number 11 SEGV: Segmentation Violation"),
        ("munmap_chunk(): invalid pointer", "LinearSolver.cxx"),
        ("munmap_chunk(): invalid pointer", "Avancement du calcul"),
        ("<EXCEPTION> <FACTOR_10>", "la matrice est singulière ou presque singulière"),
        ("malloc.c:4302: _int_malloc: Assertion `(unsigned long) (size) >= (unsigned long) (nb)'",),
        ("free(): invalid next size (fast)", "Fatal Python error: Aborted"),
        ("python3: malloc.c:4105: _int_malloc: Assertion `chunk_main_arena (bck->bk)' failed.",),
        (
            "<F> <FACTOR_55>",
            "PARMETIS ERROR: Poor initial vertex distribution. Processor 0 has no vertices assigned to it!",
        ),
        # ("PARTITIONNEUR='METIS'", "=139", "<F>_ABNORMAL_ABORT"),
        ("malloc(): unaligned tcache chunk detected", ),
        ("corrupted size vs. prev_size", "<F>_ABNORMAL_ABORT", "=134"),
        ("<F> <ALGORITH9_17>", "Le nombre de pas est négatif"),
        ("double free or corruption (!prev)","<F>_ABNORMAL_ABORT"),
        # non-mpi (likely)
        (
            "<F> <DVP_1>",
            "La commande CALC_ERC_DYN ne peut fonctionner que sur des maillages ne contenant que des SEG2",
        ),
        ("<F> <DVP_1>", "dmax .gt. 0.d0"),
        ("<EXCEPTION> <DVP_1>", "dmax .gt. 0.d0"),
        ("<F> <DVP_1>", "ier .eq. 0"),
        (
            "<F> <HHO1_4>",
            "Échec de la factorisation de Cholesky: la matrice n'est pas symétrique définie positive",
        ),
        ("<F> <DVP_2>", "Erreur numérique (floating point exception)"),
        ("<EXCEPTION> <DVP_2>", "Erreur numérique (floating point exception)"),
        ("Fortran runtime error: Unit number in I/O statement too large", "acearp.F90"),
        ("<F> <UTILITAI6_77>",),
        ("<F> <ELEMENTS2_57>", "La modélisation T3G ne permet pas de bien"),
        ("<F> <FACTOR_11>", "la matrice est singulière ou presque singulière"),
        ("AttributeError: 'libaster.Function' object has no attribute 'getMaterialNames'",),
        ("TypeError: 'float' object cannot be interpreted as an integer",),
        ("<F> <FERMETUR_13>", "libumat.so: cannot open shared object file"),
        ("Fatal Python error: Segmentation fault", "=139"),
        ("JeveuxCollection.h", "ABORT - exit code 17", "seems empty"),
        ("Killed", "137"),
        ("NOOK_TEST_RESU",),
    ]

    failed_termination_msg = "_ERROR"
    abnormal_termination_msg = "_ABNORMAL_ABORT"
    not_ok_result = "NOOK_TEST_RESU"

    num_identified_failed = 0

    num_failed_tot = 0
    no_signs_of_failure = []
    unidentified_failures = []
    fail_map: dict[tuple[str], FailedJob] = {}

    for failed_mess in last_failed:
        if not failed_mess.exists():
            continue
        mess_name = failed_mess.name.split(".")[0].strip()
        has_failed = False
        is_identified = False
        try:
            data = failed_mess.read_text(encoding="utf-8")
        except UnicodeDecodeError as e:
            logger.error(f"Unable to read '{mess_name}' due to {e}")
            continue
        for fail_msg in unclassified_fail_messages + missing_packages + numpy_failures:
            if failed_termination_msg in data or abnormal_termination_msg in data or not_ok_result in data:
                has_failed = True

            if all([msg in data for msg in fail_msg]):
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
                unidentified_failures.append(mess_name)
        else:
            no_signs_of_failure.append(mess_name)
            # print(f'{failed_mess} did not fail')

    el = TestStats(
        fail_map=fail_map,
        num_identified_failed=num_identified_failed,
        num_failed_tot=num_failed_tot,
        unidentified_failures=unidentified_failures,
        unclassified_fail_messages=unclassified_fail_messages,
        missing_packages=missing_packages,
        no_signs_of_failure=no_signs_of_failure,
        numpy_failures=numpy_failures,
        mpi=mpi,
    )

    if print:
        el.print_all()

    return el


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--test-dir",
        type=str,
        required=True,
        help="Path to the test directory",
    )
    parser.add_argument("--aster-ver", type=str, default="16.4.2", help="Code_Aster version")
    parser.add_argument("--mpi", action="store_true", help="Whether to use mpi or not")

    args = parser.parse_args()
    fail_checker(args.test_dir, args.aster_ver, args.mpi)
