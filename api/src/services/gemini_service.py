import os
import httpx
from dotenv import load_dotenv

load_dotenv()

class GeminiService:
    def __init__(self):
        pass

    async def summarize_transcript(self, transcript: str, api_key: str = None, language: str = "zh-TW", detail: str = "Concise") -> str:
        key_to_use = api_key or os.getenv("GEMINI_API_KEY")
        if not key_to_use or key_to_use == "dummy_gemini_key":
            raise ValueError("必須提供有效的 Gemini API 金鑰")

        lang_map = {"繁體中文": "zh-TW", "English": "English", "日本語": "Japanese", "한국어": "Korean"}
        target_lang = lang_map.get(language, "zh-TW")
        
        detail_prompt = "請提供極簡的摘要。" if "Ultra-short" in detail else "請提供詳細且深入的總結。" if "Detailed" in detail else "請提供精簡的總結。"
        word_count = "100" if "Ultra-short" in detail else "600" if "Detailed" in detail else "300"

        prompt = (
            f"你是一位專業的知識編輯。請將以下 YouTube 影片的逐字稿轉換為約 {word_count} 字的 {target_lang} 總結。\n"
            f"{detail_prompt}\n"
            "請使用 Markdown 格式，並包含以下結構：\n"
            "# 標題\n"
            "## TL;DR\n"
            "## 關鍵要點\n"
            "## 結論\n\n"
            f"逐字稿內容如下：\n{transcript}"
        )

        url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={key_to_use}"
        payload = {
            "contents": [{"parts": [{"text": prompt}]}]
        }

        async with httpx.AsyncClient(verify=False) as client:
            response = await client.post(url, json=payload, timeout=60.0)
            if response.status_code != 200:
                raise Exception(f"Gemini API 錯誤: {response.text}")
            
            data = response.json()
            try:
                return data["candidates"][0]["content"]["parts"][0]["text"]
            except (KeyError, IndexError):
                raise Exception(f"無法解析 Gemini 回應: {data}")

gemini_service = GeminiService()
