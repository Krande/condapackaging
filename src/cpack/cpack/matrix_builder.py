import base64

from cpack.variant_str_builder import main as variant_str_builder_main


def main(python_versions, platforms, variants_in):
    python_versions = python_versions.split(',') if python_versions else []
    platforms = platforms.split(',') if platforms else []

    platforms_dicts = []
    for platform in platforms:
        if platform == 'windows-latest':
            platforms_dicts.append({"os": platform, "short": "win"})
        elif platform == 'ubuntu-latest':
            platforms_dicts.append({"os": platform, "short": "linux"})
        elif platform == 'macos-latest':
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
            key, *value = v.split('=')
            value = key+'=' + '='.join(value)
            key_str = ','.join([sv.split('=')[0] for sv in value.split(';')])

            var_str = variant_str_builder_main(value)
            encoded_bytes = base64.b64encode(var_str.encode("utf-8"))
            var_bytes_str = encoded_bytes.decode("utf-8")

            variant_list_of_dicts.append({"key": key_str, "value": value, "var_str": var_bytes_str})
        matrix["variants"] = variant_list_of_dicts

    return matrix
