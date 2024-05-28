import os


def main():
    """
    This is a script to clean the PATH environment variable for Github Actions on windows.
    This was because of a
    """
    filter_paths_containing = [
        "fsharp",
        "CodeCoverage",
        "NETFX",
        "HTML Help Workshop",
        "Team Explorer",
        "Roslyn",
        "Common7",
        "llvm",
        "WindowsApps",
        ".dotnet",
        ".cargo",
        "Amazon"
        "php",
        "Microsoft Service Fabric",
        "Strawberry",
        "Microsoft SQL Server",
        "WiX Toolset",
        "kotlinc",
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
