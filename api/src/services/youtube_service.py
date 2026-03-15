import re
import json
import subprocess
import tempfile
import os
from typing import Optional


class YouTubeService:
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
        url = f"https://www.youtube.com/watch?v={video_id}"

        with tempfile.TemporaryDirectory() as tmpdir:
            output_template = os.path.join(tmpdir, "subs")

            # Use yt-dlp to download subtitles only (no video)
            cmd = [
                "yt-dlp",
                "--skip-download",
                "--write-subs",
                "--write-auto-subs",
                "--sub-langs", "zh-TW,zh-HK,zh-CN,zh,en",
                "--sub-format", "json3",
                "--output", output_template,
                url,
            ]

            try:
                result = subprocess.run(
                    cmd, capture_output=True, text=True, timeout=30
                )
            except subprocess.TimeoutExpired:
                raise ValueError("❌ 字幕下載超時，請稍後再試。")

            if result.returncode != 0:
                stderr = result.stderr.lower()
                if "video unavailable" in stderr or "not available" in stderr:
                    raise ValueError("❌ 找不到此影片，請確認網址是否正確。")
                if "subtitles are disabled" in stderr:
                    raise ValueError("❌ 此影片的字幕已被作者停用，無法擷取逐字稿。請換一支有字幕（含自動字幕）的影片。")
                raise ValueError(f"無法獲取影片逐字稿：{result.stderr[:200]}")

            # Find the downloaded subtitle file (prefer manual over auto-generated)
            sub_file = self._find_best_subtitle(tmpdir)
            if not sub_file:
                raise ValueError("❌ 此影片沒有任何可用字幕。")

            return self._parse_json3(sub_file, limit_seconds)

    def _find_best_subtitle(self, directory: str) -> Optional[str]:
        """Find the best subtitle file, preferring zh-TW > zh > en, manual > auto."""
        files = os.listdir(directory)
        lang_priority = ['zh-TW', 'zh-HK', 'zh-CN', 'zh', 'en']

        # Prefer manual subs (no 'auto' in filename) over auto-generated
        for lang in lang_priority:
            for f in files:
                if f.endswith('.json3') and lang in f and '.auto.' not in f:
                    return os.path.join(directory, f)
        for lang in lang_priority:
            for f in files:
                if f.endswith('.json3') and lang in f:
                    return os.path.join(directory, f)
        # Fallback: any subtitle file
        for f in files:
            if f.endswith('.json3'):
                return os.path.join(directory, f)
        return None

    def _parse_json3(self, filepath: str, limit_seconds: Optional[int] = None) -> str:
        """Parse json3 subtitle format and return concatenated text."""
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)

        texts = []
        for event in data.get('events', []):
            start_ms = event.get('tStartMs', 0)
            start_sec = start_ms / 1000.0

            if limit_seconds and start_sec > limit_seconds:
                break

            segs = event.get('segs', [])
            line = ''.join(seg.get('utf8', '') for seg in segs).strip()
            if line and line != '\n':
                texts.append(line)

        if not texts:
            raise ValueError("❌ 字幕檔案為空，無法擷取逐字稿。")

        return " ".join(texts)


youtube_service = YouTubeService()
