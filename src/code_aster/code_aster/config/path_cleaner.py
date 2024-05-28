import os


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
    os.environ["PATH"] = os.pathsep.join(new_path)


if __name__ == '__main__':
    if os.getenv('GITHUB_ENV'):
        main()
