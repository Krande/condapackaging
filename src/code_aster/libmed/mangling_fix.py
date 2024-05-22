def process_file(input_filepath: str, output_filepath: str) -> None:
    with open(input_filepath, 'r') as file:
        lines = file.readlines()

    # Processing the lines starting from the second line
    processed_lines = [lines[0]] + ["	" + line.strip().lower() + f'_={line.strip()}\n' for line in lines[1:]]

    with open(output_filepath, 'w') as file:
        file.writelines(processed_lines+lines[1:])


if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Process a file')
    parser.add_argument('--ifile', type=str, help='Input file path')
    parser.add_argument('--ofile', type=str, help='Output file path')

    args = parser.parse_args()
    process_file(args.ifile, args.ofile)
