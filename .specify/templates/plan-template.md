# 實作計畫 (Implementation Plan): [FEATURE]

**分支 (Branch)**: `[###-feature-name]` | **日期 (Date)**: [DATE] | **規格 (Spec)**: [連結]
**輸入 (Input)**: 來自 `/specs/[###-feature-name]/spec.md` 的功能規格

**附註**: 此模板由 `/speckit.plan` 指令填充。詳細執行流程請參閱 `.specify/templates/plan-template.md`。

## 摘要 (Summary)

[從功能規格中擷取：主要需求 + 研究得出的技術方案]

## 技術背景 (Technical Context)

<!--
  需要執行：請將本節內容替換為專案的技術細節。
  此處的結構僅供參考，以引導反覆運算過程。
-->

**語言/版本 (Language/Version)**: [例如：Python 3.11, Swift 5.9, Rust 1.75 或「需要釐清」]  
**主要依賴 (Primary Dependencies)**: [例如：FastAPI, UIKit, LLVM 或「需要釐清」]  
**儲存 (Storage)**: [若適用，例如：PostgreSQL, CoreData, 檔案或「不適用」]  
**測試 (Testing)**: [例如：pytest, XCTest, cargo test 或「需要釐清」]  
**目標平台 (Target Platform)**: [例如：Linux server, iOS 15+, WASM 或「需要釐清」]
**專案類型 (Project Type)**: [例如：函式庫/CLI/網路服務/行動應用程式/編譯器/桌面應用程式 或「需要釐清」]  
**效能目標 (Performance Goals)**: [領域特定，例如：1000 req/s, 10k lines/sec, 60 fps 或「需要釐清」]  
**限制 (Constraints)**: [領域特定，例如：<200ms p95, <100MB 記憶體, 支援離線 或「需要釐清」]  
**規模/範圍 (Scale/Scope)**: [領域特定，例如：10k 使用者, 1M 程式碼行數, 50 個螢幕 或「需要釐清」]

## 憲法檢查 (Constitution Check)

*閘道：必須在第 0 階段研究之前通過。在第 1 階段設計後重新檢查。*

[根據憲法文件確定的檢查項]

## 專案結構 (Project Structure)

### 文件 (此功能)

```text
specs/[###-feature]/
├── plan.md              # 此檔案 (/speckit.plan 指令輸出)
├── research.md          # 第 0 階段輸出 (/speckit.plan 指令)
├── data-model.md        # 第 1 階段輸出 (/speckit.plan 指令)
├── quickstart.md        # 第 1 階段輸出 (/speckit.plan 指令)
├── contracts/           # 第 1 階段輸出 (/speckit.plan 指令)
└── tasks.md             # 第 2 階段輸出 (/speckit.tasks 指令 - 非由 /speckit.plan 建立)
```

### 原始碼 (存放庫根目錄)
<!--
  需要執行：請將下方的佔位符目錄樹替換為此功能的具體配置。
  刪除未使用的選項，並使用實際路徑擴展所選結構 (例如：apps/admin, packages/something)。
  交付的計畫中不應包含「選項」標籤。
-->

```text
# [若未使用則刪除] 選項 1：單一專案 (預設)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [若未使用則刪除] 選項 2：Web 應用程式 (當偵測到「前端」+「後端」時)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [若未使用則刪除] 選項 3：行動裝置 + API (當偵測到「iOS/Android」時)
api/
└── [與上方後端相同]

ios/ 或 android/
└── [平台特定結構：功能模組、UI 流程、平台測試]
```

**結構決策**: [記錄所選結構並引用上方擷取的實際目錄]

## 複雜度追蹤 (Complexity Tracking)

> **僅當「憲法檢查」出現違規且必須進行合理化說明時才填寫**

| 違規項 (Violation) | 為何需要 (Why Needed) | 拒絕更簡單替代方案的理由 (Simpler Alternative Rejected Because) |
|--------------------|-----------------------|---------------------------------------------------------------|
| [例如：第 4 個專案] | [目前需求] | [為何 3 個專案不足夠] |
| [例如：Repository 模式] | [特定問題] | [為何直接存取資料庫不足夠] |
