def build_default_condarc(condarc_filepath, root_dir, artifacts_dir):
    default_condarc = f"""remote_max_retries: 5
remote_backoff_factor: 5
conda-build:
  root-dir: {root_dir}
  output_folder: {artifacts_dir}
  pkg_format: 2
  zstd_compression_level: 19
channel_priority: strict
channels:
  - conda-forge    
"""
    with open(condarc_filepath, "w") as fh:
        fh.write(default_condarc)


def condarc_builder_cli():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--condarc-filepath", required=True)
    parser.add_argument("--root-dir", required=True)
    parser.add_argument("--artifacts-dir", required=True)
    args = parser.parse_args()
    build_default_condarc(args.condarc_filepath, args.root_dir, args.artifacts_dir)


if __name__ == '__main__':
    condarc_builder_cli()