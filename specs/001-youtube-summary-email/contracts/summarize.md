# API 契約 (API Contract): POST /api/v1/summarize

**端點 (Endpoint)**: `POST /api/v1/summarize`
**說明 (Description)**: 啟動 YouTube 影片總結任務。

## 請求 (Request Body)

- **Content-Type**: `application/json`

| 欄位 (Field) | 類型 (Type) | 是否必填 (Required) | 說明 (Description) |
|--------------|-------------|---------------------|--------------------|
| `url` | String | 是 | YouTube 影片網址 |
| `userId` | UUID | 是 | 使用者 ID |

## 回應 (Responses)

### 202 Accepted

```json
{
  "taskId": "UUID",
  "status": "processing",
  "message": "任務已加入排程"
}
```

---

# API 契約 (API Contract): GET /api/v1/tasks/{taskId}

**端點 (Endpoint)**: `GET /api/v1/tasks/{taskId}`
**說明 (Description)**: 查詢總結任務狀態與內容。

## 回應 (Responses)

### 200 OK (完成)

```json
{
  "taskId": "UUID",
  "status": "success",
  "content": "# Title\n## TL;DR\n...",
  "video_id": "..."
}
```

### 200 OK (處理中)

```json
{
  "taskId": "UUID",
  "status": "processing"
}
```

---

# API 契約 (API Contract): POST /api/v1/tasks/{taskId}/send-email

**端點 (Endpoint)**: `POST /api/v1/tasks/{taskId}/send-email`
**說明 (Description)**: 手動觸發總結內容發送至使用者 Email。

## 請求 (Request Body)

| 欄位 (Field) | 類型 (Type) | 是否必填 (Required) | 說明 (Description) |
|--------------|-------------|---------------------|--------------------|
| `email` | String | 是 | 目標 Email 地址 |

## 回應 (Responses)

### 200 OK

```json
{
  "status": "success",
  "message": "郵件已發送"
}
```
