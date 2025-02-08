import os
import platform
import pathlib


def set_env(name, value):
    with open(os.environ['GITHUB_ENV'], 'a') as fh:
        print(f'{name}={value}', file=fh)

def main():
    workspace_dir = pathlib.Path(os.getenv("WORKSPACE"))
    extra_args = os.getenv("EXTRA_ARGS")
    quetz_url = os.getenv("QUETZ_URL")
    conda_channel = os.getenv("CONDA_CHANNEL")
    use_devtools = os.getenv("USE_DEVTOOLS")

    extra_args_str = ""
    # Substitute __root__ with github workspace
    if extra_args != "":
        if platform.system() == "Windows":
            new_args = []
            for arg in extra_args.split(' '):
                  if "__root__" in arg:
                      # if it's a path, and it is using single quotes, replace with double quotes
                      new_args.append(arg.replace("'", '"'))
                  else:
                      new_args.append(arg)
            extra_args = ' '.join(new_args)

        extra_args_str += extra_args.replace('__root__', workspace_dir.as_posix())

    if quetz_url and conda_channel:
        extra_args_str += f" -c {quetz_url}/get/{conda_channel}"

    #if isinstance(use_devtools, str) and use_devtools.lower() == "true":
    #    extra_args_str += f" -c {quetz_url}/get/devtools"

    set_env('EXTRA_BUILD_ARGS', extra_args_str)

if __name__ == '__main__':
    main()