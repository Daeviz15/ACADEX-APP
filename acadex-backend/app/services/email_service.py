"""
Email Service — For sending transactional emails via SMTP.

Best practices:
  • Raw smtplib is synchronous and blocks the web server. Wrapping it in 
    `asyncio.to_thread` guarantees it runs natively in the background without blocking FastAPI.
  • HTML + Plaintext multiparts ensure it looks perfect on mobile and desktop.
"""
import smtplib
import asyncio
from email.message import EmailMessage

from app.core.config import settings


async def send_verification_email(to_email: str, token: str, user_name: str) -> bool:
    """Send the 6-digit OTP code to the user asynchronously."""
    
    html_content = f"""
    <html>
    <head></head>
    <body style="font-family: Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 20px;">
        <div style="max-width: 500px; margin: 0 auto; padding: 30px; background-color: white; border: 1px solid #eaeaea; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
            <h2 style="color: #00664F; margin-top: 0;">Acadex Account Verification</h2>
            <p style="font-size: 16px;">Hi {user_name},</p>
            <p style="font-size: 16px;">Welcome to Acadex! Please use the following 6-digit verification code to activate your account:</p>
            
            <div style="text-align: center; margin: 40px 0;">
                <span style="font-size: 36px; font-weight: bold; letter-spacing: 8px; color: #00664F; background: #e6f0ed; padding: 15px 25px; border-radius: 8px;">{token}</span>
            </div>
            
            <p style="font-size: 16px;">This code will strictly expire in <strong>15 minutes</strong>.</p>
            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;" />
            <p style="font-size: 12px; color: #888; text-align: center;">If you did not request this email, please ignore it securely.</p>
        </div>
    </body>
    </html>
    """
    
    msg = EmailMessage()
    msg["Subject"] = "Verify your Acadex account"
    msg["From"] = f"{settings.FROM_NAME} <{settings.FROM_EMAIL}>"
    msg["To"] = to_email
    
    # Fallback for old email clients
    msg.set_content(f"Hi {user_name},\n\nYour Acadex verification code is: {token}\n\nThis code expires in 15 minutes.")
    
    # The gorgeous HTML version
    msg.add_alternative(html_content, subtype='html')

    def _send():
        try:
            with smtplib.SMTP(settings.SMTP_SERVER, settings.SMTP_PORT) as server:
                server.starttls()
                server.login(settings.SMTP_USER, settings.SMTP_PASSWORD)
                server.send_message(msg)
            return True
        except Exception as e:
            # Crucial to log this in production, but avoid crashing the signup flow!
            print(f"[ERROR] Failed to send email to {to_email}: {e}")
            return False

    # Execute the synchronous SMTP call in a non-blocking thread
    return await asyncio.to_thread(_send)
