import base64
import pathlib
import itertools
import json
import yaml
import subprocess

from cpack.boa_helper import get_conda_variants
from cpack.variant_str_builder import main as variant_str_builder_main

ROOT_DIR = pathlib.Path(__file__).parent.parent.parent.parent


def yaml_str_from_dict(variant_dict: dict) -> str:
    return yaml.dump(variant_dict, default_flow_style=False)


def get_variant_matrix_for_rattler(recipe_file: str, extra_config_in: str, platforms_short=list[str]) -> list[dict] | None:
    recipe_file = recipe_file.replace('__root__', ROOT_DIR.as_posix())
    extra_config_in = extra_config_in.replace('__root__', ROOT_DIR.as_posix())

    recipe_fp = pathlib.Path(recipe_file).resolve().absolute()
    extra_args = []
    if extra_config_in and len(extra_config_in) > 0:
        extra_args = extra_config_in.split(' ')
    variant_builds = []
    for os_name in ["win-64", "linux-64", "osx-64"]:
        if os_name not in platforms_short:
            continue
        args = ["rattler-build", "build", "-r", recipe_fp.as_posix(), *extra_args, "--render-only", "--target-platform",
                os_name]
        print(' '.join(args))
        result = subprocess.run(args, capture_output=True)
        if result.returncode != 0:
            print(result.stderr.decode())
            return None

        matrix_str = result.stdout.decode()
        json_matrix = json.loads(matrix_str)
        variant_builds.extend(json_matrix)

    variants_out = []
    builds = []
    for variant_build in variant_builds:
        variant_dict = variant_build["build_configuration"]['variant']
        build = variant_build["recipe"]['build']["string"]
        sub_packages = variant_build["build_configuration"]['subpackages']
        package_name = variant_build["recipe"]['package']['name']
        #if package_name.startswith("lib") and package_name in variant_dict.keys():
        #    # it's a subpackage, skip. We only want the main package (subpackages are automatically built)
        #    continue
        target_platform = variant_dict.pop("target_platform")
        key_str = ','.join(variant_dict.keys())
        var_str = ';'.join([f"{key}={value}" for key, value in variant_dict.items()])
        var_bytes_str = convert_to_byte_str(var_str)
        yaml_bytes_str = yaml_to_base64(variant_dict)
        variants_out.append(
            {"key": key_str, "value": var_str, "os": target_platform, "build": build, "var_str": var_bytes_str,
             "yaml_str": yaml_bytes_str})

    return variants_out


def yaml_to_base64(yaml_data: dict) -> str:
    yaml_str = yaml.dump(yaml_data, default_flow_style=False)
    yaml_bytes = yaml_str.encode("utf-8")  # Convert YAML string to bytes
    encoded_str = base64.b64encode(yaml_bytes).decode("utf-8")  # Encode and return string
    return encoded_str


def get_variants_from_variant_in_str(variants: list[str]) -> list[dict]:
    variant_list_of_dicts = []
    for v in variants:
        if '.yaml' in v:
            variant = variants_from_yml(v)
            variant_list_of_dicts.extend(variant)
            continue

        key, *value = v.split('=')
        value_str = '='.join(value)
        value = key + '=' + '='.join(value)
        key_value_dict = {}
        for sv in value.split(';'):
            key_d = sv.split('=')[0]
            value_d = sv.replace(key_d + '=', '')
            key_value_dict[key_d] = value_d
        key_str = ','.join([sv.split('=')[0] for sv in value.split(';')])

        var_str = variant_str_builder_main(value)
        var_bytes_str = convert_to_byte_str(var_str)

        variant_list_of_dicts.append({"key": key_str, "value": value, "var_str": var_bytes_str, **key_value_dict})
    return variant_list_of_dicts


def create_actions_matrix(python_versions, platforms, variants_in, recipe_file=None, extra_config=None):
    python_versions = python_versions.split(',') if python_versions else []
    platforms = platforms.split(',') if platforms else []

    platforms_dicts = []
    for platform in platforms:
        if platform.startswith('windows'):
            platforms_dicts.append({"os": platform, "short": "win-64"})
        elif platform.startswith('ubuntu'):
            platforms_dicts.append({"os": platform, "short": "linux-64"})
        elif platform.startswith('macos'):
            platforms_dicts.append({"os": platform, "short": "osx-64"})
        else:
            raise ValueError(f"Unknown platform {platform}")

    matrix = {
        "pyver": python_versions,
        "platform": platforms_dicts,
        "variants": []
    }

    print(f"Starting to process: '{variants_in=}'")
    variants = variants_in.split(',') if variants_in else []
    if len(variants) > 0:
        matrix["variants"].extend(get_variants_from_variant_in_str(variants))

    if recipe_file:  # This should always replace the variants
        if 'meta.yaml' in recipe_file:
            result = get_conda_variants(recipe_file)
        elif "recipe.yaml" in recipe_file:
            platforms_short = [x["short"] for x in platforms_dicts]
            result = get_variant_matrix_for_rattler(recipe_file, extra_config, platforms_short)
        else:
            raise ValueError(f"Unknown recipe file {recipe_file}")

        if result is not None:
            matrix["variants"] = result
            matrix["variants"] = create_list_product_from_matrix(matrix)

    return matrix


def create_list_product_from_matrix(matrix: dict) -> list[dict]:
    final_outputs = []
    for platform in matrix["platform"]:
        for variant in matrix["variants"]:
            if variant["os"] != platform["short"]:
                continue
            final_outputs.append({**platform, **variant})

    return final_outputs


def convert_to_byte_str(var_str: str) -> str:
    encoded_bytes = base64.b64encode(var_str.encode("utf-8"))
    var_bytes_str = encoded_bytes.decode("utf-8")
    return var_bytes_str


def convert_from_bytes_str(var_bytes_str: str) -> str:
    decoded_bytes = base64.b64decode(var_bytes_str)
    return decoded_bytes.decode("utf-8")


def variants_from_yml(variants_yml) -> list[dict]:
    from ruamel.yaml import YAML
    yaml = YAML(typ='safe', pure=True)

    with open(variants_yml, 'r') as f:
        variants = yaml.load(f)

    variants_out = []
    for key, value in variants.items():
        if isinstance(value, list):
            for v in value:
                var_str = variant_str_builder_main(f"{key}={v}")
                var_bytes_str = convert_to_byte_str(var_str)
                variants_out.append({"key": key, "value": v, "var_str": var_bytes_str})

    return variants_out
