import os
import pathlib
import argparse


def set_env(name, value):
    if "GITHUB_ENV" not in os.environ:
        return

    with open(os.environ["GITHUB_ENV"], "a") as fh:
        print(f"{name}={value}", file=fh)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("build_dir", type=str)
    args = parser.parse_args()

    build_dir = pathlib.Path(args.build_dir).resolve().absolute()
    set_env('CONDA_BUILD_DIR', build_dir.as_posix())
