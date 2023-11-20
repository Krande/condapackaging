from scan_failed import fail_checker

if __name__ == "__main__":
    aster_ver = "16.4.12"
    variant = "ca-6771216530-mpi"
    # variant = "ca-6694568706-mpi"
    fail_checker(f'temp/ctest-results-{aster_ver}-{variant}/ctest-code_aster-linux-3.11', aster_ver, True)
