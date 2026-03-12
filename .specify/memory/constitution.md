<!--
Sync Impact Report:
- Version change: 1.1.0 → 1.2.0
- List of modified principles: - 規格先行 (Specification-First): 加入「所有規格文件（spec.md, plan.md 等）必須使用繁體中文」的語言規範。
- Added sections: VI. 簡約性與複雜度控管 (Simplicity & Complexity Control)
- Templates requiring updates:
  - @.specify/templates/spec-template.md (✅ 已翻譯為繁體中文)
  - @.specify/templates/plan-template.md (✅ 確保內容與標題一致且已翻譯)
  - @.specify/templates/tasks-template.md (✅ 確保內容與標題一致且已翻譯)
  - @.specify/templates/checklist-template.md (✅ 已翻譯為繁體中文)
  - @.specify/templates/agent-file-template.md (✅ 已翻譯為繁體中文)
- Follow-up TODOs: 無
-->

# SpecKit 憲法 (Constitution)

## 核心原則 (Core Principles)

### I. 規格先行 (Specification-First)
所有功能開發必須在實作前完成規格說明 (`spec.md`) 與實作計畫 (`plan.md`)。**為了確保團隊溝通的一致性，所有規格文件與設計文件必須統一使用「繁體中文」撰寫。**這確保所有的技術決策都經過深思熟慮，並且具備長期的可維護性。未經規劃的實作是不被允許的。

### II. 使用者情境導向且可獨立測試 (Story-Driven & Independent Testing)
功能必須拆解為具備優先順序 (P1, P2, P3) 的使用者情境 (User Stories)。每個情境必須是獨立且可測試的，確保開發過程可以增量交付，且每個增量都具備完整的價值與品質。

### III. 基礎建設優先 (Foundation First)
在實作任何具體的使用者情境之前，必須先完成必要的基礎架構 (Foundational Phase)。這包括資料庫結構、核心服務框架、錯誤處理與日誌系統，確保應用程式建立在穩固的基礎之上。

### IV. 測試驅動開發 (Test-Driven Development, TDD)
開發必須遵循嚴格的 TDD 循環：
1. **Red**: 編寫一個會失敗的測試，定義預期行為。
2. **Green**: 編寫最少量的程式碼使測試通過。
3. **Refactor**: 在確保測試通過的前提下，重構程式碼以優化結構。
測試不僅是驗證工具，更是設計工具。所有邏輯變更必須有對應的測試覆蓋。

### V. 模組化設計與清晰路徑 (Modular Design & Explicit Paths)
遵循嚴格的專案結構與檔案命名慣例。程式碼應高度模組化，確保高內聚與低耦合。所有任務描述必須包含明確的檔案路徑，以消除實作時的歧義。

### VI. 簡約性與複雜度控管 (Simplicity & Complexity Control)
始終追求最簡單的解決方案，避免過度工程 (YAGNI)。任何增加系統複雜度的決策必須在實作計畫中進行合理化說明，並說明為何不採用更簡單的替代方案。

## 治理規範 (Governance)

### 修訂程序
本憲法優於所有其他的開發慣例。任何對憲法的修改必須經過正式的提案、文檔化更新、版本變更說明，並制定現有專案的遷移或適應計畫。

### 合規性審查
所有的程式碼審查 (PR) 與設計檢閱必須驗證是否符合本憲法的核心原則。任何違反原則的實作除非有極其特殊的理由且已在計畫中註明，否則應予以退回。

### 版本控制原則
憲法版本遵循語意化版本 (Semantic Versioning)：
- **MAJOR**: 不相容的治理規則或原則重定義。
- **MINOR**: 新增原則、擴充指南或非破壞性變更。
- **PATCH**: 文字修飾、排版更正或不影響語意的澄清。

**Version**: 1.2.0 | **Ratified**: 2026-02-05 | **Last Amended**: 2026-03-09