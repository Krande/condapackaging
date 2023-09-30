import re

import os
import pathlib
import shutil

import requests
import tarfile
import pandas as pd
from dataclasses import dataclass
from scan_failed import fail_checker, TestStats


@dataclass
class TestPackage:
    rel_tag: str
    test_stats: TestStats
    ca_version: str
    python_version: str
    results_dir: pathlib.Path


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
        df = pd.DataFrame(
            {
                "release_tag": [],
                "ca_version": [],
                "python_version": [],
                "num_failed_tests": [],
            }
        )
        for result in self.get_results(release_tag, python_ver, mpi_ver, overwrite):
            df = df._append(
                {
                    "release_tag": result.rel_tag,
                    "ca_version": result.ca_version,
                    "python_version": result.python_version,
                    "num_failed_tests": result.test_stats.num_failed_tot,
                },
                ignore_index=True,
            )
            failed = result.test_stats.num_failed_tot
            print(f'{result.rel_tag} - {result.ca_version} - {result.python_version}: {failed} failed tests')
        df = df.sort("release_tag")
        print('done')

    def get_results(self, release_tag=None, python_ver=None, mpi_ver=None, overwrite=False):
        results = []
        for release in self.list_all_releases():
            rel_name = release["name"]
            asset = release["assets"][0]
            name = asset["name"]

            tag_name = release["tag_name"]

            mpi_str = re.search("mpi|seq", rel_name).group(0)
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
                res = TestPackage(rel_tag, test_stats, ca_version, py_ver, res_dir)
                results.append(res)

        return results

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

    # gatc.create_report(release_tag="ca-6355937094", python_ver="3.11", mpi_ver="seq")