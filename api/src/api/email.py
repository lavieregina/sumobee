from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from src.services.email_service import email_service
from src.services.supabase_client import supabase

router = APIRouter()

class EmailRequest(BaseModel):
    email: str

@router.post("/tasks/{task_id}/send-email")
async def send_summary_email(task_id: str, request: EmailRequest):
    # 1. 取得任務內容
    res = supabase.table("summary_tasks").select("*").eq("id", task_id).single().execute()
    task = res.data
    if not task:
        raise HTTPException(status_code=404, detail="找不到總結任務")

    if task["status"] != "success":
        raise HTTPException(status_code=400, detail="總結尚未完成，無法發送郵件")

    # 2. 呼叫郵件服務
    subject = f"SumoBee 影片總結：{task['video_id']}"
    content_html = f"<div>{task['content']}</div>" # 簡單包裝

    try:
        email_service.send_summary_email(request.email, subject, content_html)
        return {"status": "success", "message": "郵件已發送"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"郵件發送失敗：{str(e)}")

# TODO: 實作 OTP 驗證端點
