#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import pathlib
import sys
import tempfile
from typing import Iterable

import lief
from conda_package_handling.api import extract as cph_extract

# New imports for .lib handling via external tools
import shutil
import subprocess


BINARY_SUFFIXES = {".so", ".dll", ".pyd", ".dylib", ".lib"}


def _find_llvm_nm() -> str | None:
    """
    Locate llvm-nm (preferred) or nm in PATH. Returns the executable path or None.
    """
    for exe in ("llvm-nm", "llvm-nm.exe", "nm", "nm.exe"):
        p = shutil.which(exe)
        if p:
            return p
    return None


def _get_lib_symbols_via_nm(path: pathlib.Path) -> list[str] | None:
    """
    Try to extract symbols from a .lib using llvm-nm if available.

    We request global symbols (-g) and POSIX output (-P), which prints lines like:
        <name> <type> <value>
    where <type> indicates symbol type (e.g., T, B, D, U, I, ...).

    Returns a sorted list of unique names or None if nm is not available or fails.
    """
    nm = _find_llvm_nm()
    if nm is None:
        return None
    try:
        # Don't use --defined-only so that import libraries still yield names (U/I).
        proc = subprocess.run(
            [nm, "-g", "-P", str(path)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        if proc.returncode != 0:
            return None
        out = proc.stdout.decode("utf-8", errors="ignore")
        names: list[str] = []
        for line in out.splitlines():
            line = line.strip()
            if not line:
                continue
            # POSIX format: name type value [size]
            parts = line.split()
            if not parts:
                continue
            # In rare cases, names can contain spaces; fall back to first token.
            name = parts[0]
            if name:
                names.append(name)
        dedup_ordered = list(dict.fromkeys(names))
        return sorted(dedup_ordered)
    except Exception:
        return None


def _get_lib_symbols_from_first_linker_member(path: pathlib.Path) -> list[str]:
    """
    Best-effort parsing of Microsoft COFF import/static libraries (.lib) by
    reading the first linker member from the archive ("!<arch>\n").

    This member stores a table of public symbol names as a sequence of
    null-terminated strings after a 32-bit count and 32-bit offsets.

    Returns an empty list if the file doesn't match the expected layout.
    """
    try:
        data = path.read_bytes()
        # Verify COFF archive magic
        if not data.startswith(b"!<arch>\n"):
            return []
        # First member header starts at offset 8, header is 60 bytes
        off = 8
        if len(data) < off + 60:
            return []
        header = data[off : off + 60]
        # Member size is ASCII decimal in bytes [48:58]
        try:
            size_str = header[48:58].decode("ascii", "ignore").strip()
            member_size = int(size_str)
        except Exception:
            return []
        mstart = off + 60
        mend = mstart + member_size
        if mend > len(data):
            return []
        mdata = data[mstart:mend]
        # Parse first linker member layout: <num_symbols><offsets...><strings...>
        if len(mdata) < 4:
            return []
        import struct

        num_symbols = struct.unpack_from("<I", mdata, 0)[0]
        pos = 4
        offsets_bytes = num_symbols * 4
        if pos + offsets_bytes > len(mdata):
            return []
        pos += offsets_bytes
        # The rest is a sequence of null-terminated strings
        names: list[str] = []
        while pos < len(mdata):
            end = mdata.find(b"\x00", pos)
            if end == -1:
                break
            s = mdata[pos:end]
            try:
                name = s.decode("utf-8", "ignore")
            except Exception:
                name = ""
            if name:
                names.append(name)
            pos = end + 1
        dedup_ordered = list(dict.fromkeys(names))
        return sorted(dedup_ordered)
    except Exception:
        return []


def get_exported_symbols(
    path: pathlib.Path,
    *,
    include_data: bool = False,
) -> list[str]:
    """
    Return a sorted list of exported symbol names for the given binary.

    By default this focuses on exported *functions* via the abstract
    LIEF API (works for PE, ELF, Mach-O).

    If include_data=True, it will also include exported variables/data
    symbols when the backend exposes an 'exported' property.
    """
    if not path.is_file():
        raise FileNotFoundError(f"{path} is not a regular file")

    suffix = path.suffix.lower()
    if suffix == ".lib":
        # Prefer llvm-nm for robust symbol listing; fallback to archive index.
        via_nm = _get_lib_symbols_via_nm(path)
        if via_nm is not None:
            return via_nm
        return _get_lib_symbols_from_first_linker_member(path)

    binary = lief.parse(path)  # type: ignore[arg-type]
    if binary is None:
        raise RuntimeError(f"Failed to parse binary: {path}")

    names: list[str] = []

    if include_data:
        # Use LIEF's symbol list and keep those marked as exported.
        for sym in getattr(binary, "symbols", []):  # type: ignore[attr-defined]
            exported = getattr(sym, "exported", False)
            if not exported:
                continue

            name = getattr(sym, "name", "") or getattr(sym, "demangled_name", "")
            if not name:
                continue

            names.append(str(name))
    else:
        # Cross-format exported function list.
        for fn in getattr(binary, "exported_functions", []):
            name = getattr(fn, "name", "") or getattr(fn, "demangled_name", "")
            if not name:
                continue
            names.append(str(name))

    # Deduplicate while preserving order, then sort for stable output.
    dedup_ordered = list(dict.fromkeys(names))
    return sorted(dedup_ordered)


def _iter_binaries(paths: Iterable[pathlib.Path]) -> Iterable[pathlib.Path]:
    for p in paths:
        if p.is_dir():
            raise IsADirectoryError(f"{p} is a directory; expected file path")
        yield p


def _is_binary_module(path: pathlib.Path) -> bool:
    return path.suffix.lower() in BINARY_SUFFIXES


def _normalize_lib_stem(stem: str) -> str:
    # Strip leading "lib" to make Linux/macOS names like "libfoo.so"
    # match "foo" as a logical library name.
    if stem.startswith("lib"):
        return stem[3:]
    return stem


def find_binaries_in_extracted_conda(
    root: pathlib.Path,
    lib_name: str,
) -> list[pathlib.Path]:
    """
    Search the extracted conda package tree for binary modules that match
    the requested library name.

    Matching rules:
    - If lib_name has an extension: exact basename match (case-sensitive).
    - If lib_name has no extension:
        * Match files with a binary suffix where normalized stem
          (strip leading 'lib') == lib_name.
    """
    query = pathlib.Path(lib_name)
    matches: list[pathlib.Path] = []

    if query.suffix:
        # Exact basename match (e.g. "mylib.dll" or "libfoo.so").
        target_name = query.name
        for p in root.rglob("*"):
            if p.is_file() and p.name == target_name:
                matches.append(p)
    else:
        # Match by logical library name (strip "lib" prefix on disk).
        logical_name = lib_name

        for p in root.rglob("*"):
            if not p.is_file():
                continue
            if not _is_binary_module(p):
                continue
            if _normalize_lib_stem(p.stem) == logical_name:
                matches.append(p)

    return matches


def extract_conda_package(
    conda_pkg: pathlib.Path,
    dest_dir: pathlib.Path,
) -> None:
    """
    Extract a .conda or .tar.bz2 package into dest_dir using
    conda-package-handling.
    """
    if not conda_pkg.is_file():
        raise FileNotFoundError(f"{conda_pkg} is not a regular file")

    # cph handles both .conda and .tar.bz2 formats.
    cph_extract(str(conda_pkg), str(dest_dir))


def handle_files_mode(
    binaries: list[pathlib.Path],
    *,
    include_data: bool,
    as_json: bool,
) -> int:
    exports_per_file: dict[str, list[str]] = {}

    for bin_path in _iter_binaries(binaries):
        symbols = get_exported_symbols(
            bin_path,
            include_data=include_data,
        )
        exports_per_file[str(bin_path)] = symbols

    _print_results(exports_per_file, as_json=as_json)
    return 0


def handle_conda_mode(
    conda_pkg: pathlib.Path,
    lib_name: str | None,
    *,
    include_data: bool,
    as_json: bool,
) -> int:
    """
    Extract a conda package and list exported symbols for matching binary modules.

    If lib_name is None, scan all binary modules in the package (files with
    suffixes in BINARY_SUFFIXES). If lib_name is provided, only modules
    matching the name (with rules documented in find_binaries_in_extracted_conda)
    are considered.
    """
    with tempfile.TemporaryDirectory(prefix="conda_extract_") as tmpdir_str:
        tmpdir = pathlib.Path(tmpdir_str)
        extract_conda_package(conda_pkg, tmpdir)

        if lib_name is None:
            matches = [
                p for p in tmpdir.rglob("*")
                if p.is_file() and _is_binary_module(p)
            ]
        else:
            matches = find_binaries_in_extracted_conda(tmpdir, lib_name)

        if not matches:
            if lib_name is None:
                raise FileNotFoundError(f"No binary modules found in {conda_pkg}")
            raise FileNotFoundError(
                f"No binary modules matching '{lib_name}' found in {conda_pkg}"
            )

        exports_per_file: dict[str, list[str]] = {}
        for p in matches:
            symbols = get_exported_symbols(
                p,
                include_data=include_data,
            )
            # Use path relative to extraction root to show in-package location.
            rel = p.relative_to(tmpdir)
            key = f"{conda_pkg}::{rel.as_posix()}"
            exports_per_file[key] = symbols

        _print_results(exports_per_file, as_json=as_json)
        return 0


def _print_results(
    exports_per_file: dict[str, list[str]],
    *,
    as_json: bool,
) -> None:
    if as_json:
        if len(exports_per_file) == 1:
            only_key = next(iter(exports_per_file))
            json.dump(exports_per_file[only_key], sys.stdout, indent=2)
        else:
            json.dump(exports_per_file, sys.stdout, indent=2)
        print()
        return

    # Plain text
    for i, (fname, symbols) in enumerate(exports_per_file.items()):
        if len(exports_per_file) > 1:
            if i:
                print()
            print(f"# {fname}")
        for sym in symbols:
            print(sym)


def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=(
            "List exported symbols from binaries (DLL/SO/etc.) "
            "or from binary modules inside conda packages. "
            "Automatically detects mode based on file extension."
        )
    )

    parser.add_argument(
        "file",
        nargs="+",
        type=pathlib.Path,
        help=(
            "Path(s) to binary files (DLL/SO/PYD/DYLIB/LIB) or conda package "
            "(.conda/.tar.bz2). For conda packages, provide the package path "
            "optionally followed by the library name to search for. If no "
            "library name is provided, all binary modules in the package will "
            "be scanned."
        ),
    )
    parser.add_argument(
        "--include-data",
        action="store_true",
        help="Include exported data symbols in addition to functions",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Output JSON instead of plain text",
    )

    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_arg_parser()
    args = parser.parse_args(argv)

    # Detect mode based on file extension
    first_file = args.file[0]
    file_suffix = first_file.suffix.lower()

    # Conda package extensions
    if file_suffix == ".conda" or first_file.name.endswith(".tar.bz2"):
        # Conda mode: library name is optional; if omitted, scan all binaries
        conda_pkg = args.file[0]
        lib_name = str(args.file[1]) if len(args.file) >= 2 else None

        return handle_conda_mode(
            conda_pkg=conda_pkg,
            lib_name=lib_name,
            include_data=args.include_data,
            as_json=args.json,
        )

    # Binary file mode
    return handle_files_mode(
        binaries=args.file,
        include_data=args.include_data,
        as_json=args.json,
    )


if __name__ == "__main__":
    raise SystemExit(main())
