from scan_failed import fail_checker

if __name__ == "__main__":
    aster_ver = "16.4.9"
    fail_checker(f'temp/ctest-results-{aster_ver}-ca-6458726549-mpi/ctest-code_aster-linux-3.11', aster_ver, True)
