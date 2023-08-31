import argparse
import importlib
import inspect
import logging
import os
import pathlib
import pkgutil

import pybind11_stubgen


def find_injected_classes(module_name):
    stub_entries = []

    # Import the target module
    try:
        module = importlib.import_module(module_name)
    except (ModuleNotFoundError, ImportError, AssertionError) as e:
        logging.warning(f"Failed to import {module_name}: {e}")
        return stub_entries

    # If it's a package, recursively explore
    if hasattr(module, "__path__"):
        for _, sub_module, is_pkg in pkgutil.walk_packages(module.__path__):
            full_sub_module_name = f"{module_name}.{sub_module}"
            stub_entries.extend(find_injected_classes(full_sub_module_name))

    # Iterate through all members of the module
    sf = inspect.getsourcefile(module)

    for name, obj in inspect.getmembers(module):
        if not name.startswith('Extended'):
            continue

        res = inspect.getmembers(obj)
        if hasattr(obj, "mro"):
            for parent in obj.mro():
                if "decorated" in parent.__dict__:
                    stub_entry = generate_stub_entry(name, obj)
                    stub_entries.append(stub_entry)

    return stub_entries


def add_injector_methods_to_classes(parser: pybind11_stubgen.IParser):
    """Code Aster has a custom decorator that injects python methods into pybind11 classes. This function
    adds the methods to the classes."""

    stub_methods = find_injected_classes("code_aster.ObjectsExt")
    for class_ in stub_methods:
        if class_.name == "ExtendedMesh":
            print("sd")
    print("add_injector_methods_to_classes")


def run(
    parser: pybind11_stubgen.IParser,
    printer: pybind11_stubgen.Printer,
    module_name: str,
    out_dir: pathlib.Path,
    sub_dir: pathlib.Path | None,
    dry_run: bool,
):
    add_injector_methods_to_classes(parser)
    module = parser.handle_module(
        pybind11_stubgen.QualifiedName.from_str(module_name),
        importlib.import_module(module_name),
    )

    parser.finalize()

    if module is None:
        raise RuntimeError(f"Can't parse {module_name}")

    if dry_run:
        return

    writer = pybind11_stubgen.Writer()

    out_dir.mkdir(exist_ok=True)
    writer.write_module(module, printer, to=out_dir, sub_dir=sub_dir)


def main():
    conda_prefix = os.getenv("CONDA_PREFIX")

    stubs_dir = pathlib.Path(__file__).parent / "stubs" / "code_aster-stubs"
    aster_lib = pathlib.Path(conda_prefix) / "lib" / "aster" / "code_aster"
    module_name = "libaster"

    args = argparse.Namespace(
        module_name=module_name,
        ignore_all_errors=None,
        ignore_invalid_identifiers=None,
        ignore_invalid_expressions=None,
        ignore_unresolved_names=None,
        print_invalid_expressions_as_is=True,
        output_dir="stubs",
        root_suffix=None,
        # set_ignored_invalid_identifiers=None,
        # set_ignored_invalid_expressions=None,
        # set_ignored_unresolved_names=None,
        exit_code=False,
        numpy_array_wrap_with_annotated_fixed_size=True,
        numpy_array_remove_parameters=True,
        dry_run=False,
    )
    # shutil.copytree('stubs', dummy_lib, dirs_exist_ok=True)
    logging.basicConfig(
        level=logging.INFO,
        format="%(name)s - [%(levelname)7s] %(message)s",
    )

    parser = pybind11_stubgen.stub_parser_from_args(args)
    printer = pybind11_stubgen.Printer(
        invalid_expr_as_ellipses=not args.print_invalid_expressions_as_is
    )

    out_dir = pathlib.Path(args.output_dir)
    out_dir.mkdir(exist_ok=True)

    if args.root_suffix is None:
        sub_dir = None
    else:
        sub_dir = pathlib.Path(f"{args.module_name}{args.root_suffix}")

    run(
        parser,
        printer,
        args.module_name,
        out_dir,
        sub_dir=sub_dir,
        dry_run=args.dry_run,
    )


if __name__ == "__main__":
    main()
