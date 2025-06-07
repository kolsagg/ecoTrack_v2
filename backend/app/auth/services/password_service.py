from typing import Dict
from fastapi import HTTPException, status
from app.core.config import settings

class PasswordService:
    def __init__(self):
        self.client = settings.supabase

    async def reset_password(self, email: str) -> Dict[str, str]:
        """
        Send password reset email.
        """
        try:
            # Send password reset email with redirect URL
            self.client.auth.reset_password_email(
                email,
                {
                    "redirect_to": f"{settings.FRONTEND_URL}/auth/reset-password"
                }
            )
            return {"message": "Password reset email sent successfully"}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

    async def confirm_password_reset(self, token: str, new_password: str) -> Dict[str, str]:
        """
        Confirm password reset with token and new password.
        """
        try:
            self.client.auth.update_user({
                "password": new_password
            })
            return {"message": "Password reset successfully"}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

# Create global password service instance
password_service = PasswordService() 