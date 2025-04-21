import os
import requests
from dotenv import load_dotenv

load_dotenv()
SERVER_URL = os.getenv('SERVER_URL', 'http://localhost:8000')

def chat(message: str):
    resp = requests.get(
        f"{SERVER_URL}/chat", params={"message": message}, stream=True
    )
    resp.raise_for_status()
    for line in resp.iter_lines(decode_unicode=True):
        if line.startswith('data: '):
            print(line.removeprefix('data: '))

if __name__ == '__main__':
    chat('Hello from Python client!')
