import os


def main():
    env_file = os.environ.get("GITHUB_OUTPUT", None)
    python_versions = "${{ inputs.python_versions }}"
    platforms = "${{ inputs.platforms }}"
    variants = "${{ inputs.variants }}"

    python_versions = python_versions.split(',') if python_versions else []
    platforms = platforms.split(',') if platforms else []
    variants = variants.split(',') if variants else []

    matrix = {
        "pyver": python_versions,
        "platform": platforms
    }

    if len(variants) > 0:
        variant_list_of_dicts = []
        for v in variants:
            key, value = v.split('=')
            variant_list_of_dicts.append({"key": key, "value": value})
        matrix["variants"] = variants

    with open(env_file, "a") as my_file:
        my_file.write(f"final_matrix={matrix}\n")


if __name__ == '__main__':
    main()
