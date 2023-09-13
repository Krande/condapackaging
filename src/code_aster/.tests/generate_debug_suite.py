import argparse
import os
import pathlib
import shutil


# Please remember to run this script using a code_aster conda environment

def get_current_failed(test_dir: pathlib.Path):
    return list(test_dir.glob("*.mess"))


def get_related_files_from_export(export_file: pathlib.Path):
    with open(export_file) as f:
        for line in f:
            if not line.startswith("F "):
                continue
            yield line.split(" ")[2].strip()

def create_suite(test_dir, included_tests: list[str]=None):
    test_dir = pathlib.Path(test_dir).resolve()
    if not test_dir.exists():
        test_dir.mkdir(exist_ok=True, parents=True)

    failed = get_current_failed(test_dir)
    astest_dir = pathlib.Path(os.getenv('CONDA_PREFIX')) / 'share' / 'aster' / 'tests'
    for fail in failed:
        dest_dir = test_dir.parent / test_dir.stem / fail.stem
        dest_dir.mkdir(exist_ok=True)
        export_file = astest_dir / fail.with_suffix('.export').name
        if not export_file.exists():
            raise ValueError(f'{export_file} does not exist')

        for related_file in get_related_files_from_export(export_file):
            shutil.copy(astest_dir / related_file, dest_dir / related_file)
        shutil.copy(export_file, dest_dir / export_file.name)

    if included_tests is None:
        return

    # expand include_tests so that all elments with | separated are expanded in a single list
    # e.g. ['mtlp100a|ttnp200a|mtlp102a|ttna200a'] -> ['mtlp100a', 'ttnp200a', 'mtlp102a', 'ttna200a']
    included_tests = [test for tests in included_tests for test in tests.split("|")]

    for incl in included_tests:
        dest_dir = test_dir.parent / test_dir.stem / incl
        dest_dir.mkdir(exist_ok=True)
        export_file = astest_dir / f'{incl}.export'
        if not export_file.exists():
            raise ValueError(f'{export_file} does not exist')

        for related_file in get_related_files_from_export(export_file):
            shutil.copy(astest_dir / related_file, dest_dir / related_file)
        shutil.copy(export_file, dest_dir / export_file.name)

if __name__ == '__main__':
    # argparse = argparse.ArgumentParser()
    # argparse.add_argument('test_dir', help='The directory containing the failed tests')
    # args = argparse.parse_args()
    # create_suite(args.test_dir)
    create_suite("temp/py311fail_float", ["mtlp100a|ttnp200a|mtlp102a|ttna200a"])
    create_suite("temp/py311fail_no_ok", ["zzzz395q|zzzz395e|supv004a|sdll123f"])
    create_suite("temp/py311fail_float_as_int", ["ssls141b|ssls141d|ahlv302g"])
    create_suite("temp/py311fail_libumat", ["zzzz409a"])
    create_suite("temp/py311fail_get_mat_names", ["zzzz503h"])
    create_suite("temp/py311fail_sing_matr", ["wtnv113k"])
    create_suite("temp/py311fail_JeveuxCollection", ["zzzz381a|cont001a|ssll111b"])


