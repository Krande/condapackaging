import json
import os
import tempfile
import typer
from toposort import toposort_flatten

output_file = os.environ.get("GITHUB_OUTPUT", tempfile.gettempdir() + "/env.txt")
env_file = os.environ.get("GITHUB_ENV", tempfile.gettempdir() + "/env.txt")

app = typer.Typer()


def flatten_job_deps(build_deps: dict[str, list[str]]) -> list[str]:
    build_deps = {x: set(y) for x, y in build_deps.items()}
    return toposort_flatten(build_deps)


def should_run():
    def set_output(name, value):
        with open(os.environ['GITHUB_OUTPUT'], 'a') as fh:
            print(f'{name}={value}', file=fh)

    job_name = os.getenv('JOB_NAME', None)
    build_selection = os.getenv('BUILD_SELECTION', None)

    print(f'{job_name=}')

    if not build_selection:
        set_output("should_run", "true")
        exit(0)

    job_list = build_selection.split(',')
    print(f'{build_selection=}')
    print(f'{job_list=}')
    if "all" in job_list:
        if len(job_list) == 1:
            print('job_list is 1')
            set_output("should_run", "true")
            exit(0)

        if f'!{job_name}' in job_list:
            print(f'Job {job_name} is skipped')
            set_output("should_run", "false")
            exit(0)

        set_output("should_run", "true")
        exit(0)

    print('all at the bottom')
    if job_name in job_list:
        set_output("should_run", "true")
    else:
        set_output("should_run", "false")


if __name__ == '__main__':
    data_json = r'/home/kristoffer/code/condapackaging/src/code_aster/build_deps.json'
    result = flatten_job_deps(json.load(open(data_json, 'r')))
    print(result)
