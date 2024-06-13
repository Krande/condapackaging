import os
import requests
import pathlib
from dotenv import load_dotenv

load_dotenv()

API_URL = "https://prefix.dev/api"
GRAPHQL_ENDPOINT = f"{API_URL}/graphql"
DELETE_ENDPOINT_TEMPLATE = f"{API_URL}/v1/delete/{{channel_name}}/win-64/{{filename}}"


def get_channel_query(channel_name: str) -> str:
    return pathlib.Path("query_channel.graphql").read_text().replace('__CHANNEL_NAME__', channel_name)


def get_files_query(channel_name: str, package_name: str) -> str:
    return pathlib.Path("query_package_files.graphql").read_text().replace('__CHANNEL_NAME__', channel_name).replace(
        '__PACKAGE_NAME__', package_name)


def fetch_channel_data_data(session: requests.Session, channel_name: str, token: str) -> dict:
    query = get_channel_query(channel_name)
    headers = {"Authorization": f"Bearer {token}"}
    response = session.post(GRAPHQL_ENDPOINT, json={"query": query}, headers=headers)
    response.raise_for_status()
    return response.json()


def fetch_files_data(session: requests.Session, channel_name: str, package_name: str, token: str) -> dict:
    query = get_files_query(channel_name, package_name)
    headers = {"Authorization": f"Bearer {token}"}
    response = session.post(GRAPHQL_ENDPOINT, json={"query": query}, headers=headers)
    response.raise_for_status()
    return response.json()


def delete_package(session: requests.Session, channel_name: str, filename: str, token: str):
    headers = {"Authorization": f"Bearer {token}"}
    delete_url = DELETE_ENDPOINT_TEMPLATE.format(channel_name=channel_name, filename=filename)
    response = session.delete(delete_url, headers=headers)
    response.raise_for_status()
    return response.text


def main(channel_name: str):
    token = os.getenv("PREFIX_API_KEY")
    if not token:
        raise ValueError("API token not found. Please set the PREFIX_API_KEY in your .env file.")

    with requests.Session() as session:
        data = fetch_channel_data_data(session, channel_name, token)
        packages = data.get("data", {}).get("channel", {}).get("packages", {}).get("page", [])

        if not packages:
            print("No packages found.")
            return

        for pkg in packages:
            name = pkg["name"]
            files_data = fetch_files_data(session, channel_name, name, token)
            pkg_files = files_data.get("data", {}).get("package", {}).get("variants", {}).get("page", [])
            for pkg_file in pkg_files:
                filename = pkg_file["filename"]
                try:
                    result = delete_package(session, channel_name, filename, token)
                    print(f"Deleted {filename}: '{result}'")
                except Exception as e:
                    print(f"Failed to delete {filename}: {e}")


if __name__ == '__main__':
    main("code-aster")
