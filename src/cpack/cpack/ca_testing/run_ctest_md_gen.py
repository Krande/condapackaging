from dataclasses import dataclass
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

def get_failed_jobs(zip_ref: zipfile.ZipFile) -> list[str]:
    failed_log = "Testing/Temporary/LastTestsFailed.log"

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

def scan_cache_dirs(cache_temp_dir: str):
    md_str = "# Test Results\n\n"
    cache_temp_dir = pathlib.Path(cache_temp_dir).resolve().absolute()

    run_testcases = "run_testcases.xml"


    for zip_file in cache_temp_dir.glob("*.zip"):
        not_identified = []
        num_identified = 0
        fail_map = {}
        with zipfile.ZipFile(zip_file, 'r') as zip_ref:
            failed_jobs = get_failed_jobs(zip_ref)
            variants = get_variants_matrix(zip_ref)
            os = variants.get('platform', {}).get('os', 'n/a')
            pyver = variants.get('pyver', 'n/a')
            mpi = variants.get('variants',{}).get('mpi', 'n/a')
            build_type = variants.get('variants',{}).get('build_type', 'n/a')

            xml_data = examine_xml_data(zip_ref.read(run_testcases).decode('utf-8'))
            for file_name in zip_ref.namelist():
                if file_name.endswith('.mess'):  # Replace '.suffix' with the desired file suffix
                    mess_name = file_name.replace('.mess', '')
                    if mess_name not in failed_jobs:
                        print(f"Skipping {mess_name} as it is not in the failed jobs list")
                        continue
                    data = zip_ref.read(file_name).decode('utf-8')
                    result = check_test_file(mess_name, data, fail_map)
                    if result.is_identified:
                        num_identified += 1
                    else:
                        not_identified.append(mess_name)

        md_str += f"## CTest OS: {os}, Python: {pyver}, mpi: {mpi}, build_type: {build_type}\n"
        md_str += f"* Failed Jobs: {xml_data.failures} of {xml_data.tests} [{100*(xml_data.tests-xml_data.failures)/xml_data.tests:.2f}%]\n"
        md_str += f"* Identified: {num_identified}\n"
        md_str += f"* Not Identified: {len(not_identified)}\n\n"

    return md_str


def cli_md_gen():
    parser = argparse.ArgumentParser(description="Run ctest_md_gen")
    parser.add_argument("--cache-dir", type=str, help="The directory containing the zipped test results from the GA cache", required=True)
    parser.add_argument("--output-md", type=str, help="The output markdown file", required=True)
    args = parser.parse_args()

    md_str = scan_cache_dirs(args.cache_dir)
    with open(args.output_md, 'w') as f:
        f.write(md_str)


if __name__ == '__main__':
    cli_md_gen()
