import re

import os
import pathlib
import shutil
from itertools import groupby

import requests
import tarfile
import pandas as pd
from dataclasses import dataclass

from cpack.packages import Package
from cpack.cli_quetz_uploader import QuetzManager
from scan_failed import fail_checker, TestStats
from dotenv import load_dotenv

load_dotenv()


@dataclass
class TestPackage:
    rel_tag: str
    test_stats: TestStats
    ca_version: str
    python_version: str
    results_dir: pathlib.Path
    notes: str = ""


def extract_release_body_for_notes(body: str) -> str:
    """Check if the release body contains the string "Notes:"""
    res = body.split("Notes:")
    if len(res) < 2:
        return ""

    return res[1].replace("\n", " ").replace("*", "").strip()


def parse_packages(text: str) -> dict[str, Package]:
    lines = text.strip().split("\n")
    packages = {}

    # Find the line where the package list starts
    start_line = 0
    for i, line in enumerate(lines):
        if "───────────────────────────────────────────────────────────────────────────────" in line:
            start_line = i + 1
            break

    # Parse each package line
    for line in lines[start_line:]:
        parts = line.split()
        if len(parts) < 4:
            continue
        name = parts[0]
        version = parts[1]
        build = parts[2]
        packages[name] = Package(name, version, build)

    return packages


@dataclass
class GATestChecker:
    temp_dir: pathlib.Path = pathlib.Path("temp")
    ROOT_URL: str = "https://github.com/Krande/condapackaging/releases"
    API_ROOT_URL: str = "https://api.github.com/repos/Krande/condapackaging/releases"

    @staticmethod
    def list_all_releases() -> list[str]:
        r = requests.get(GATestChecker.API_ROOT_URL)
        return r.json()

    def create_report(self, release_tag=None, python_ver=None, mpi_ver=None, overwrite=False):
        # Create a dataframe with the columns; release_tag, ca_version, python_version, num_failed_tests
        qm = QuetzManager()

        df = pd.DataFrame(
            {
                "release_tag": [],
                "code_aster": [],
                "python": [],
                "mpi": [],
                "numpy": [],
                "hdf5": [],
                "gcc": [],
                "num_failed_tests": [],
                "description": [],
            }
        )
        df["num_failed_tests"] = df["num_failed_tests"].astype(int)
        for key, results in groupby(
            self.get_results(release_tag, python_ver, mpi_ver, overwrite), key=lambda x: x.rel_tag
        ):
            for result in results:
                run_packages = parse_packages((result.results_dir / "mamba.txt").read_text(encoding="utf-8"))
                gcc_ver = None
                for meta in qm.get_packages_meta_for_channel(result.rel_tag, "code-aster"):
                    bld_req = meta["requirements"]["build"]
                    for req in bld_req:
                        if not req.startswith("gcc_linux-64"):
                            continue
                        gcc_ver = req.split(" ")[1]
                        break
                    if gcc_ver is not None:
                        break

                result: TestPackage
                df = df._append(
                    {
                        "release_tag": result.rel_tag,
                        "code_aster": result.ca_version,
                        "python": result.python_version,
                        "mpi": result.test_stats.mpi,
                        "numpy": run_packages["numpy"].version,
                        "hdf5": run_packages["hdf5"].version,
                        "gcc": gcc_ver,
                        "num_failed_tests": result.test_stats.num_failed_tot,
                        "description": result.notes,
                    },
                    ignore_index=True,
                )
                failed = result.test_stats.num_failed_tot
                print(
                    f"{result.rel_tag} - {result.ca_version} - {result.python_version} - {result.test_stats.mpi} - {gcc_ver}: {failed} failed tests"
                )

        df.to_csv("report.csv", index=False)
        print("done")

    def get_results(self, release_tag=None, python_ver=None, mpi_ver=None, overwrite=False):
        for release in self.list_all_releases():
            rel_name = release["name"]
            tag_name = release["tag_name"]
            body_str = extract_release_body_for_notes(release["body"])
            for asset in release["assets"]:
                name = asset["name"]
                mpi_str = re.search("mpi|seq", name).group(0)
                if mpi_ver is not None and mpi_str != mpi_ver:
                    continue
                rel_tag = re.search("\[(.*?)\]", rel_name).group(1).replace("-" + mpi_str, "")
                if release_tag is not None and rel_tag != release_tag:
                    continue
                ca_version = tag_name.split("-")[2]
                dest_file = self.temp_dir / "files" / name
                dest_dir = self.temp_dir / name.replace(".tar.gz", "")
                if not dest_file.exists() or overwrite is True:
                    r = requests.get(asset["browser_download_url"])
                    dest_file.parent.mkdir(exist_ok=True, parents=True)
                    with open(dest_file, "wb") as f:
                        f.write(r.content)
                    with tarfile.open(dest_file, "r:gz") as f:
                        f.extractall(dest_dir)

                for d in os.listdir(dest_dir):
                    py_ver = d.split("-")[-1]
                    res_dir = dest_dir / d
                    if python_ver is not None and py_ver != python_ver:
                        continue
                    test_stats = fail_checker(res_dir, ca_version, mpi_str, print=False)
                    yield TestPackage(rel_tag, test_stats, ca_version, py_ver, res_dir, body_str)

    def prep_ctests_for_local_rerunning(self, local_env_path):
        local_env_path = pathlib.Path(local_env_path)
        cmake_file = local_env_path / "CTestTestfile.cmake"

        with open(cmake_file, "r") as f:
            data = f.read().replace("/home/runner/micromamba/envs/test-env", "local_env_path")
        shutil.copy(cmake_file, cmake_file.with_suffix(".bak"))
        with open(cmake_file, "w") as f:
            f.write(data)


if __name__ == "__main__":
    gatc = GATestChecker()
    gatc.create_report()

    # gatc.create_report(release_tag="ca-6458726549", python_ver="3.11", mpi_ver="mpi")
    # res = list(gatc.get_results(release_tag="ca-6362649655", python_ver="3.11", mpi_ver="seq"))[0]
    # res = list(gatc.get_results(release_tag="ca-6458726549", python_ver="3.11", mpi_ver="mpi"))[0]
