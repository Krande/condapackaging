from cpack.variant_str_builder import main as variant_str_builder_main

def main(python_versions, platforms, variants):
    python_versions = python_versions.split(',') if python_versions else []
    platforms = platforms.split(',') if platforms else []
    variants = variants.split(',') if variants else []
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

    if len(variants) > 0:
        variant_list_of_dicts = []
        for v in variants:
            key, *value = v.split('=')
            value = key+'=' + '='.join(value)
            key_str = ','.join([sv.split('=')[0] for sv in value.split(';')])
            var_str = variant_str_builder_main(value)
            variant_list_of_dicts.append({"key": key_str, "value": value, "var_str": var_str})
        matrix["variants"] = variant_list_of_dicts

    return matrix
