import re
from typing import Optional

import requests
from youtube_transcript_api import YouTubeTranscriptApi
from youtube_transcript_api._errors import TranscriptsDisabled, NoTranscriptFound, VideoUnavailable


class YouTubeService:
    def __init__(self):
        # 關閉 SSL 驗證，解決 Windows 憑證問題
        self._session = requests.Session()
        self._session.verify = False

    def extract_video_id(self, url: str) -> Optional[str]:
        patterns = [
            r'(?:v=|\/)([0-9A-Za-z_-]{11}).*',
            r'youtu\.be\/([0-9A-Za-z_-]{11})'
        ]
        for pattern in patterns:
            match = re.search(pattern, url)
            if match:
                return match.group(1)
        return None

    def get_transcript(self, video_id: str, limit_seconds: Optional[int] = None) -> str:
        try:
            api = YouTubeTranscriptApi(http_client=self._session)

            # 嘗試首選語言
            preferred = ['zh-TW', 'zh-HK', 'zh-CN', 'zh', 'en']
            try:
                transcript = api.fetch(video_id, languages=preferred)
            except NoTranscriptFound:
                # 找不到首選語言，改用 list() 找任何可用字幕（包含自動生成）
                transcript_list = api.list(video_id)
                best = None
                for t in transcript_list:
                    if best is None:
                        best = t
                    if not t.is_generated:
                        best = t
                        break
                if best is None:
                    raise ValueError("此影片沒有任何字幕")
                transcript = best.fetch()

            entries = list(transcript)
            if limit_seconds:
                entries = [e for e in entries if e.start <= limit_seconds]

            return " ".join(e.text for e in entries)

        except TranscriptsDisabled:
            raise ValueError("❌ 此影片的字幕已被作者停用，無法擷取逐字稿。請換一支有字幕（含自動字幕）的影片。")
        except VideoUnavailable:
            raise ValueError("❌ 找不到此影片，請確認網址是否正確。")
        except ValueError:
            raise
        except Exception as e:
            raise ValueError(f"無法獲取影片逐字稿：{str(e)}")


youtube_service = YouTubeService()
