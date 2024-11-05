from collections.abc import Iterable
from dataclasses import dataclass, field
import json
import re
import argparse
import pathlib
import zipfile
import xml.etree.ElementTree as ET

from cpack.ca_testing.scan_failed import get_failed_from_log_str, check_test_file


@dataclass
class TestResult:
    tests: int
    time: float
    failures: int


def examine_xml_data(xml_data: str) -> TestResult:
    # Replace known problematic characters
    xml_data = re.sub(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', '', xml_data)
    root = ET.fromstring(xml_data)
    tests = int(root.attrib["tests"])
    time = float(root.attrib["time"])
    failures = int(root.attrib["failures"])
    return TestResult(tests, time, failures)


@dataclass
class TestDataSet:
    name: str
    data_source: pathlib.Path = None

    def read_file_contents(self, file_name: str) -> str | None:
        if self.data_source.suffix == ".zip":
            with zipfile.ZipFile(self.data_source, 'r') as zip_ref:
                return zip_ref.read(file_name).decode('utf-8')
        else:
            file_path = self.data_source / file_name
            if not file_path.exists():
                return None

            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()

    def get_failed_jobs(self):
        data = self.read_file_contents("Testing/Temporary/LastTestsFailed.log")
        return get_failed_from_log_str(data)

    def get_variant_matrix(self):
        data = self.read_file_contents("variants.json")
        if data is None:
            return {}
        return json.loads(data)

    def get_run_xml(self):
        data = self.read_file_contents("run_testcases.xml")
        return examine_xml_data(data)

    def iter_failed_jobs(self):
        failed_jobs = self.get_failed_jobs()
        for job in failed_jobs:
            data = self.read_file_contents(f"{job}.mess")
            yield job, data

def get_failed_jobs_from_zip(zip_ref: zipfile.ZipFile, failed_log="Testing/Temporary/LastTestsFailed.log") -> list[str]:
    try:
        zip_ref.getinfo(failed_log)
    except KeyError:
        failed_jobs = []
    else:
        failed_jobs = get_failed_from_log_str(zip_ref.read(failed_log).decode('utf-8'))

    return failed_jobs


def get_variants_matrix(zip_ref: zipfile.ZipFile) -> dict:
    variants_json = "variants.json"
    try:
        zip_ref.getinfo(variants_json)
    except KeyError:
        return {}

    return json.loads(zip_ref.read(variants_json).decode('utf-8'))


@dataclass
class TestIterator:
    directory: str | pathlib.Path
    test_data: list[TestDataSet] = field(default_factory=list)

    def __post_init__(self):
        if isinstance(self.directory, str):
            self.directory = pathlib.Path(self.directory)

        zip_files = list(self.directory.glob("*.zip"))
        contents = list(self.directory.glob("*"))
        if len(zip_files) == 0 and len(contents) == 0:
            raise FileNotFoundError(f"No zip files or directories found in {self.directory}")

        self.test_data = [TestDataSet(d.name, d) for d in contents]

    def generate_md_str(self) -> str:

        md_str = "# Test Results\n\n"
        for test_data in self.test_data:
            failed_jobs = test_data.get_failed_jobs()
            variants = test_data.get_variant_matrix()
            xml_data = test_data.get_run_xml()
            os = variants.get('platform', {}).get('os', 'n/a')
            pyver = variants.get('pyver', 'n/a')
            mpi = variants.get('variants', {}).get('mpi', 'n/a')
            build_type = variants.get('variants', {}).get('build_type', 'n/a')
            fail_map = {}
            num_identified = 0
            not_identified = []
            for job, data in test_data.iter_failed_jobs():
                result = check_test_file(job, data, fail_map)
                if result.is_identified:
                    num_identified += 1
                else:
                    not_identified.append(job)

            md_str += f"## CTest OS: {os}, Python: {pyver}, mpi: {mpi}, build_type: {build_type}\n"
            md_str += f"* Failed Jobs: {xml_data.failures} of {xml_data.tests} [{100 * (xml_data.tests - xml_data.failures) / xml_data.tests:.2f}%]\n"
            md_str += f"* Identified: {num_identified}\n"
            md_str += f"* Not Identified: {len(not_identified)}\n\n"

        return md_str

def scan_cache_dirs(cache_temp_dir: str):
    cache_temp_dir = pathlib.Path(cache_temp_dir).resolve().absolute()
    test_iter = TestIterator(cache_temp_dir)
    md_str = test_iter.generate_md_str()
    return md_str


def cli_md_gen():
    parser = argparse.ArgumentParser(description="Run ctest_md_gen")
    parser.add_argument("--cache-dir", type=str,
                        help="The directory containing the zipped test results from the GA cache", required=True)
    parser.add_argument("--output-md", type=str, help="The output markdown file", required=True)
    args = parser.parse_args()

    md_str = scan_cache_dirs(args.cache_dir)
    with open(args.output_md, 'w') as f:
        f.write(md_str)


if __name__ == '__main__':
    cli_md_gen()
