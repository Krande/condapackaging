import pathlib
import re
import sys

# Define replacement patterns
_replacements = [
    (r"INTEGER *,", "INTEGER(4),"),
    (r"INTEGER *::", "INTEGER(4) ::"),
    (r"INTEGER MPI", "INTEGER(4) MPI"),
    (r"REAL *,", "REAL(4),"),
    (r"REAL *::", "REAL(4) ::"),
    (r"COMPLEX *,", "COMPLEX(4),"),
    (r"COMPLEX *::", "COMPLEX(4) ::"),
    (r"LOGICAL *,", "LOGICAL(4),"),
    (r"LOGICAL *::", "LOGICAL(4) ::"),
]


def cli_entry():
    # Define prefix and include path
    prefix = pathlib.Path(sys.prefix)
    print(f"Prefix: {prefix}")

    if sys.platform == "win32":
        include_dir = prefix / "Library" / "include"
    else:
        include_dir = prefix / "include"

    main(include_dir)


def find_files(include_dir: pathlib.Path):
    # Define file patterns
    include_patterns = ["*_struc.h", "*_root.h"]

    # Collect files matching the patterns
    files_to_edit = []
    for pattern in include_patterns:
        files_to_edit.extend(include_dir.glob(pattern))

    files_to_edit.append(include_dir / "mpif.h")

    return files_to_edit


# Function to perform in-place modification of files
def modify_file(file_path: pathlib.Path):
    print(f"Modifying file: {file_path}")

    original_content = file_path.read_text(encoding="utf-8")
    content = original_content
    for pattern, replacement in _replacements:
        content = re.sub(pattern, replacement, content)

    file_path.write_text(content, encoding="utf-8")


def main(include_dir):
    if isinstance(include_dir, str):
        include_dir = pathlib.Path(include_dir)
    files_to_edit = find_files(include_dir)
    # Apply modifications
    for file in files_to_edit:
        modify_file(file)


if __name__ == '__main__':
    cli_entry()