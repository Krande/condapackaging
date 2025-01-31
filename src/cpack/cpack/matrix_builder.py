import base64
import pathlib
import json

import subprocess
from cpack.variant_str_builder import main as variant_str_builder_main


def get_variant_matrix_for_rattler(recipe_file: str, extra_config_in: str) -> list[dict] | None:
    recipe_fp = pathlib.Path(recipe_file).resolve().absolute()
    extra_args = []
    if extra_config_in and len(extra_config_in) > 0:
        extra_args = extra_config_in.split(' ')

    result = subprocess.run(["rattler-build", "build", "-r", recipe_fp.as_posix(), *extra_args, "--render-only"],
                            capture_output=True)
    if result.returncode != 0:
        print(result.stderr.decode())
        return None

    matrix_str = result.stdout.decode()
    json_matrix = json.loads(matrix_str)
    variants = []
    for variant_build in json_matrix:
        variant_dict = variant_build["build_configuration"]['variant']
        variant_dict.pop("target_platform")
        variants.append(variant_dict)

    return variants


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


def create_actions_matrix(python_versions, platforms, variants_in, recipe_input=None, extra_config=None):
    python_versions = python_versions.split(',') if python_versions else []
    platforms = platforms.split(',') if platforms else []

    platforms_dicts = []
    for platform in platforms:
        if platform.startswith('windows'):
            platforms_dicts.append({"os": platform, "short": "win"})
        elif platform.startswith('ubuntu'):
            platforms_dicts.append({"os": platform, "short": "linux"})
        elif platform.startswith('macos'):
            platforms_dicts.append({"os": platform, "short": "macos"})
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

    if recipe_input: # This should always replace the variants
        result = get_variant_matrix_for_rattler(recipe_input, extra_config)
        if result is not None:
            matrix["variants"] = result

    return matrix


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
