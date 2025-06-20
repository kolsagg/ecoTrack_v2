from typing import Dict
from fastapi import HTTPException, status
from app.core.config import settings

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
            # Email adresinin sistemde olup olmadığını kontrol et
            user_exists = await self._check_user_exists(email)
            
            if user_exists:
                # Kullanıcı mevcutsa gerçekten email gönder
                self.client.auth.reset_password_email(
                    email,
                    {
                        "redirect_to": f"{settings.FRONTEND_URL}/auth/reset-password"
                    }
                )
            
            # Her durumda aynı güvenli mesaj döndür
            return {
                "message": "Eğer bu email adresi sistemimizde kayıtlıysa, şifre sıfırlama bağlantısı gönderilecektir"
            }
            
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="İstek işlenirken bir hata oluştu"
            )

    async def _check_user_exists(self, email: str) -> bool:
        """
        Email adresinin sistemde kayıtlı olup olmadığını kontrol et.
        Bu bilgi sadece sistem içinde kullanılır, dışarıya sızmaz.
        """
        try:
            # Users tablosundan email adresini ara
            result = self.client.table("users").select("id").eq("email", email).execute()
            return len(result.data) > 0
        except Exception:
            # Hata durumunda güvenli tarafta kalarak True döndür
            # Böylece email gönderilmeye çalışılır (Supabase zaten kontrol eder)
            return True

    async def confirm_password_reset(self, token: str, new_password: str) -> Dict[str, str]:
        """
        Confirm password reset with token and new password.
        """
        try:
            self.client.auth.update_user({
                "password": new_password
            })
            return {"message": "Şifre başarıyla sıfırlandı"}
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=str(e)
            )

# Create global password service instance
password_service = PasswordService() 