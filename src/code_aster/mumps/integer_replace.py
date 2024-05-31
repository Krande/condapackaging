import os
import pathlib
from pathlib import Path


def find_files(directory: str) -> list[Path]:
    """
    Find all files in the specified directory that match the pattern *_struc.h or *_root.h.

    Args:
        directory (str): The directory to search for files.

    Returns:
        list[Path]: A list of Paths to the matched files.
    """
    path = Path(directory)
    return list(path.rglob('*_struc.h')) + list(path.rglob('*_root.h'))


def replace_text_in_file(file_path: Path) -> None:
    """
    Replace occurrences of 'INTEGER *,' with 'INTEGER(4),' in the specified file.

    Args:
        file_path (Path): The path to the file to modify.
    """
    content = file_path.read_text()
    updated_content = content.replace('INTEGER *', 'INTEGER(4),')
    file_path.write_text(updated_content)


def main(directory: str | pathlib.Path) -> None:
    """
    Main function to find and replace text in all matched files within a directory.

    Args:
        directory (str): The directory to search for files and perform replacements.
    """
    files = find_files(directory)
    if len(files) == 0:
        raise FileNotFoundError(f'No files found in {directory} matching the pattern *_struc.h or *_root.h')
    for file_path in files:
        replace_text_in_file(file_path)


if __name__ == '__main__':
    # include_dir = pathlib.Path(os.getenv('SRC_DIR')).resolve().absolute() / 'mumps/5.6.2/include'
    include_dir = r'C:\work\code\mumps'
    main(include_dir)
