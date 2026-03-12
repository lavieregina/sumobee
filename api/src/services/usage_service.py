from datetime import datetime, timezone

from fastapi import HTTPException

from src.services.supabase_client import supabase


class UsageService:
    def check_and_update_usage(self, user_id: str):
        # 1. 取得使用者 Profile
        res = supabase.table("profiles").select("*").eq("id", user_id).single().execute()
        profile = res.data
        if not profile:
            raise HTTPException(status_code=404, detail="找不到使用者資料")

        # 2. Lazy Evaluation: 檢查是否需要跨月重置
        last_reset = datetime.fromisoformat(profile["last_reset_date"])
        now = datetime.now(timezone.utc)
        if last_reset.year < now.year or last_reset.month < now.month:
            # 跨月重置
            supabase.table("profiles").update({
                "current_usage": 0,
                "last_reset_date": now.isoformat()
            }).eq("id", user_id).execute()
            profile["current_usage"] = 0

        # 3. 檢查額度
        if profile["current_usage"] >= profile["monthly_limit"]:
            raise HTTPException(status_code=403, detail="本月總結額度已用完")

        return True

    def increment_usage(self, user_id: str):
        # 原子性增加使用量 (在真實環境建議用 RPC)
        res = supabase.table("profiles").select("current_usage").eq("id", user_id).single().execute()
        current = res.data["current_usage"]
        supabase.table("profiles").update({"current_usage": current + 1}).eq("id", user_id).execute()

    def get_existing_summary(self, video_id: str):
        # 重複偵測 (FR-007): 尋找同一影片且成功的最近總結
        res = supabase.table("summary_tasks") \
            .select("content") \
            .eq("video_id", video_id) \
            .eq("status", "success") \
            .order("created_at", desc=True) \
            .limit(1).execute()
        return res.data[0]["content"] if res.data else None

usage_service = UsageService()
