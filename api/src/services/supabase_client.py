import os

from dotenv import load_dotenv
from supabase import Client, ClientOptions, create_client
import httpx

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

def get_supabase_client() -> Client:
    if not SUPABASE_URL or not SUPABASE_KEY:
        raise ValueError("SUPABASE_URL and SUPABASE_KEY must be set in environment variables")
    
    # 關閉 SSL 驗證，解決 Windows 憑證問題
    cli = create_client(SUPABASE_URL, SUPABASE_KEY)
    cli.postgrest.session = httpx.Client(verify=False)
    return cli

supabase: Client = get_supabase_client()
