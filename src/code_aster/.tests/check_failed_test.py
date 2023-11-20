from scan_failed import fail_checker

if __name__ == "__main__":
    aster_ver = "16.4.14"
    channel = "ca-6929259947"
    variant = "seq"

    fail_checker(f'temp/ctest-results-{aster_ver}-{channel}-{variant}/ctest-code_aster-linux-3.11-{variant}', aster_ver,
                 True)
