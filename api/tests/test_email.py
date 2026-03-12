from unittest.mock import MagicMock

import pytest
from httpx import ASGITransport, AsyncClient

from src.main import app


@pytest.mark.asyncio
async def test_send_email_endpoint_success(mocker):
    # Mock Supabase (讀取任務)
    mock_supabase = mocker.patch("src.api.email.supabase")
    mock_supabase.table().select().eq().single().execute.return_value = MagicMock(
        data={"status": "success", "content": "Test content", "video_id": "abc"}
    )

    # Mock Email Service
    mocker.patch("src.api.email.email_service.send_summary_email", return_value=True)

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as ac:
        response = await ac.post(
            "/api/v1/tasks/550e8400-e29b-41d4-a716-446655440000/send-email",
            json={"email": "user@example.com"}
        )
    assert response.status_code == 200
    assert response.json()["status"] == "success"
