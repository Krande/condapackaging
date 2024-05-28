import os


def main():
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
    for path in os.getenv("PATH").split(os.pathsep):
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

    os.environ["PATH"] = os.pathsep.join(new_path)


if __name__ == '__main__':
    main()
