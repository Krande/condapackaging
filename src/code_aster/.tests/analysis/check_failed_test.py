from scan_failed import fail_checker

if __name__ == "__main__":
    aster_ver = "17.0.5"
    channel = "ca-7761113790"
    variant = "seq"

    fail_checker(f'temp/ctest-results-{aster_ver}-{channel}-{variant}/ctest-code_aster-linux-3.11-{variant}', aster_ver,
                 True)
