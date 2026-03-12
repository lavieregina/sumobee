# 快速開始 (Quickstart): SumoBee (MVP v1.0)

## 1. 後端 (API) 設定

**環境需求**: Python 3.11+

1. **進入 API 目錄**: `cd api`
2. **安裝依賴**: `pip install -r requirements.txt`
3. **設定環境變數**: 建立 `.env` 檔案並填入以下內容：
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   RESEND_API_KEY=your_resend_api_key
   ```
4. **啟動開發伺服器**: `uvicorn src.main:app --reload`

### API 使用範例

#### A. 提交總結請求
```bash
curl -X POST http://localhost:8000/api/v1/summarize \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ", "userId": "YOUR_UUID"}'
```
回應：`{"status": "processing", "taskId": "TASK_UUID"}`

#### B. 輪詢任務狀態
```bash
curl http://localhost:8000/api/v1/tasks/TASK_UUID
```
回應：`{"status": "success", "content": "Markdown內容...", "video_id": "..."}`

#### C. 手動發送郵件
```bash
curl -X POST http://localhost:8000/api/v1/tasks/TASK_UUID/send-email \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com"}'
```

## 2. 前端 (Mobile) 設定

**環境需求**: Flutter SDK 3.x

1. **進入 Mobile 目錄**: `cd mobile`
2. **安裝依賴**: `flutter pub get`
3. **配置 API**: 在 `lib/services/api_service.dart` 中修改 `baseUrl` 為後端位址。
4. **執行**: `flutter run`

## 3. 測試指南

- **執行後端 TDD 測試**: `$env:PYTHONPATH="."; cd api; pytest`
- **執行前端 Widget 測試**: `cd mobile; flutter test`
- **可觀測性**: 透過 `TelemetryService` 監控成功率，確保符合 SC-002 (98%)。
