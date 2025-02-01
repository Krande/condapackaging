import argparse
import subprocess
import pathlib
import sys
import re

print("Running test python file for libmed.")

def main():
    print("Running test batch file for libmed.")

    parser = argparse.ArgumentParser(description="Run the test batch file for libmed.")
    parser.add_argument("--int-type", type=str, default="med_int", help="The integer type to test.")
    args = parser.parse_args()

    size_map = {
        "64": "8",
        "32": "4",
    }
    int_size = size_map[args.int_type]

    # Get the absolute path of this script's directory.
    this_dir = pathlib.Path(__file__).parent.absolute()
    test_bat = this_dir / "test_med_int/run_test.bat"

    if not test_bat.exists():
        print(f"Error: Test batch file not found at {test_bat}", file=sys.stderr)
        sys.exit(1)

    print(f"Running test batch file: {test_bat}")
    # Run the batch file. Using shell=True to properly execute a .bat file.
    proc = subprocess.run(test_bat.as_posix(), capture_output=True, shell=True)
    if proc.returncode != 0:
        print(f"Error: Test batch file returned error code {proc.returncode}", file=sys.stderr)
        sys.exit(proc.returncode)
    print("Test batch file completed successfully.")

    result = proc.stdout.decode("utf-8")
    # Extract the test results from the output.
    cap = re.search(r'MEDFile: size of med_int is "(.*?)"', result)
    if cap is None:
        print("Error: Test result not found in output.", file=sys.stderr)
        sys.exit(1)

    test_result = cap.group(1)
    if test_result != int_size:
        print(f"Error: Test result {test_result} does not match expected value {int_size}.", file=sys.stderr)
        sys.exit(1)

    print(f"Test result '{test_result}' matches expected value.")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
