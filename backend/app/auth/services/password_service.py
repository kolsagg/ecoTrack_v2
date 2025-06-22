from typing import Dict
from fastapi import HTTPException, status
from app.core.config import settings
import logging

logger = logging.getLogger(__name__)

class PasswordService:
    def __init__(self):
        self.client = settings.supabase

    async def reset_password(self, email: str) -> Dict[str, str]:
        """
        Send password reset email.
        For security reasons, the same message is returned regardless of
        whether the email address exists in the system or not.
        """
        try:
            # Doğrudan Supabase auth sistemine email gönderme isteği yap
            # Supabase kendi auth.users tablosunu kontrol eder
            # Eğer email yoksa sessizce başarısız olur, hata vermez
            response = self.client.auth.reset_password_email(
                email,
                {
                    "redirect_to": f"{settings.FRONTEND_URL}/auth/reset-password"
                }
            )
            
            logger.info(f"Password reset email requested for: {email}")
            
            # Her durumda aynı güvenli mesaj döndür
            return {
                "message": "If this email address is registered in our system, a password reset link will be sent."
            }
            
        except Exception as e:
            logger.error(f"Error sending password reset email for {email}: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An error occurred while processing the request"
            ) from e

    async def _check_user_exists_in_auth(self, email: str) -> bool:
        """
        Check if the user exists in the Supabase auth system.
        This method is no longer used, but it is here for future reference.
        """
        try:
            # Not: Supabase client'ı admin API'sini kullanarak auth.users'ları sorgulayabilir
            # Ama bu genellikle server-side admin işlemleri için kullanılır
            # Normal kullanım için reset_password_email direkt çağırmak daha güvenli
            return True
        except Exception:
            return True

    async def confirm_password_reset(self, token: str, new_password: str) -> Dict[str, str]:
        """
        Confirm password reset with token and new password.
        """
        try:
            response = self.client.auth.update_user({
                "password": new_password
            })
            
            if response.user:
                logger.info(f"Password successfully reset for user: {response.user.id}")
                return {"message": "Password successfully reset"}
            else:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Password reset failed"
                )
                
        except Exception as e:
            logger.error(f"Error confirming password reset: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid token or password reset expired"
            ) from e

# Create global password service instance
password_service = PasswordService() 