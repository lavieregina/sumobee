import os
import httpx
import json
from dotenv import load_dotenv
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")

from supabase import create_client
cli = create_client(url, key)
cli.postgrest.session = httpx.Client(verify=False)

task_id = "b928f148-b5fb-4dd2-a0b8-1c47d2c0ecfc"
res = cli.table("summary_tasks").select("*").eq("id", task_id).single().execute()
print(json.dumps(res.data, indent=2, ensure_ascii=False))
