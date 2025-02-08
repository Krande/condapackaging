import os
import pathlib
from time import strftime


def main():
    src_dir = pathlib.Path(os.getenv("SRC_DIR"))
    # Commit hash and branch name set to n/a for now
    chash = 'n/a'
    bname = 'n/a'

    version = os.getenv('PKG_VERSION')
    version_tuple = tuple([int(x) for x in version.split('.')])
    if len(version_tuple) == 4:
        version_tuple = tuple([x for x in version_tuple[:3]])

    os.environ['_CA_VERSION'] = version

    dst_file = src_dir / 'code_aster' / 'pkginfo.py'

    with open(dst_file, 'w') as f:
        curr_time = strftime("%d/%m/%Y")
        f.write(f'pkginfo =({version_tuple}, "{chash}", "{bname}", "{curr_time}", "n/a", 1, ["no source repository"],)')

    print(f"Version set to {version} in {dst_file}")

if __name__ == '__main__':
    main()
