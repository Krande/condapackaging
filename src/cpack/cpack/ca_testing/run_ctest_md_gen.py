from cpack.ca_testing.check_failed_test import fail_checker
from cpack.ca_testing.scan_failed import Test

def main():

    test_stats = fail_checker(res_dir, ca_version, mpi_str, print=False)
    yield TestPackage(rel_tag, test_stats, ca_version, py_ver, res_dir, last_update=datetime_object,
                      notes=body_str)

def cli_main():
    ...


if __name__ == '__main__':
    main()
