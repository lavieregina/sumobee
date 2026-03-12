import google.generativeai as genai
import asyncio

async def test():
    try:
        model = genai.GenerativeModel('gemini-1.5-flash', api_key="dummy")
        print("Success initialization")
    except Exception as e:
        print(f"Error: {e}")

asyncio.run(test())
