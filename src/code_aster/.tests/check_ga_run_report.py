import os
import pathlib
import requests
import tarfile
from dataclasses import dataclass
from scan_failed import fail_checker


@dataclass
class GATestChecker:
    ca_version: str
    debug_build: bool
    mpi: bool
    python_version: str
    temp_dir: pathlib.Path = pathlib.Path('temp')

    def run_check(self, overwrite=False):
        self.download_github_release(overwrite)
        self.fail_evaluator()


    def download_github_release(self, overwrite=False):
        if self.dest_dir.exists() and overwrite is False:
            print('Folder exists. pass overwrite=True to download again')
            return None

        root_url = 'https://github.com/Krande/condapackaging/releases/download'
        relase_str = f'code-aster-{self.ca_version}-ctest-{self.release_str}-{self.mpi_str}'
        download_url = root_url + f'/{relase_str}/{self.file_str}'
        print(f'Downloading {download_url} and untarring to temp/ctest-results')
        r = requests.get(download_url)

        self.dest_dir.mkdir(exist_ok=True, parents=True)
        with open(self.dest_dir / self.file_str, 'wb') as f:
            f.write(r.content)

        with tarfile.open(self.dest_dir / self.file_str, 'r:gz') as f:
            f.extractall(self.dest_dir)

        print(f'Downloaded and untarred to {self.dest_dir}')

    def fail_evaluator(self):
        fmap = dict()
        for d in os.listdir(self.dest_dir):
            cur_dir = self.dest_dir / d
            
            if not cur_dir.is_dir():
                continue
            py_ver = d.split('-')[-1]

            fmap[py_ver] = fail_checker(self.dest_dir / d, self.ca_version)


    @property
    def dest_dir(self):
        return (self.temp_dir / self.release_str).absolute().resolve()

    @property
    def mpi_str(self):
        if self.mpi:
            return 'mpi'

        return 'seq'

    @property
    def release_str(self):
        if self.debug_build:
            return 'debug'

        return "release"

    @property
    def file_str(self):
        return f'ctest-results-{self.ca_version}-{self.release_str}-{self.mpi_str}.tar.gz'

if __name__ == '__main__':
    gatc = GATestChecker('16.4.4', debug_build=True, mpi=True, python_version='3.11')
    gatc.run_check()

    # download_github_release(ca_ver_, tag_, mpi_, pyver_)
    # fail_evaluator(tag)
