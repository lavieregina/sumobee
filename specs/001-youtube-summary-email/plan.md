# 實作計畫 (Implementation Plan): SumoBee (知識擷取 MVP v1.0)

**分支 (Branch)**: `001-youtube-summary-email` | **日期 (Date)**: 2026-03-09 | **規格 (Spec)**: [specs/001-youtube-summary-email/spec.md](specs/001-youtube-summary-email/spec.md)
**輸入 (Input)**: 來自 `/specs/001-youtube-summary-email/spec.md` 的功能規格

## 摘要 (Summary)

SumoBee 是一個行動應用程式，允許使用者分享 YouTube 網址以獲取 AI 生成的 300 字繁體中文總結。系統將使用 Flutter 作為前端框架處理分享意圖，後端則使用 Python (FastAPI) 整合 YouTube 字幕擷取、Gemini API 總結邏輯，以及 Resend API 進行電子郵件發送。資料儲存與使用者額度管理將委託給 Supabase。

## 技術背景 (Technical Context)

**Language/Version**: Python 3.11+ (後端), Dart 3.x / Flutter 3.x (前端)
**Primary Dependencies**: FastAPI, `youtube-transcript-api`, `google-generativeai`, `resend`, `flutter_sharing_intent`
**Storage**: Supabase (PostgreSQL + Auth)
**Testing**: pytest (後端), flutter test (前端)
**Target Platform**: iOS, Android, Serverless
**Project Type**: Mobile App + API
**Performance Goals**: 總結生成與預覽需在 60 秒內完成 (SC-001)
**Constraints**: 免費版限制每月 3 次總結，單次影片長度限制 15 分鐘 (FR-005)
**Scale/Scope**: MVP v1.0 核心流程實作

## 憲法檢查 (Constitution Check)

*閘道：必須在第 0 階段研究之前通過。在第 1 階段設計後重新檢查。*

1. **規格先行 (Specification-First)**: 已完成 `spec.md` 且全文使用繁體中文撰寫。(✅ 通過)
2. **情境導向且可獨立測試 (Story-Driven)**: 規格中已定義 P1、P2 情境與驗收標準。(✅ 通過)
3. **基礎建設優先 (Foundation First)**: 本計畫優先處理 Supabase 整合與 AI 總結核心邏輯。(✅ 通過)
4. **簡約性與複雜度控管 (Simplicity)**: 選用 `gemini-1.5-flash` 以兼顧低延遲與低成本，避免過度工程。(✅ 通過)

## 專案結構 (Project Structure)

### 文件 (此功能)

```text
specs/001-youtube-summary-email/
├── plan.md              # 此檔案
├── research.md          # 第 0 階段輸出
├── data-model.md        # 第 1 階段輸出
├── quickstart.md        # 第 1 階段輸出
├── contracts/           # 第 1 階段輸出
└── tasks.md             # 第 2 階段輸出
```

### 原始碼 (存放庫根目錄)

```text
api/                     # 後端 Python (FastAPI)
├── src/
│   ├── api/             # 路由定義 (summarize 端點)
│   ├── services/        # 核心邏輯 (YouTube, Gemini, Email)
│   ├── models/          # Pydantic 實體
│   └── main.py          # 進入點
└── tests/               # 後端測試

mobile/                  # 前端 Flutter
├── lib/
│   ├── services/        # API 客戶端, 分享處理
│   ├── screens/         # UI 畫面 (預覽, 儀表板)
│   └── main.dart        # 進入點
└── test/                # 前端測試
```

**結構決策**: 採用 `api/` 與 `mobile/` 雙目錄結構，明確拆分後端服務與行動應用程式邏輯，符合模組化原則。

## 複雜度追蹤 (Complexity Tracking)

> **僅當 憲法檢查 出現違規且必須進行合理化說明時才填寫**

| 違規項 (Violation) | 為何需要 (Why Needed) | 拒絕更簡單替代方案的理由 (Simpler Alternative Rejected Because) |
|--------------------|-----------------------|---------------------------------------------------------------|
| 無 | N/A | N/A |
