import os
import argparse

env_file = os.environ.get("GITHUB_OUTPUT", None)


def main(variant_string):
    variants = variant_string.split(';')
    var_str = ' --variants= \"{'
    for i, v in enumerate(variants):
        if i > 0:
            var_str += ', '
        key, *value = v.split('=')
        value_str = '='.join(value)
        var_str += f"'{key}': '{value_str}'"
    var_str += '}\"'

    return var_str




if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--variant-string', dest='variant_string', default='')
    args = parser.parse_args()
    main(**vars(args))

