from fastapi import APIRouter, HTTPException, status, Depends
from typing import Dict, Any
import time
from datetime import datetime, timedelta
from app.core.config import settings
from app.core.auth import get_current_user

router = APIRouter()

@router.get("/health")
async def health_check() -> Dict[str, Any]:
    """
    Basic system health check
    """
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT
    }

@router.get("/health/detailed")
async def detailed_health_check() -> Dict[str, Any]:
    """
    Detailed system health check
    """
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "checks": {}
    }
    
    overall_healthy = True
    
    # Supabase bağlantı kontrolü
    try:
        start_time = time.time()
        supabase = settings.supabase
        result = supabase.table("users").select("id").limit(1).execute()
        response_time = time.time() - start_time
        
        health_status["checks"]["supabase"] = {
            "status": "healthy",
            "response_time_ms": round(response_time * 1000, 2),
            "message": "Connection successful"
        }
    except Exception as e:
        overall_healthy = False
        health_status["checks"]["supabase"] = {
            "status": "unhealthy",
            "error": str(e),
            "message": "Connection failed"
        }
    
    # Genel durum
    if not overall_healthy:
        health_status["status"] = "unhealthy"
    elif any(check.get("status") == "degraded" for check in health_status["checks"].values()):
        health_status["status"] = "degraded"
    
    return health_status

@router.get("/health/database")
async def database_health_check() -> Dict[str, Any]:
    """
    Database health check
    """
    try:
        start_time = time.time()
        supabase = settings.supabase
        
        # Temel bağlantı testi
        connection_test = supabase.table("users").select("id").limit(1).execute()
        connection_time = time.time() - start_time
        
        # Tablo sayıları
        start_time = time.time()
        tables_info = {}
        
        table_names = ["users", "categories", "receipts", "expenses", "merchants"]
        for table in table_names:
            try:
                count_result = supabase.table(table).select("id", count="exact").execute()  # type: ignore
                tables_info[table] = count_result.count if hasattr(count_result, 'count') else 0
            except Exception as e:
                tables_info[table] = f"Error: {str(e)}"
        
        query_time = time.time() - start_time
        
        return {
            "status": "healthy",
            "connection_time_ms": round(connection_time * 1000, 2),
            "query_time_ms": round(query_time * 1000, 2),
            "tables": tables_info,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database health check failed: {str(e)}"
        )

@router.get("/health/metrics")
async def system_metrics(current_user = Depends(get_current_user)) -> Dict[str, Any]:
    """
    System metrics (for authorized users)
    """
    try:
        supabase = settings.supabase_admin
        
        # Kullanıcı istatistikleri
        users_count = supabase.table("users").select("id", count="exact").execute()  # type: ignore
        
        # Harcama istatistikleri
        expenses_count = supabase.table("expenses").select("id", count="exact").execute()  # type: ignore
        
        # Fiş istatistikleri
        receipts_count = supabase.table("receipts").select("id", count="exact").execute()  # type: ignore
        
        # Merchant istatistikleri
        merchants_count = supabase.table("merchants").select("id", count="exact").execute()  # type: ignore
        
        # Son 24 saat içindeki aktivite
        yesterday = datetime.utcnow() - timedelta(days=1)
        recent_expenses = supabase.table("expenses").select("id", count="exact").gte("created_at", yesterday.isoformat()).execute()  # type: ignore
        recent_receipts = supabase.table("receipts").select("id", count="exact").gte("created_at", yesterday.isoformat()).execute()  # type: ignore
        
        return {
            "timestamp": datetime.utcnow().isoformat(),
            "totals": {
                "users": users_count.count if hasattr(users_count, 'count') else 0,
                "expenses": expenses_count.count if hasattr(expenses_count, 'count') else 0,
                "receipts": receipts_count.count if hasattr(receipts_count, 'count') else 0,
                "merchants": merchants_count.count if hasattr(merchants_count, 'count') else 0
            },
            "last_24h": {
                "new_expenses": recent_expenses.count if hasattr(recent_expenses, 'count') else 0,
                "new_receipts": recent_receipts.count if hasattr(recent_receipts, 'count') else 0
            },
            "system": {
                "environment": settings.ENVIRONMENT,
                "version": settings.VERSION
            }
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retrieve system metrics: {str(e)}"
        )

@router.get("/health/ready")
async def readiness_check() -> Dict[str, str]:
    """
    Kubernetes readiness probe
    """
    try:
        # Temel veritabanı bağlantısını kontrol et
        supabase = settings.supabase
        supabase.table("users").select("id").limit(1).execute()
        
        return {"status": "ready"}
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Service not ready"
        )

@router.get("/health/live")
async def liveness_check() -> Dict[str, str]:
    """
    Kubernetes liveness probe
    """
    return {"status": "alive"} 