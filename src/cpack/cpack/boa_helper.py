import itertools
import json
import os
import pathlib

from boa.core.utils import get_config
from conda_build.api import render


def set_output(name, value):
    with open(os.environ["GITHUB_OUTPUT"], "a") as fh:
        print(f"{name}={value}", file=fh)


def get_conda_variants(recipe_dir):
    combined_spec, config = get_config(recipe_dir)
    rendered_recipe = render(recipe_dir, config=config)
    variants = []
    for key, value in combined_spec.items():
        if not isinstance(value, list):
            continue
        if len(value) < 2:
            continue
        for val in value:
            var_dict = {"key": key, "value": val}
            variants.append(var_dict)
    return variants


def create_builds():
    recipe_dir = os.getenv("INPUT_RECIPE_DIR")
    python_versions = os.getenv("INPUT_PYTHON_VERSIONS")
    platforms = os.getenv("INPUT_PLATFORMS")
    conda_variants = get_conda_variants(recipe_dir)
    python_variants = python_versions.split(",")
    platform_variants = platforms.split(",")

    builds = []

    variants = list(itertools.product(python_variants, platform_variants, conda_variants))
    for python_version, platform, variant in variants:
        build = {
            "os": platform,
            "python": python_version,
            "variant_key": variant["key"],
            "variant_value": variant["value"],
        }
        builds.append(build)
    return builds


def generate_ga_matrix():
    builds = create_builds()

    build_matrix = {"builds": builds}
    set_output('build_matrix', json.dumps(build_matrix))

    return build_matrix


