import asyncio
import logging
from datetime import datetime, timedelta
from typing import Callable, Dict, List
from app.core.config import settings
try:
    from app.services.loyalty_service import LoyaltyService
except ImportError:
    LoyaltyService = None

try:
    from app.services.ai_service import AIService
except ImportError:
    AIService = None

logger = logging.getLogger(__name__)

class TaskScheduler:
    """
    Periyodik görevleri yöneten scheduler sınıfı
    """
    def __init__(self):
        self.tasks: Dict[str, Dict] = {}
        self.running = False
        self.loyalty_service = LoyaltyService() if LoyaltyService else None
        self.ai_service = AIService() if AIService else None
    
    def add_task(self, name: str, func: Callable, interval_minutes: int, run_immediately: bool = False):
        """
        Yeni bir periyodik görev ekle
        """
        self.tasks[name] = {
            'func': func,
            'interval': timedelta(minutes=interval_minutes),
            'last_run': datetime.now() - timedelta(minutes=interval_minutes) if run_immediately else datetime.now(),
            'next_run': datetime.now() if run_immediately else datetime.now() + timedelta(minutes=interval_minutes)
        }
        logger.info(f"Task '{name}' added with {interval_minutes} minute interval")
    
    async def start(self):
        """
        Scheduler'ı başlat
        """
        self.running = True
        logger.info("Task scheduler started")
        
        # Varsayılan görevleri ekle
        self._add_default_tasks()
        
        while self.running:
            try:
                await self._check_and_run_tasks()
                await asyncio.sleep(60)  # Her dakika kontrol et
            except Exception as e:
                logger.error(f"Scheduler error: {e}")
                await asyncio.sleep(60)
    
    async def stop(self):
        """
        Scheduler'ı durdur
        """
        self.running = False
        logger.info("Task scheduler stopped")
    
    async def _check_and_run_tasks(self):
        """
        Çalıştırılması gereken görevleri kontrol et ve çalıştır
        """
        current_time = datetime.now()
        
        for name, task in self.tasks.items():
            if current_time >= task['next_run']:
                try:
                    logger.info(f"Running scheduled task: {name}")
                    await task['func']()
                    
                    # Sonraki çalışma zamanını güncelle
                    task['last_run'] = current_time
                    task['next_run'] = current_time + task['interval']
                    
                    logger.info(f"Task '{name}' completed successfully")
                except Exception as e:
                    logger.error(f"Error running task '{name}': {e}")
    
    def _add_default_tasks(self):
        """
        Varsayılan periyodik görevleri ekle
        """
        # Loyalty seviye güncellemeleri (günlük)
        self.add_task(
            "update_loyalty_levels",
            self._update_loyalty_levels,
            interval_minutes=24 * 60  # 24 saat
        )
        
        # Eski webhook loglarını temizle (haftalık)
        self.add_task(
            "cleanup_webhook_logs",
            self._cleanup_webhook_logs,
            interval_minutes=7 * 24 * 60  # 7 gün
        )
        
        # AI önerilerini yenile (günlük)
        self.add_task(
            "refresh_ai_suggestions",
            self._refresh_ai_suggestions,
            interval_minutes=24 * 60  # 24 saat
        )
        
        # Sistem sağlık kontrolü (saatlik)
        self.add_task(
            "health_check",
            self._system_health_check,
            interval_minutes=60  # 1 saat
        )
    
    async def _update_loyalty_levels(self):
        """
        Tüm kullanıcıların loyalty seviyelerini güncelle
        """
        try:
            # Tüm kullanıcıları al ve seviyelerini güncelle
            supabase = settings.supabase_admin
            
            # Aktif kullanıcıları al
            users_response = supabase.table("users").select("id").execute()
            
            for user in users_response.data:
                user_id = user["id"]
                
                # Kullanıcının toplam harcamasını hesapla
                expenses_response = supabase.table("expenses").select("total_amount").eq("user_id", user_id).execute()
                
                total_spent = sum(expense["total_amount"] for expense in expenses_response.data)
                
                # Loyalty seviyesini güncelle
                await self.loyalty_service.update_user_level(user_id, total_spent)
            
            logger.info("Loyalty levels updated successfully")
        except Exception as e:
            logger.error(f"Error updating loyalty levels: {e}")
    
    async def _cleanup_webhook_logs(self):
        """
        30 günden eski webhook loglarını temizle
        """
        try:
            supabase = settings.supabase_admin
            cutoff_date = datetime.now() - timedelta(days=30)
            
            # Eski logları sil
            result = supabase.table("webhook_logs").delete().lt("created_at", cutoff_date.isoformat()).execute()
            
            deleted_count = len(result.data) if result.data else 0
            logger.info(f"Cleaned up {deleted_count} old webhook logs")
        except Exception as e:
            logger.error(f"Error cleaning up webhook logs: {e}")
    
    async def _refresh_ai_suggestions(self):
        """
        Aktif kullanıcılar için AI önerilerini yenile
        """
        try:
            supabase = settings.supabase_admin
            
            # Son 7 gün içinde aktif olan kullanıcıları al
            cutoff_date = datetime.now() - timedelta(days=7)
            
            active_users = supabase.table("expenses").select("user_id").gte("created_at", cutoff_date.isoformat()).execute()
            
            unique_users = list(set(user["user_id"] for user in active_users.data))
            
            for user_id in unique_users:
                try:
                    # Kullanıcı için yeni öneriler oluştur
                    await self.ai_service.generate_savings_suggestions(user_id)
                    await self.ai_service.generate_budget_suggestions(user_id)
                except Exception as e:
                    logger.error(f"Error generating suggestions for user {user_id}: {e}")
            
            logger.info(f"AI suggestions refreshed for {len(unique_users)} users")
        except Exception as e:
            logger.error(f"Error refreshing AI suggestions: {e}")
    
    async def _system_health_check(self):
        """
        Sistem sağlık kontrolü
        """
        try:
            # Supabase bağlantısını kontrol et
            supabase = settings.supabase
            health_check = supabase.table("users").select("id").limit(1).execute()
            
            if not health_check:
                logger.warning("Supabase connection issue detected")
                return
            
            # Ollama bağlantısını kontrol et (eğer aktifse)
            if settings.OLLAMA_ENABLED:
                try:
                    await self.ai_service.test_connection()
                except Exception as e:
                    logger.warning(f"Ollama connection issue: {e}")
            
            logger.info("System health check completed successfully")
        except Exception as e:
            logger.error(f"System health check failed: {e}")

# Global scheduler instance
scheduler = TaskScheduler() 