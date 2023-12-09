import base64

from cpack.variant_str_builder import main as variant_str_builder_main


def create_actions_matrix(python_versions, platforms, variants_in):
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
        "platform": platforms_dicts
    }

    print(f"Starting to process: '{variants_in=}'")
    variants = variants_in.split(',') if variants_in else []
    if len(variants) > 0:
        variant_list_of_dicts = []
        for v in variants:
            if '.yaml' in v:
                variant = variants_from_yml(v)
                variant_list_of_dicts.extend(variant)
                continue

            key, *value = v.split('=')
            value = key + '=' + '='.join(value)
            key_str = ','.join([sv.split('=')[0] for sv in value.split(';')])

            var_str = variant_str_builder_main(value)
            var_bytes_str = convert_to_byte_str(var_str)

            variant_list_of_dicts.append({"key": key_str, "value": value, "var_str": var_bytes_str})
        matrix["variants"] = variant_list_of_dicts

    return matrix


def convert_to_byte_str(var_str: str) -> str:
    encoded_bytes = base64.b64encode(var_str.encode("utf-8"))
    var_bytes_str = encoded_bytes.decode("utf-8")
    return var_bytes_str


def convert_from_bytes_str(var_bytes_str: str) -> str:
    decoded_bytes = base64.b64decode(var_bytes_str)
    return decoded_bytes.decode("utf-8")


def variants_from_yml(variants_yml) -> list[dict]:
    import ruamel.yaml as yaml

    with open(variants_yml, 'r') as f:
        variants = yaml.safe_load(f)

    zip_keys = variants.get('zip_keys', [])
    variants_out = []
    for key, value in variants.items():
        if isinstance(value, list):
            for v in value:
                var_str = variant_str_builder_main(f"{key}={v}")
                var_bytes_str = convert_to_byte_str(var_str)
                variants_out.append({"key": key, "value": v, "var_str": var_bytes_str})

    return variants_out
