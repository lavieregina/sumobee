# 功能規格 (Feature Specification): SumoBee (知識擷取 MVP v1.0)

**功能分支 (Feature Branch)**: `001-youtube-summary-email`  
**建立日期 (Created)**: 2026-03-09  
**狀態 (Status)**: 草案 (Draft)  
**輸入 (Input)**: 使用者描述: "# Project Specification: SumoBee (MVP v1.0) ## 1. Description SumoBee is a micro-SaaS mobile application designed for 'Knowledge Capture.' It allows users to share a YouTube URL via the system share sheet, generates a 300-word AI summary, and sends it directly to the user's email. ## 2. User Story - **As a User**, I see a 20-minute video on YouTube but don't have time to watch. - **I click 'Share'** and select the SumoBee app icon. - **SumoBee processes** the video in the background. - **I receive an email** within 60 seconds containing a structured summary in Traditional Chinese. ## 3. Technical Requirements ### A. Frontend (Mobile) - **Framework:** Flutter or React Native. - **Core Library:** `receive_sharing_intent` (Flutter) or `react-native-share-menu`. - **UI:** - Input field for `User Email`. - Usage dashboard (Credits remaining). - 'How to use' tutorial (GIF/Image). ### B. Backend (Serverless) - **Runtime:** Node.js (TypeScript) or Python (FastAPI). - **YouTube Integration:** Use `youtube-transcript-api` or `yt-dlp` to fetch subtitles/metadata. - **AI Logic (Gemini API):** - Model: `gemini-1.5-flash` (for low latency). - Prompt: 'Summarize this YouTube transcript into a 300-word brief in Traditional Chinese (zh-TW). Use Markdown: # Title, ## TL;DR, ## Key Takeaways, ## Conclusion.' - **Email Service:** Resend API or SendGrid. ### C. Database (Lightweight) - **Provider:** Supabase or Firebase. - **Schema:** - `users`: { id, email, created_at, monthly_limit, current_usage }. ## 4. API Endpoints - `POST /api/v1/summarize` - Body: `{ 'url': string, 'userId': string, 'email': string }` - Response: `{ 'status': 'processing' | 'success' | 'error', 'message': string }` ## 5. Monetization Logic - **Tier 1 (Free):** 3 summaries per month, 15-min limit. - **Tier 2 (Pro):** $4.99/mo, Unlimited, 2hr+ video support, Notion sync. ## 6. Constraints & Edge Cases - **No Subtitles:** If no transcript is found, use Gemini to analyze the video description/comments or return an error. - **Rate Limiting:** Implement a queue to handle multiple concurrent requests. - **Language:** Force Traditional Chinese output regardless of input video language."

## 使用者情境與測試 (User Scenarios & Testing) *(必填)*

### 使用者情境 1 - 透過分享選單擷取 YouTube 知識 (優先順序: P1)

身為使用者，當我在 YouTube 上看到感興趣但沒有時間完整觀看的影片時，我可以透過系統分享功能，直接將影片網址傳送到 SumoBee 進行處理，而無需離開當前的影音應用。

**優先順序理由**: 這是產品的核心價值與入口，若無法方便地分享與擷取網址，產品將失去其作為「知識擷取」工具的便利性。

**獨立測試方式**: 啟動行動應用程式，在 YouTube App 中選擇一個影片，點擊分享並選取 SumoBee，驗證 App 能正確接收網址並顯示「正在處理」或類似的視覺回饋。

**驗收情境 (Acceptance Scenarios)**:

1. **假設 (Given)** 使用者在 YouTube App 中，**當 (When)** 點擊分享並選擇 SumoBee 且已登入/設定 Email，**那麼 (Then)** App 應開啟並自動讀取該影片網址。
2. **假設 (Given)** App 接收到網址，**當 (When)** 點擊「開始總結」或自動啟動，**那麼 (Then)** 系統應向後端發送請求並顯示處理狀態。

---

### 使用者情境 2 - 在 App 預覽 AI 總結並選擇發送郵件 (優先順序: P1)

身為使用者，在分享影片網址後的短時間內，我可以在 SumoBee App 內直接看到結構清晰、使用繁體中文撰寫的影片總結。如果我需要永久保存或在電腦閱讀，我可以點擊按鈕將此總結發送至我的電子郵件信箱。

**優先順序理由**: 這是產品的核心交付價值，提供即時預覽與靈活的郵件保存選項。

**獨立測試方式**: 執行分享流程，驗證 App 主畫面是否正確顯示總結內容，並測試點擊「寄送郵件」按鈕後，信箱是否收到正確格式的郵件。

**驗收情境 (Acceptance Scenarios)**:

1. **假設 (Given)** 後端處理完成，**當 (When)** 使用者開啟 App，**那麼 (Then)** App 應顯示包含標題、TL;DR、關鍵要點及結論的總結內容。
2. **假設 (Given)** 已顯示總結，**當 (When)** 使用者點擊「寄送電子郵件」，**那麼 (Then)** 系統應觸發發信邏輯並提示「已發送」。

---

### 使用者情境 3 - 管理個人使用限額與設定 (優先順序: P2)

身為使用者，我可以在 App 介面中看到我本月的剩餘點數（總結次數）以及設定接收郵件的地址，確保我了解我的使用狀態。

**優先順序理由**: 提供透明的使用資訊，並支援基本的使用者設定。

**獨立測試方式**: 開啟 App 主畫面，驗證是否顯示當前剩餘點數及已設定的 Email。

**驗收情境 (Acceptance Scenarios)**:

1. **假設 (Given)** 使用者已進行過總結，**當 (When)** 進入儀表板，**那麼 (Then)** 剩餘點數應正確扣除並顯示。

---

### 邊界情況 (Edge Cases)

- 當影片完全不允許讀取（如私人影片或受版權保護）時會發生什麼？系統應返回明確的「無法處理」錯誤。
- **重複網址處理**：當使用者分享已總結過的網址時，App 應提示「此影片已完成總結」並直接顯示現有內容，使用者仍可選擇重新發送郵件，系統不重複扣除額度。
- **長影片處理 (免費版)**：對於超過 15 分鐘的影片，系統僅擷取前 15 分鐘內容進行總結，並在結果中註明受限於免費版額度。
- **播放清單與 Shorts 處理**：系統支援 YouTube Shorts 總結；分享播放清單時僅處理當前播放的那一支影片。
- **處理超時與額度歸還**：若總結任務超過 90 秒未完成，系統必須發送「處理延遲通知」電子郵件，並自動歸還該次扣除的額度。

## 需求 (Requirements) *(必填)*

### 功能需求 (Functional Requirements)

- **FR-001**: 系統必須支援從行動裝置分享選單接收 YouTube URL。
- **FR-002**: 系統必須能自動擷取影片內容資訊（如字幕、描述）。
- **FR-003**: 系統必須生成約 300 字的繁體中文總結。
- **FR-004**: **App 預覽與郵件發送**：
  - **內容預覽**：系統必須在 App 介面直接展示生成後的 Markdown 總結內容。
  - **手動發送**：提供「寄送至電子郵件」功能，由使用者觸發後才將總結發送至設定的地址。
  - **初次驗證**：使用者在首次使用服務前，必須通過一次性驗證碼 (OTP) 驗證電子郵件地址。
- **FR-005**: 系統必須記錄每位使用者的每月使用量，並執行分級限制：
  - **免費版**：3 次/月，影片長度若超過 15 分鐘則僅總結前 15 分鐘內容，並附帶 Pro 升級導引。
  - **Pro 版**：無次數與長度限制。
- **FR-006**: 總結內容必須包含固定結構：標題、TL;DR、關鍵要點、結論。
- **FR-007**: **快取與重複偵測**：系統應識別重複的 URL 請求，重用現有總結且不計入使用者額度。

### 關鍵實體 (Key Entities)

- **使用者 (User)**: 包含 ID、Email、建立時間、每月限額、當前使用量。
- **總結任務 (Summary Task)**: 包含 影片網址、狀態（處理中/完成/錯誤）、生成內容、建立時間。

## 假設與限制 (Assumptions & Constraints)

- **技術假設**: 假設後端能穩定存取 YouTube 公開資訊。
- **語言限制**: 強制輸出為繁體中文 (zh-TW)，不論原始影片語言。
- **內容來源**: 若無字幕，將優先使用影片描述與中繼資料作為總結依據。

## 成功標準 (Success Criteria) *(必填)*

### 可衡量的成果 (Measurable Outcomes)

- **SC-001**: 從分享網址到收到郵件的平均時間應低於 60 秒。
- **SC-002**: 系統對具備字幕的公開 YouTube 影片處理成功率應達到 98% 以上。
- **SC-003**: 生成的總結內容必須符合繁體中文 (zh-TW) 語法與用字規範。
- **SC-004**: 免費版使用者在未升級情況下，單月總結次數限制為 3 次。
- **SC-005**: 處理超時（>90秒）的任務必須在 5 分鐘內觸發額度歸還與使用者通知。

