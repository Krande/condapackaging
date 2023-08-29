import pathlib
import requests
import tarfile
from scan_failed import fail_checker

_TMP_DIR = pathlib.Path('temp')


def download_github_release(t):
    root_url = 'https://github.com/Krande/condapackaging/releases/download'
    download_url = root_url + f'/code-aster-16.4.2-ctest-{t}/ctest-results-{t}.tar.gz'
    print(f'Downloading {download_url} and untarring to temp/ctest-results')
    r = requests.get(download_url)

    dest_dir = _TMP_DIR / t
    dest_dir.mkdir(exist_ok=True, parents=True)
    with open(dest_dir / 'ctest-results.tar.gz', 'wb') as f:
        f.write(r.content)

    with tarfile.open(dest_dir / 'ctest-results.tar.gz', 'r:gz') as f:
        f.extractall(dest_dir)

    print(f'Downloaded and untarred to {dest_dir}')


def fail_evaluator(t):
    fmap39 = fail_checker(_TMP_DIR / t / f"ctest-code_aster-linux-3.9", '16.4.2')
    fmap310 = fail_checker(_TMP_DIR / t / f"ctest-code_aster-linux-3.10", '16.4.2')
    fmap311 = fail_checker(_TMP_DIR / t / f"ctest-code_aster-linux-3.11", '16.4.2')
    ferr1 = ('<F> <DVP_2>', 'Erreur numérique (floating point exception)')

    true_fails = set(fmap311[ferr1].jobs_failed)
    ferr39 = set(fmap39[ferr1].jobs_failed)
    ferr310 = set(fmap310[ferr1].jobs_failed)
    ferr310_39 = ferr310 - ferr39
    ferr39_310 = ferr39 - ferr310
    ferr39_311 = ferr39 - true_fails
    ferr310_311 = ferr310 - true_fails
    ferr311_39 = true_fails - ferr39
    ferr311_310 = true_fails - ferr310
    jobs_of_interest = ferr39_311
    with open('jobs_of_interest.txt', 'w') as f:
        f.write('\n'.join(jobs_of_interest))


if __name__ == '__main__':
    tag = 'gcc8crosslinux'
    pyver = '3.10'

    # download_github_release()
    fail_evaluator(tag)
