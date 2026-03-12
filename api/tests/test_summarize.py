from unittest.mock import MagicMock

import pytest
from httpx import ASGITransport, AsyncClient

from src.main import app


@pytest.mark.asyncio
async def test_summarize_endpoint_success(mocker):
    # Mock UsageService (額度檢查)
    mocker.patch("src.api.summarize.usage_service.check_and_update_usage", return_value=True)
    # Mock Supabase Table (寫入任務)
    mocker.patch("src.api.summarize.supabase.table", return_value=MagicMock())

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/summarize",
            json={
                "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
                "userId": "550e8400-e29b-41d4-a716-446655440000"
            }
        )
    assert response.status_code == 202
    assert response.json()["status"] == "processing"

@pytest.mark.asyncio
async def test_summarize_endpoint_invalid_url():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/summarize",
            json={
                "url": "not-a-youtube-url",
                "userId": "550e8400-e29b-41d4-a716-446655440000"
            }
        )
    assert response.status_code == 400
