import uuid
from datetime import datetime

from fastapi import APIRouter, BackgroundTasks, HTTPException
from pydantic import BaseModel

from src.services.gemini_service import gemini_service
from src.services.groq_service import groq_service
from src.services.supabase_client import supabase
from src.services.youtube_service import youtube_service

router = APIRouter()

class SummarizeRequest(BaseModel):
    url: str
    userId: str
    geminiApiKey: str | None = None  # 保留向下相容
    groqApiKey: str | None = None    # 優先使用 Groq
    language: str | None = "繁體中文"
    summaryDetail: str | None = "精簡 (Concise)"

import asyncio

from src.services.usage_service import usage_service


async def process_summary_task(task_id: str, video_id: str, user_id: str, api_key: dict | None = None, language: str = "繁體中文", detail: str = "精簡 (Concise)"):
    try:
        # 1. 檢查是否有快取
        cached_content = usage_service.get_existing_summary(video_id)
        if cached_content:
            supabase.table("summary_tasks").update({
                "status": "success",
                "content": cached_content,
                "completed_at": datetime.now().isoformat()
            }).eq("id", task_id).execute()
            return

        # 2. 擷取字幕與生成總結 (加入 90s 超時控制)
        try:
            # 擷取字幕
            transcript = youtube_service.get_transcript(video_id, limit_seconds=900)

            # 調用 AI 生成總結 (優先 Groq，其次 Gemini)
            summary = await asyncio.wait_for(
                groq_service.summarize_transcript(transcript, api_key=api_key.get('groq'), language=language, detail=detail)
                if api_key.get('groq') else
                gemini_service.summarize_transcript(transcript, api_key=api_key.get('gemini'), language=language, detail=detail),
                timeout=90.0
            )

            # 更新成功狀態
            supabase.table("summary_tasks").update({
                "status": "success",
                "content": summary,
                "completed_at": datetime.now().isoformat()
            }).eq("id", task_id).execute()

            # 增加使用者使用量
            usage_service.increment_usage(user_id)

        except asyncio.TimeoutError:
            # 超時處理 (T022): 標記錯誤且不扣額度 (或在此歸還)
            supabase.table("summary_tasks").update({
                "status": "error",
                "error_message": "處理超時 (超過 90 秒)",
                "completed_at": datetime.now().isoformat()
            }).eq("id", task_id).execute()
            # 這裡不呼叫 increment_usage，等同於歸還額度

    except Exception as e:
        supabase.table("summary_tasks").update({
            "status": "error",
            "error_message": str(e),
            "completed_at": datetime.now().isoformat()
        }).eq("id", task_id).execute()

@router.post("/summarize", status_code=202)
async def summarize_video(request: SummarizeRequest, background_tasks: BackgroundTasks):
    video_id = youtube_service.extract_video_id(request.url)
    if not video_id:
        raise HTTPException(status_code=400, detail="無效的 YouTube 網址")

    # 檢查額度 (T015)
    usage_service.check_and_update_usage(request.userId)

    # 建立任務紀錄
    task_id = str(uuid.uuid4())
    supabase.table("summary_tasks").insert({
        "id": task_id,
        "user_id": request.userId,
        "video_url": request.url,
        "video_id": video_id,
        "status": "processing"
    }).execute()

    # 加入背景任務執行
    api_keys = {
        'groq': request.groqApiKey,
        'gemini': request.geminiApiKey,
    }
    background_tasks.add_task(process_summary_task, task_id, video_id, request.userId, api_keys, request.language, request.summaryDetail)

    return {"status": "processing", "taskId": task_id}
