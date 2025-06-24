import logging
import asyncio
from datetime import datetime, timedelta
from typing import List, Dict, Any
from supabase import Client
from app.core.config import settings

logger = logging.getLogger(__name__)

class CleanupService:
    """
    Expired public receipt'leri ve orphan data'ları temizleyen servis
    """
    
    def __init__(self):
        self.supabase = settings.supabase_admin
    
    async def cleanup_expired_public_receipts(self) -> Dict[str, Any]:
        """
        Süresi dolmuş public receipt'leri ve ilişkili expense/expense_items'ları temizle
        
        Returns:
            Cleanup sonuçları
        """
        try:
            logger.info("Starting expired public receipts cleanup")
            
            # Süresi dolmuş public receipt'leri bul
            current_time = datetime.now().isoformat()
            
            expired_receipts_response = self.supabase.table("receipts").select(
                "id, merchant_name, total_amount, expires_at"
            ).eq("is_public", True).lt("expires_at", current_time).execute()
            
            if not expired_receipts_response.data:
                logger.info("No expired public receipts found")
                return {
                    "success": True,
                    "receipts_cleaned": 0,
                    "expenses_cleaned": 0,
                    "expense_items_cleaned": 0
                }
            
            expired_receipts = expired_receipts_response.data
            logger.info(f"Found {len(expired_receipts)} expired public receipts")
            
            receipts_cleaned = 0
            expenses_cleaned = 0
            expense_items_cleaned = 0
            
            # Her expired receipt için cleanup yap
            for receipt in expired_receipts:
                receipt_id = receipt["id"]
                
                try:
                    # İlişkili expense'ları bul
                    expenses_response = self.supabase.table("expenses").select(
                        "id"
                    ).eq("receipt_id", receipt_id).is_("user_id", "null").execute()
                    
                    # Expense items'ları temizle
                    for expense in expenses_response.data:
                        expense_id = expense["id"]
                        
                        # Expense items'ları sil
                        expense_items_result = self.supabase.table("expense_items").delete().eq(
                            "expense_id", expense_id
                        ).is_("user_id", "null").execute()
                        
                        if expense_items_result.data:
                            expense_items_cleaned += len(expense_items_result.data)
                    
                    # Expense'ları sil
                    expenses_result = self.supabase.table("expenses").delete().eq(
                        "receipt_id", receipt_id
                    ).is_("user_id", "null").execute()
                    
                    if expenses_result.data:
                        expenses_cleaned += len(expenses_result.data)
                    
                    # Receipt'i sil
                    receipt_result = self.supabase.table("receipts").delete().eq(
                        "id", receipt_id
                    ).eq("is_public", True).execute()
                    
                    if receipt_result.data:
                        receipts_cleaned += 1
                        logger.info(f"Cleaned expired public receipt: {receipt_id} ({receipt['merchant_name']})")
                
                except Exception as e:
                    logger.error(f"Error cleaning receipt {receipt_id}: {str(e)}")
                    continue
            
            result = {
                "success": True,
                "receipts_cleaned": receipts_cleaned,
                "expenses_cleaned": expenses_cleaned,
                "expense_items_cleaned": expense_items_cleaned
            }
            
            logger.info(f"Expired public receipts cleanup completed: {result}")
            return result
            
        except Exception as e:
            logger.error(f"Error during expired public receipts cleanup: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "receipts_cleaned": 0,
                "expenses_cleaned": 0,
                "expense_items_cleaned": 0
            }
    
    async def cleanup_orphan_expenses(self) -> Dict[str, Any]:
        """
        Receipt'i olmayan orphan expense'ları temizle
        """
        try:
            logger.info("Starting orphan expenses cleanup")
            
            # Receipt'i olmayan expense'ları bul
            orphan_expenses_response = self.supabase.table("expenses").select(
                "id, receipt_id"
            ).is_("user_id", "null").execute()
            
            orphan_count = 0
            
            for expense in orphan_expenses_response.data:
                expense_id = expense["id"]
                receipt_id = expense["receipt_id"]
                
                # Receipt'in hala var olup olmadığını kontrol et
                receipt_check = self.supabase.table("receipts").select("id").eq(
                    "id", receipt_id
                ).execute()
                
                if not receipt_check.data:
                    # Receipt yok, expense'ı ve items'ları temizle
                    self.supabase.table("expense_items").delete().eq("expense_id", expense_id).execute()
                    self.supabase.table("expenses").delete().eq("id", expense_id).execute()
                    orphan_count += 1
            
            logger.info(f"Cleaned {orphan_count} orphan expenses")
            return {"success": True, "orphan_expenses_cleaned": orphan_count}
            
        except Exception as e:
            logger.error(f"Error during orphan expenses cleanup: {str(e)}")
            return {"success": False, "error": str(e)}

    async def cleanup_old_webhook_logs(self, days_to_keep: int = 30) -> Dict[str, Any]:
        """
        Eski webhook loglarını temizle
        """
        try:
            logger.info(f"Starting webhook logs cleanup (keeping last {days_to_keep} days)")
            
            cutoff_date = (datetime.now() - timedelta(days=days_to_keep)).isoformat()
            
            result = self.supabase.table("webhook_logs").delete().lt("created_at", cutoff_date).execute()
            
            deleted_count = len(result.data) if result.data else 0
            logger.info(f"Cleaned up {deleted_count} old webhook logs")
            
            return {"success": True, "webhook_logs_cleaned": deleted_count}
            
        except Exception as e:
            logger.error(f"Error during webhook logs cleanup: {str(e)}")
            return {"success": False, "error": str(e)}

# Global cleanup service instance
cleanup_service = CleanupService() 