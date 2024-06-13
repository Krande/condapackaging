import os

import requests
from dotenv import load_dotenv

load_dotenv()


def main():
    query = "{viewer { login }}"
    token = os.getenv("PREFIX_API_KEY")
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.post("https://prefix.dev/api/graphql", json={"query": query}, headers=headers)
    print(response.json())


if __name__ == '__main__':
    main()
