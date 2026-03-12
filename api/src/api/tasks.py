from fastapi import APIRouter, HTTPException

from src.services.supabase_client import supabase

router = APIRouter()

@router.get("/tasks/{task_id}")
async def get_task_status(task_id: str):
    res = supabase.table("summary_tasks").select("*").eq("id", task_id).single().execute()
    task = res.data
    if not task:
        raise HTTPException(status_code=404, detail="找不到任務")

    return {
        "taskId": task["id"],
        "status": task["status"],
        "content": task.get("content"),
        "error_message": task.get("error_message"),
        "video_id": task["video_id"]
    }
