import os
from dotenv import load_dotenv

load_dotenv()


class GroqService:
    """使用 Groq API（免費高速 LLM 服務）生成影片摘要"""

    async def summarize_transcript(self, transcript: str, api_key: str = None, language: str = "zh-TW", detail: str = "Concise") -> str:
        key = api_key or os.getenv("GROQ_API_KEY")
        if not key:
            raise ValueError("必須提供 Groq API 金鑰（請至 https://console.groq.com 免費申請）")

        import httpx
        from groq import AsyncGroq
        
        # 關閉 SSL 驗證，解決 Windows 憑證不足導致的連線錯誤
        http_client = httpx.AsyncClient(verify=False)
        client = AsyncGroq(api_key=key, http_client=http_client)

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
            f"逐字稿內容如下：\n{transcript[:12000]}"
        )

        chat_completion = await client.chat.completions.create(
            messages=[{"role": "user", "content": prompt}],
            model="llama-3.3-70b-versatile",
            max_tokens=1024,
            temperature=0.7,
        )

        return chat_completion.choices[0].message.content


groq_service = GroqService()
