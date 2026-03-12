import os
import httpx
from dotenv import load_dotenv
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")

# Sign up using direct REST call to bypass SSL in Python client
res = httpx.post(
    f"{url}/auth/v1/signup",
    headers={
        "apikey": key,
        "Content-Type": "application/json"
    },
    json={
        "email": "testuser+sumobee@gmail.com",
        "password": "Test1234!",
        "data": {}
    },
    verify=False
)
print("Status:", res.status_code)
import json
print(json.dumps(res.json(), indent=2, ensure_ascii=False))
