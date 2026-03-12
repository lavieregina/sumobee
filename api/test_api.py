import os
import httpx
import json
import urllib.request
import urllib.error
import time
from dotenv import load_dotenv
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")
GEMINI_KEY = os.getenv("GEMINI_API_KEY")

USER_ID = "f49d8a5a-82e1-4e58-be68-d5033fd35002"

# Call summarize API with real Gemini key
req_data = {
    'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'userId': USER_ID,
    'geminiApiKey': GEMINI_KEY
}

print(f"Calling summarize with userId={USER_ID}, geminiApiKey={GEMINI_KEY[:10]}...")
req = urllib.request.Request(
    'http://localhost:8000/api/v1/summarize',
    data=json.dumps(req_data).encode(),
    headers={'Content-Type': 'application/json'}
)
res = urllib.request.urlopen(req)
body = json.loads(res.read().decode())
task_id = body.get('taskId')
print(f"✅ Task created: {task_id}")

# Poll for result (up to 2 minutes)
print("Polling for result...")
for i in range(24):
    time.sleep(5)
    status_req = urllib.request.Request(f'http://localhost:8000/api/v1/tasks/{task_id}')
    try:
        status_res = urllib.request.urlopen(status_req)
        status_body = json.loads(status_res.read().decode())
        status = status_body.get('status')
        print(f"  [{(i+1)*5}s] Status: {status}")
        if status == 'success':
            print("\n🎉 FULL END-TO-END SUCCESS!")
            print("=" * 60)
            content = status_body.get('content', '')
            print(content[:500] + "..." if len(content) > 500 else content)
            print("=" * 60)
            break
        elif status == 'error':
            print(f"\n❌ Task failed: {status_body.get('error_message')}")
            break
    except Exception as e:
        print(f"  Poll error: {e}")
        break
else:
    print("⏰ Timeout waiting for result")
