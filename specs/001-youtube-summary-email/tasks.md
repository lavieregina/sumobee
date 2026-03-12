---

description: "SumoBee (知識擷取 MVP v1.0) 實作任務列表 - 分析修正版"
---

# 任務列表 (Tasks): SumoBee (知識擷取 MVP v1.0)

**輸入 (Input)**: 來自 `/specs/001-youtube-summary-email/` 的設計文件
**先決條件 (Prerequisites)**: plan.md, spec.md, research.md, data-model.md, contracts/summarize.md
**憲法狀態**: 已根據 TDD 與 簡約性原則 進行優化

**格式**: `[ID] [P?] [情境] 描述`

---

## 第 1 階段：設定 (共用基礎建設)

- [X] T001 根據實作計畫建立 `api/` (Python) 與 `mobile/` (Flutter) 目錄結構
- [X] T002 初始化 FastAPI 專案，建立 `api/requirements.txt` 並安裝依賴
- [X] T003 初始化 Flutter 專案，設定 `mobile/pubspec.yaml` 並執行 `flutter pub get`
- [X] T004 [P] 設定 Python (Ruff) 與 Dart (Analysis Options) 的 Linting 工具

---

## 第 2 階段：基礎架構 (阻塞性先決條件)

- [X] T005 在 Supabase 控制台建立專案並設定 `profiles` 與 `summary_tasks` 資料表
- [X] T006 實作後端資料庫連接客戶端於 `api/src/services/supabase_client.py`
- [X] T007 [P] 實作 Google Gemini AI 總結服務於 `api/src/services/gemini_service.py` (含 zh-TW 強制輸出邏輯)
- [X] T008 [P] 實作 Resend 郵件發送服務於 `api/src/services/email_service.py`
- [X] T009 [P] 實作 YouTube 字幕擷取於 `api/src/services/youtube_service.py` (包含免費版 15 分鐘截斷邏輯)
- [X] T010 [P] 設定 FastAPI 環境變數管理與錯誤處理框架於 `api/src/main.py`

---

## 第 3 階段：使用者情境 1 - 透過分享選單擷取網址 (優先順序: P1) 🎯 MVP

**目標**: 實現從分享選單接收 URL 並啟動任務

### 測試 (TDD FIRST)
- [X] T011 [P] [US1] 在 `api/tests/test_summarize.py` 進行 `/api/v1/summarize` 端點測試
- [X] T012 [P] [US1] 在 `mobile/test/sharing_test.dart` 模擬分享意圖接收測試

### 實作
- [X] T013 [P] [US1] 在 Flutter 實作 `mobile/lib/services/sharing_service.dart` (處理分享意圖)
- [X] T014 [US1] 在 `api/src/api/summarize.py` 實作總結請求端點 (網址解析與排程)
- [X] T015 [US1] 實作後端額度檢查與重複偵測：包含 Lazy Evaluation 自動跨月重置 `current_usage`
- [X] T016 [US1] 實作異步總結排程與 `processing` 狀態管理
- [X] T017 [US1] 實作任務查詢端點 `GET /api/v1/tasks/{taskId}` 於 `api/src/api/tasks.py`

---

## 第 4 階段：使用者情境 2 - 在 App 預覽總結並寄送郵件 (優先順序: P1)

**目標**: 內容預覽與手動發信

### 測試 (TDD FIRST)
- [X] T018 [P] [US2] 在 `api/tests/test_email.py` 進行發信端點與 OTP 邏輯測試
- [X] T019 [P] [US2] 在 `mobile/test/preview_test.dart` 測試 Markdown 預覽畫面渲染

### 實作
- [X] T020 [US2] 在 `mobile/lib/screens/preview_screen.dart` 實作總結預覽 (支援 Markdown)
- [X] T021 [US2] 在 `api/src/api/email.py` 實作 `/send-email` 端點與 OTP 驗證邏輯
- [X] T022 [US2] 實作「後端自動超時檢測」：若任務 >90s 未完成，自動標記 error 並歸還額度

---

## 第 5 階段：使用者情境 3 - 管理個人使用限額與設定 (優先順序: P2)

**目標**: 使用者儀表板

### 測試 (TDD FIRST)
- [X] T023 [P] [US3] 在 `mobile/test/dashboard_test.dart] 測試額度顯示邏輯

### 實作
- [X] T024 [US3] 在 `mobile/lib/screens/dashboard_screen.dart`實作儀表板 UI
- [X] T025 [US3] 串接 Supabase `profiles` 資料實作額度讀取與教學區塊

---

## 第 N 階段：磨光與可觀測性 (Polish & Observability)

- [X] T026 [P] 在 `api/src/services/telemetry.py` 實作簡單日誌統計，以測量 SC-002 (98% 成功率)
- [X] T027 更新 `specs/001-youtube-summary-email/quickstart.md` 包含 OTP 與 輪詢範例
- [X] T028 執行全流程整合測試與 API 性能優化 (SC-001)

---

## 備註 (Notes)
- 憲法遵從：已確保所有實作階段皆具備 TDD 測試任務。
- 額度邏輯：由後端 API 統一處理 Lazy Reset 與超時自動退款。
