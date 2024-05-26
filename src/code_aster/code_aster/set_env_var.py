import os
import argparse


def set_env(name, value):
    with open(os.environ["GITHUB_ENV"], "a") as fh:
        print(f"{name}={value}", file=fh)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("build_dir", type=str)
    args = parser.parse_args()
    set_env('CONDA_BUILD_DIR', args.build_dir)
