import os
from time import strftime

import yaml
import pathlib


def main():
    src_dir = pathlib.Path(__file__).parent / '..'
    # Commit hash and branch name set to n/a for now
    chash = 'n/a'
    bname = 'n/a'
    with open(src_dir / "recipe.yaml", "r") as stream:
        data = yaml.safe_load(stream)
        version = data['context']['version']
        version_tuple = tuple([int(x) for x in version.split('.')])

    os.environ['_CA_VERSION'] = version

    with open('./code_aster/pkginfo.py', 'w') as f:
        curr_time = strftime("%d/%m/%Y")
        f.write(f'pkginfo =({version_tuple}, "{chash}", "{bname}", "{curr_time}", "n/a", 1, ["no source repository"],)')


if __name__ == '__main__':
    main()
