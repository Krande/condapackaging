import os

_SRC_DIR = os.getenv('SRC_DIR')
_PREFIX = os.getenv('PREFIX')
_SP_DIR = os.getenv('SP_DIR')

shell_exec = [f"{_SRC_DIR}/ASTK_CLIENT/bin", f"{_SRC_DIR}/ASTK_SERV/bin"]
profile_sh = f"{_SRC_DIR}/ASTK_SERV/etc/profile.sh"


def basic_sub(file_path, old, new):
    with open(file_path, 'r') as f:
        content = f.read()

    if old not in content:
        return None

    content = content.replace(old, new)

    with open(file_path, 'w') as f:
        f.write(content)


def sub_shell_exec(bin_directory, old, new):
    for filename in os.listdir(bin_directory):
        file_path = os.path.join(bin_directory, filename)

        # Skip if it's not a file
        if not os.path.isfile(file_path):
            continue

        basic_sub(file_path, old, new)


def main():
    for xdir in shell_exec:
        sub_shell_exec(xdir, '#!?SHELL_EXECUTION?', '#!/usr/bin/env bash')

    basic_sub(profile_sh, '?HOME_PYTHON?', _PREFIX)
    basic_sub(profile_sh, '?WISH_EXE?', f"{_PREFIX}/bin/wish")
    basic_sub(profile_sh, '?ASRUN_SITE_PKG?', _SP_DIR)
    basic_sub(profile_sh, '?ASRUN_SITE_PKG?', _SP_DIR)


if __name__ == '__main__':
    main()
