import logging
from typing import Dict, List, Optional
from enum import Enum
import httpx
from app.core.config import settings

logger = logging.getLogger(__name__)

class NotificationType(Enum):
    """
    Bildirim türleri
    """
    RECEIPT_RECEIVED = "receipt_received"
    LOYALTY_LEVEL_UP = "loyalty_level_up"
    BUDGET_ALERT = "budget_alert"
    SAVINGS_TIP = "savings_tip"
    WEEKLY_SUMMARY = "weekly_summary"
    MONTHLY_SUMMARY = "monthly_summary"

class NotificationService:
    """
    Push notification servisi
    """
    def __init__(self):
        self.fcm_server_key = settings.FCM_SERVER_KEY if hasattr(settings, 'FCM_SERVER_KEY') else None
        self.fcm_url = "https://fcm.googleapis.com/fcm/send"
    
    async def send_notification(
        self,
        user_id: str,
        title: str,
        body: str,
        notification_type: NotificationType,
        data: Optional[Dict] = None
    ) -> bool:
        """
        Kullanıcıya push notification gönder
        """
        try:
            # Kullanıcının FCM token'ını al
            fcm_token = await self._get_user_fcm_token(user_id)
            if not fcm_token:
                logger.warning(f"No FCM token found for user {user_id}")
                return False
            
            # Bildirim payload'ını hazırla
            payload = {
                "to": fcm_token,
                "notification": {
                    "title": title,
                    "body": body,
                    "sound": "default",
                    "badge": 1
                },
                "data": {
                    "type": notification_type.value,
                    "user_id": user_id,
                    **(data or {})
                }
            }
            
            # FCM'e gönder
            if self.fcm_server_key:
                success, fcm_response = await self._send_to_fcm(payload)
                if success:
                    # Bildirimi veritabanına kaydet
                    await self._save_notification_log(user_id, title, body, notification_type, True, fcm_response=fcm_response)
                    return True
                else:
                    # Başarısız gönderim logunu kaydet
                    await self._save_notification_log(user_id, title, body, notification_type, False, fcm_response=fcm_response)
            else:
                logger.warning("FCM server key not configured")
            
            return False
            
        except Exception as e:
            logger.error(f"Error sending notification to user {user_id}: {e}")
            await self._save_notification_log(user_id, title, body, notification_type, False, str(e))
            return False
    
    async def send_bulk_notification(
        self,
        user_ids: List[str],
        title: str,
        body: str,
        notification_type: NotificationType,
        data: Optional[Dict] = None
    ) -> Dict[str, bool]:
        """
        Birden fazla kullanıcıya notification gönder
        """
        results = {}
        
        for user_id in user_ids:
            success = await self.send_notification(user_id, title, body, notification_type, data)
            results[user_id] = success
        
        return results
    
    async def send_receipt_notification(self, user_id: str, merchant_name: str, amount: float):
        """
        Fiş alındı bildirimi gönder
        """
        title = "Yeni Fiş Alındı!"
        body = f"{merchant_name} - {amount:.2f} TL"
        
        await self.send_notification(
            user_id=user_id,
            title=title,
            body=body,
            notification_type=NotificationType.RECEIPT_RECEIVED,
            data={"merchant_name": merchant_name, "amount": str(amount)}
        )
    
    async def send_loyalty_level_up_notification(self, user_id: str, new_level: str):
        """
        Loyalty seviye yükseltme bildirimi gönder
        """
        title = "Tebrikler! 🎉"
        body = f"Loyalty seviyeniz {new_level} oldu!"
        
        await self.send_notification(
            user_id=user_id,
            title=title,
            body=body,
            notification_type=NotificationType.LOYALTY_LEVEL_UP,
            data={"new_level": new_level}
        )
    
    async def send_budget_alert_notification(self, user_id: str, category: str, percentage: float):
        """
        Bütçe uyarısı bildirimi gönder
        """
        title = "Bütçe Uyarısı ⚠️"
        body = f"{category} kategorisinde bütçenizin %{percentage:.0f}'ini harcadınız"
        
        await self.send_notification(
            user_id=user_id,
            title=title,
            body=body,
            notification_type=NotificationType.BUDGET_ALERT,
            data={"category": category, "percentage": str(percentage)}
        )
    
    async def send_savings_tip_notification(self, user_id: str, tip: str):
        """
        Tasarruf önerisi bildirimi gönder
        """
        title = "Tasarruf İpucu 💡"
        body = tip
        
        await self.send_notification(
            user_id=user_id,
            title=title,
            body=body,
            notification_type=NotificationType.SAVINGS_TIP,
            data={"tip": tip}
        )
    
    async def send_weekly_summary_notification(self, user_id: str, total_spent: float, top_category: str):
        """
        Haftalık özet bildirimi gönder
        """
        title = "Haftalık Harcama Özeti 📊"
        body = f"Bu hafta {total_spent:.2f} TL harcadınız. En çok: {top_category}"
        
        await self.send_notification(
            user_id=user_id,
            title=title,
            body=body,
            notification_type=NotificationType.WEEKLY_SUMMARY,
            data={"total_spent": str(total_spent), "top_category": top_category}
        )
    
    async def _get_user_fcm_token(self, user_id: str) -> Optional[str]:
        """
        Kullanıcının FCM token'ını al
        """
        try:
            supabase = settings.supabase_admin  # Admin client kullan
            
            # user_devices tablosundan aktif token al
            result = supabase.table("user_devices").select("fcm_token").eq("user_id", user_id).eq("is_active", True).order("last_used_at", desc=True).limit(1).execute()
            
            if result.data:
                return result.data[0]["fcm_token"]
            
            return None
            
        except Exception as e:
            logger.error(f"Error getting FCM token for user {user_id}: {e}")
            return None
    
    async def _send_to_fcm(self, payload: Dict) -> tuple[bool, Optional[Dict]]:
        """
        FCM'e notification gönder
        """
        try:
            headers = {
                "Authorization": f"key={self.fcm_server_key}",
                "Content-Type": "application/json"
            }
            
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    self.fcm_url,
                    json=payload,
                    headers=headers,
                    timeout=30
                )
                
                fcm_response = None
                if response.status_code == 200:
                    fcm_response = response.json()
                    success = fcm_response.get("success", 0) > 0
                    return success, fcm_response
                else:
                    logger.error(f"FCM request failed: {response.status_code} - {response.text}")
                    fcm_response = {
                        "status_code": response.status_code,
                        "error": response.text
                    }
                    return False, fcm_response
                    
        except Exception as e:
            logger.error(f"Error sending to FCM: {e}")
            return False, {"error": str(e)}
    
    async def _save_notification_log(
        self,
        user_id: str,
        title: str,
        body: str,
        notification_type: NotificationType,
        success: bool,
        error_message: Optional[str] = None,
        fcm_response: Optional[Dict] = None
    ):
        """
        Notification logunu veritabanına kaydet
        """
        try:
            supabase = settings.supabase_admin
            
            # notification_logs tablosuna kaydet
            log_data = {
                "user_id": user_id,
                "title": title,
                "body": body,
                "notification_type": notification_type.value,
                "success": success,
                "error_message": error_message,
                "fcm_response": fcm_response
            }
            
            result = supabase.table("notification_logs").insert(log_data).execute()
            
            if result.data:
                logger.info(f"Notification log saved for user {user_id}")
            else:
                logger.warning(f"Failed to save notification log for user {user_id}")
            
        except Exception as e:
            logger.error(f"Error saving notification log: {e}")

# Global notification service instance
notification_service = NotificationService() 