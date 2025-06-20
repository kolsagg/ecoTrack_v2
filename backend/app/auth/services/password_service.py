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
        Güvenlik nedeniyle email adresi sistemde olsun ya da olmasın
        her durumda aynı mesaj döndürülür.
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
                "message": "Eğer bu email adresi sistemimizde kayıtlıysa, şifre sıfırlama bağlantısı gönderilecektir"
            }
            
        except Exception as e:
            logger.error(f"Error sending password reset email for {email}: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="İstek işlenirken bir hata oluştu"
            ) from e

    async def _check_user_exists_in_auth(self, email: str) -> bool:
        """
        Supabase auth sisteminde kullanıcının var olup olmadığını kontrol et.
        Bu metod artık kullanılmıyor ama gelecekte gerekirse buradadır.
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
                return {"message": "Şifre başarıyla sıfırlandı"}
            else:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Şifre sıfırlama başarısız oldu"
                )
                
        except Exception as e:
            logger.error(f"Error confirming password reset: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Geçersiz token veya şifre sıfırlama süresi dolmuş"
            ) from e

# Create global password service instance
password_service = PasswordService() 