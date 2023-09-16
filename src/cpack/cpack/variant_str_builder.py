def main(variant_string):
    variants = variant_string.split(";")
    var_str = ' --variants="{'
    for i, v in enumerate(variants):
        if i > 0:
            var_str += ", "
        key, *value = v.split("=")
        value_str = "=".join(value)
        var_str += f"'{key}': '{value_str}'"
    var_str += '}"'

    return var_str
