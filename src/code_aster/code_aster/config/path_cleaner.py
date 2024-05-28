import os


def main():
    filter_paths_containing = [
        "fsharp",
        "CodeCoverage",
        "NETFX",
        "HTML Help Workshop",
        "Team Explorer",
        "Roslyn"
    ]
    new_path = []
    for path in os.getenv("PATH").split(os.pathsep):
        for filter_path in filter_paths_containing:
            if filter_path.lower() in path.lower():
                print(f"Skipping {path}")
                continue
            print(f"Adding {path}")
        new_path.append(path)

    os.environ["PATH"] = os.pathsep.join(new_path)


if __name__ == '__main__':
    main()
