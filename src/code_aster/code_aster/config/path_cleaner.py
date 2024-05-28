import os


def set_output(name, value):
    if "GITHUB_OUTPUT" not in os.environ:
        return

    with open(os.environ["GITHUB_OUTPUT"], "a") as fh:
        print(f"{name}={value}", file=fh)


def set_env(name, value):
    if "GITHUB_ENV" not in os.environ:
        return

    with open(os.environ["GITHUB_ENV"], "a") as fh:
        print(f"{name}={value}", file=fh)


def main():
    """
    This is a script to clean the PATH environment variable for Github Actions on windows.
    This was because of an issue running WAF build on the windows-latest runner.
    """
    filter_paths_containing = [
        "fsharp",
        "CodeCoverage",
        "NETFX",
        "HTML Help Workshop",
        "Team Explorer",
        "Roslyn",
        "llvm",
        "WindowsApps",
        "dotnet",
        ".cargo",
        "Amazon",
        "php",
        "Microsoft Service Fabric",
        "Strawberry",
        "SQL",
        "WiX Toolset",
        "kotlinc",
        "hostedtoolcache",
        "SeleniumWebDrivers",
        "MongoDB",
        "aliyun",
        "zstd",
        "Mercurial",
        "MySQL",
        "ProgramData",
        "cabal",
        "ghcup",
        "php",
        "sbt",
        "pulumi",
        "Windows Performance Toolkit",
        "ImageMagick",
        "DiagnosticsHub"
    ]
    new_path = set()
    old_paths = os.getenv("PATH").split(os.pathsep)
    for path in old_paths:
        should_skip = False
        for filter_path in filter_paths_containing:
            if filter_path.lower() in path.lower():
                should_skip = True
                break

        if should_skip:
            print(f"Skipping {path}")
        else:
            print(f"Adding {path}")
            new_path.add(path)

    print(f"Reduced PATH from {len(old_paths)} to {len(new_path)}")
    new_path_str = os.pathsep.join(new_path)
    # set_env("TMP_PATH_VAR", new_path_str)
    with open("cleaned_path.txt", "w") as file:
        file.write(new_path_str)


if __name__ == '__main__':
    if os.getenv('GITHUB_ENV'):
        main()
