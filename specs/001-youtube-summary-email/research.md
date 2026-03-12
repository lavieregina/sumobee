# 研究報告 (Research Report): SumoBee (知識擷取 MVP v1.0)

## 1. 決策：前端分享意圖處理 (flutter_sharing_intent)

- **決策 (Decision)**: 使用 `flutter_sharing_intent` 插件處理 iOS/Android 的系統分享行為。
- **理由 (Rationale)**: 該插件在 Flutter 生態系中維護穩定，能同步處理 cold start 與 background 狀態下的網址擷取。
- **替代方案 (Alternatives)**: `receive_sharing_intent` (維護頻率較低)。

## 2. 決策：YouTube 字幕擷取技術 (youtube-transcript-api)

- **決策 (Decision)**: 採用 `youtube-transcript-api` (Python 庫)。
- **理由 (Rationale)**: 可以在伺服器端直接透過影片 ID 獲取字幕，不需模擬瀏覽器或使用龐大的 `yt-dlp` 下載影片。
- **風險 (Risks)**: 若影片完全沒有字幕（包括自動生成字幕），則需 fallback 至影片描述與中繼資料。

## 3. 決策：AI 總結模型與提示詞策略 (Gemini 1.5 Flash)

- **決策 (Decision)**: 使用 `gemini-1.5-flash` 並設定嚴格的 System Prompt。
- **理由 (Rationale)**: Flash 模型回應速度極快且成本低廉，支援大上下文窗口以應對長影片腳本。
- **提示詞模式 (Prompting)**: 
  - 角色：專業知識編輯。
  - 任務：將輸入文本轉換為 300 字繁體中文 Markdown 總結。
  - 格式：標題、TL;DR、關鍵要點、結論。

## 4. 決策：電子郵件服務與驗證 (Resend + OTP)

- **決策 (Decision)**: 使用 Resend API 進行 transactional email 發送。
- **理由 (Rationale)**: API 設計極簡，且提供良好的郵件送達率與追蹤功能。初次驗證將使用其發送 6 位數 OTP。
- **流程**: 使用者輸入 Email → 發送 OTP → 驗證成功 → 儲存至 Supabase。

## 5. 決策：後端服務與額度控管 (FastAPI + Supabase)

- **決策 (Decision)**: 使用 FastAPI 託管總結端點，並串接 Supabase。
- **理由 (Rationale)**: FastAPI 非同步特性適合處理耗時的 AI 任務。Supabase 用於儲存使用者資訊、額度限制（Credits）以及總結快取。
- **額度邏輯**: 每次請求前檢查 `current_usage < monthly_limit`，總結成功後原子性更新 `current_usage`。
