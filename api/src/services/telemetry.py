import logging

from src.services.supabase_client import supabase

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("telemetry")

class TelemetryService:
    def log_task_completion(self, task_id: str, status: str):
        # 簡單的日誌記錄，後續可擴展至 Prometheus 或 Supabase Stats
        logger.info(f"Task {task_id} completed with status: {status}")

    def get_success_rate(self) -> float:
        # 從 Supabase 統計成功率
        res = supabase.table("summary_tasks").select("status").execute()
        tasks = res.data
        if not tasks:
            return 1.0
        success_count = sum(1 for t in tasks if t["status"] == "success")
        return success_count / len(tasks)

telemetry = TelemetryService()
