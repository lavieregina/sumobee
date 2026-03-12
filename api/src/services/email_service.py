import os

import resend
from dotenv import load_dotenv

load_dotenv()

RESEND_API_KEY = os.getenv("RESEND_API_KEY")

class EmailService:
    def __init__(self):
        if not RESEND_API_KEY:
            raise ValueError("RESEND_API_KEY must be set in environment variables")
        resend.api_key = RESEND_API_KEY

    def send_summary_email(self, to_email: str, subject: str, content_html: str):
        params = {
            "from": "SumoBee <onboarding@resend.dev>",
            "to": [to_email],
            "subject": subject,
            "html": content_html,
        }
        return resend.Emails.send(params)

    def send_otp_email(self, to_email: str, otp: str):
        params = {
            "from": "SumoBee <onboarding@resend.dev>",
            "to": [to_email],
            "subject": "SumoBee 驗證碼",
            "html": f"<p>您的驗證碼為：<strong>{otp}</strong></p>",
        }
        return resend.Emails.send(params)

email_service = EmailService()
