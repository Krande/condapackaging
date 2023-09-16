import os
import tempfile
import typer

from cpack.matrix_builder import main as matrix_builder_main
from cpack.variant_str_builder import main as variant_str_builder_main

output_file = os.environ.get("GITHUB_OUTPUT", tempfile.gettempdir() + "/env.txt")
env_file = os.environ.get("GITHUB_ENV", tempfile.gettempdir() + "/env.txt")


app = typer.Typer()


@app.command(name="matrix-builder")
def matrix_builder(python_versions: str = "", platforms: str = "", variants: str = ""):
    matrix = matrix_builder_main(python_versions, platforms, variants)

    print(f"final_matrix={matrix}")
    with open(output_file, "a") as my_file:
        my_file.write(f"final_matrix={matrix}\n")

@app.command(name="variant-str-builder")
def variant_str_builder(variant_string: str = ""):
    var_str = variant_str_builder_main(variant_string)
    print(f"VARIANT_STR={var_str}")
    with open(env_file, "a") as my_file:
        my_file.write(f"VARIANT_STR={var_str}\n")


if __name__ == "__main__":
    app()
