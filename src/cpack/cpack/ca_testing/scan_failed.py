import argparse
import logging
import pathlib
from dataclasses import dataclass
import xml.etree.ElementTree as ET
from colorama import Fore

from cpack.ca_testing.error_messages import unclassified_fail_messages, missing_packages, numpy_failures, \
    failed_termination_msg, abnormal_termination_msg, not_ok_result

logger = logging.getLogger(__name__)


# Run all using
# run_ctest --resutest=ctest -L submit -L sequential -LE need_data --timefactor=5.0 --only-failed-results
# Rerun all failed using
# run_ctest --resutest=ctest -L submit -L sequential -LE need_data --timefactor=5.0 --only-failed-results --rerun-failed


@dataclass
class FailedJobsSummary:
    num_failed: int
    jobs_failed: list[str]

def get_failed_from_log_str(log_str: str) -> list[str]:
    return [line.split()[-1].strip().split('_')[-1] for line in log_str.split("\n") if line.strip() != ""]

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
class XmlLogStats:
    name: str
    tot_num_jobs: int
    tot_failures: int
    time: float
    failure_data: list[str] = None


def get_xml_log_stats(xml_file: pathlib.Path) -> XmlLogStats:
    # Parsing the XML
    root = ET.fromstring(xml_file.read_text(encoding="utf-8"))
    name = root.get("name")
    time = float(root.get("time"))
    tot_num_jobs = int(root.get("tests"))
    tot_failures = int(root.get("failures"))

    # Extracting test cases with failures
    testcases_with_failure = [testcase for testcase in root.findall("testcase") if testcase.find("failure") is not None]


    return XmlLogStats(name=name, tot_num_jobs=tot_num_jobs, tot_failures=tot_failures, time=time)


@dataclass
class TestStats:
    fail_map: dict[tuple[str], FailedJobsSummary]
    num_failed_tot: int
    num_identified_failed: int
    unidentified_failures: list[str]
    no_signs_of_failure: list[str]
    missing_packages: list[tuple[str]]
    numpy_failures: list[tuple[str]]
    unclassified_fail_messages: list[tuple[str]]
    mpi: bool
    xml_log_stats: XmlLogStats

    def __post_init__(self):
        self._not_failures_num = len(self.no_signs_of_failure)
        self._unidentified_failures_num = len(self.unidentified_failures)
        self._mis_pkg_n = self._calc_sum_failed(self.missing_packages)
        self._numpy_n = self._calc_sum_failed(self.numpy_failures)
        self._unclassified_n = self._calc_sum_failed(self.unclassified_fail_messages)

    def _calc_sum_failed(self, packages: list[tuple[str]]) -> int:
        return sum([len(self.fail_map.get(nf, FailedJobsSummary(0, [])).jobs_failed) for nf in packages])

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
            mis_packs = self.fail_map.get(mis_pack, FailedJobsSummary(0, [])).jobs_failed
            if len(mis_packs) == 0:
                continue
            print(f"\n  errors=({len(mis_packs)}), missing_package(s): {mis_pack[0]}:\n")
            print("    " + "|".join(mis_packs))
        return res

    def print_numpy_errors(self):
        res = self._numpy_n
        print(Fore.RED + f"\nNumpy Errors ({res}):\n")
        for error_code in self.numpy_failures:
            for failure in self.fail_map.get(error_code, FailedJobsSummary(0, [])).jobs_failed:
                print(f"    {failure} due to '{error_code}'")

        return res

    def print_unidentified_failures(self):
        print(Fore.RED + f"\nUnidentified failures {self._unidentified_failures_num}:\n")
        print("     " + "|".join(self.unidentified_failures))

    def print_unclassified_failures(self):
        res = self._unclassified_n
        print(Fore.RED + f"\nUnclassified Errors ({res}):")
        for error_code in self.unclassified_fail_messages:
            errors = self.fail_map.get(error_code, FailedJobsSummary(0, [])).jobs_failed
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
        tot_num_jobs = self.xml_log_stats.tot_num_jobs

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

@dataclass
class ScanResult:
    fail_map: dict[tuple[str], FailedJobsSummary]
    is_identified: bool
    has_failed: bool

def check_test_file(mess_name: str, data: str, fail_map: dict) -> ScanResult:
    is_identified = False
    has_failed = False
    for fail_msg in unclassified_fail_messages + missing_packages + numpy_failures:
        if failed_termination_msg in data or abnormal_termination_msg in data or not_ok_result in data:
            has_failed = True

        if all([msg in data for msg in fail_msg]):
            is_identified = True
            if fail_msg not in fail_map:
                fail_map[fail_msg] = FailedJobsSummary(1, [mess_name])
            else:
                fail_map[fail_msg].num_failed += 1
                fail_map[fail_msg].jobs_failed.append(mess_name)


    return ScanResult(fail_map=fail_map, is_identified=is_identified, has_failed=has_failed)

def fail_checker(test_dir, aster_ver, mpi, print=True) -> TestStats:
    test_dir = pathlib.Path(test_dir).resolve()
    if not test_dir.exists():
        raise ValueError(f"{test_dir} does not exist")

    last_failed = get_last_failed(test_dir, aster_ver)
    if last_failed is None:
        last_failed = get_current_failed(test_dir)

    xml_log_stats = get_xml_log_stats(test_dir / "run_testcases.xml")

    num_identified_failed = 0

    num_failed_tot = 0
    no_signs_of_failure = []
    unidentified_failures = []
    fail_map: dict[tuple[str], FailedJobsSummary] = {}

    for failed_mess in last_failed:
        if not failed_mess.exists():
            continue
        mess_name = failed_mess.name.split(".")[0].strip()
        try:
            data = failed_mess.read_text(encoding="utf-8")
        except UnicodeDecodeError as e:
            logger.error(f"Unable to read '{mess_name}' due to {e}")
            continue
        scan_result = check_test_file(mess_name, data, fail_map)

        if scan_result.has_failed is True:
            num_failed_tot += 1
            if scan_result.is_identified:
                num_identified_failed += 1
            else:
                unidentified_failures.append(mess_name)
        else:
            no_signs_of_failure.append(mess_name)
            # print(f'{failed_mess} did not fail')

    if num_failed_tot != xml_log_stats.tot_failures:
        logger.warning(
            f"Number of failed tests {num_failed_tot} does not match number of failed tests in xml log {xml_log_stats.tot_failures}"
        )

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
        xml_log_stats=xml_log_stats,
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
