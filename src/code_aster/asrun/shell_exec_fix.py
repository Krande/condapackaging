import os


def main(bin_directory):
    for filename in os.listdir(bin_directory):
        file_path = os.path.join(bin_directory, filename)

        # Skip if it's not a file
        if not os.path.isfile(file_path):
            continue

        with open(file_path, 'r') as f:
            content = f.read()

        if '#!?SHELL_EXECUTION?' in content:
            content = content.replace('#!?SHELL_EXECUTION?', '#!/bin/bash')

            with open(file_path, 'w') as f:
                f.write(content)

if __name__ == '__main__':
    main("/bin")