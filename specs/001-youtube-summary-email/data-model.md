# 資料模型 (Data Model): SumoBee (知識擷取 MVP v1.0)

## 1. 使用者 (User)

**資料表名稱**: `profiles` (Supabase `auth.users` 的擴充)

| 欄位名稱 (Field) | 類型 (Type) | 說明 (Description) | 驗證規則 (Validation) |
|------------------|-------------|--------------------|-----------------------|
| `id` | UUID | 主鍵 (與 Auth 關聯) | 唯一 |
| `email` | String | 使用者電子郵件 | 格式正確, 已驗證 |
| `created_at` | Timestamp | 註冊時間 | 自動生成 |
| `monthly_limit` | Integer | 每月總結額度 | 預設為 3 (免費版) |
| `current_usage` | Integer | 本月已用總結次數 | 每次總結成功後 +1 |
| `last_reset_date`| Timestamp | 額度重置時間 | 每月重置一次 |
| `is_pro` | Boolean | 是否為付費版使用者 | 預設為 false |

## 2. 總結任務 (Summary Task)

**資料表名稱**: `summary_tasks`

| 欄位名稱 (Field) | 類型 (Type) | 說明 (Description) | 驗證規則 (Validation) |
|------------------|-------------|--------------------|-----------------------|
| `id` | UUID | 任務唯一識別碼 | 唯一 |
| `user_id` | UUID | 請求的使用者 ID | 必填 (外鍵) |
| `video_url` | String | 影片原始網址 | 必填 |
| `video_id` | String | YouTube 影片 ID | 必填 (快取索引) |
| `status` | Enum | 狀態: `processing`, `success`, `error` | 必填 |
| `content` | Text | AI 生成的 Markdown 總結內容 | 成功時必填 |
| `error_message` | Text | 錯誤詳細訊息 | 失敗時必填 |
| `created_at` | Timestamp | 任務建立時間 | 自動生成 |
| `completed_at` | Timestamp | 任務完成時間 | 成功或失敗時填入 |

## 3. 狀態轉換 (State Transitions)

1. `processing` -> `success`: 總結生成並儲存完成。
2. `processing` -> `error`: 失敗（超時、無字幕、API 錯誤）。
3. 成功後觸發使用者 `current_usage` 更新。
