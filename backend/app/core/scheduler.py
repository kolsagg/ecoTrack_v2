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
    from app.services.cleanup_service import cleanup_service
except ImportError:
    cleanup_service = None

try:
    from app.services.global_inflation_service import GlobalInflationService
except ImportError:
    GlobalInflationService = None

logger = logging.getLogger(__name__)

class TaskScheduler:
    """
    Periyodik görevleri yöneten scheduler sınıfı
    """
    def __init__(self):
        self.tasks: Dict[str, Dict] = {}
        self.running = False
        self.loyalty_service = LoyaltyService() if LoyaltyService else None
        self.inflation_service = GlobalInflationService() if GlobalInflationService else None
    
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
        
        # Expired public receipt'leri temizle (günlük)
        self.add_task(
            "cleanup_expired_public_receipts",
            self._cleanup_expired_public_receipts,
            interval_minutes=24 * 60  # 24 saat
        )
        
        # Sistem sağlık kontrolü (saatlik)
        self.add_task(
            "health_check",
            self._system_health_check,
            interval_minutes=60  # 1 saat
        )
        
        # Aylık enflasyon hesaplama (haftalık - Pazar gecesi 3:00)
        self.add_task(
            "calculate_monthly_inflation",
            self._calculate_monthly_inflation,
            interval_minutes=7 * 24 * 60,  # 7 gün
            run_immediately=False
        )
    
    async def _update_loyalty_levels(self):
        """
        Tüm kullanıcıların loyalty seviyelerini güncelle
        """
        try:
            logger.info("Loyalty levels update task started")
            
            # TODO: Implement loyalty level update logic if needed
            # Currently loyalty levels are automatically calculated 
            # when points are awarded, so this may not be necessary
            
            logger.info("Loyalty levels update completed")
        except Exception as e:
            logger.error(f"Error updating loyalty levels: {e}")
    
    async def _cleanup_webhook_logs(self):
        """
        30 günden eski webhook loglarını temizle
        """
        try:
            if cleanup_service:
                result = await cleanup_service.cleanup_old_webhook_logs(days_to_keep=30)
                if result["success"]:
                    logger.info(f"Webhook logs cleanup: {result['webhook_logs_cleaned']} logs cleaned")
                else:
                    logger.error(f"Webhook logs cleanup failed: {result.get('error')}")
            else:
                # Fallback to old method if cleanup_service not available
                supabase = settings.supabase_admin
                cutoff_date = datetime.now() - timedelta(days=30)
                
                # Eski logları sil
                result = supabase.table("webhook_logs").delete().lt("created_at", cutoff_date.isoformat()).execute()
                
                deleted_count = len(result.data) if result.data else 0
                logger.info(f"Cleaned up {deleted_count} old webhook logs")
        except Exception as e:
            logger.error(f"Error cleaning up webhook logs: {e}")
    
    async def _cleanup_expired_public_receipts(self):
        """
        Süresi dolmuş public receipt'leri ve ilişkili verileri temizle
        """
        try:
            if cleanup_service:
                result = await cleanup_service.cleanup_expired_public_receipts()
                
                if result["success"]:
                    logger.info(f"Expired public receipts cleanup: {result['receipts_cleaned']} receipts, "
                               f"{result['expenses_cleaned']} expenses, {result['expense_items_cleaned']} items cleaned")
                else:
                    logger.error(f"Expired public receipts cleanup failed: {result.get('error')}")
            else:
                logger.warning("CleanupService not available, skipping expired public receipts cleanup")
                
        except Exception as e:
            logger.error(f"Error running expired public receipts cleanup: {e}")

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
            
            logger.info("System health check completed successfully")
        except Exception as e:
            logger.error(f"System health check failed: {e}")

    async def _calculate_monthly_inflation(self):
        """
        Aylık ürün enflasyonunu hesapla ve veritabanına kaydet (aydan aya değişim)
        """
        try:
            logger.info("Monthly inflation calculation task started")
            
            if self.inflation_service:
                await self.inflation_service.calculate_and_store_monthly_inflation()
                logger.info("Monthly inflation calculation completed successfully")
            else:
                logger.warning("GlobalInflationService not available, skipping monthly inflation calculation")
                
        except Exception as e:
            logger.error(f"Error calculating monthly inflation: {e}")

# Global scheduler instance
scheduler = TaskScheduler() 