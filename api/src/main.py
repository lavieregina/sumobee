
from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

app = FastAPI(title="SumoBee API", version="1.0.0")

# 允許跨域請求 (Flutter Web 在 localhost:3000 呼叫 localhost:8000)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"status": "error", "message": f"伺服器內部錯誤：{str(exc)}"},
    )

@app.get("/")
async def root():
    return {"message": "SumoBee API is running"}

from src.api.email import router as email_router
from src.api.summarize import router as summarize_router
from src.api.tasks import router as tasks_router

app.include_router(summarize_router, prefix="/api/v1")
app.include_router(tasks_router, prefix="/api/v1")
app.include_router(email_router, prefix="/api/v1")
