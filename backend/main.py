from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import uvicorn
import asyncio
import uuid
import os

from app.core.config import settings
from app.core.logging_config import setup_logging, log_request, log_response, get_logger
from app.core.security import (
    SecurityHeadersMiddleware, 
    HTTPSRedirectMiddleware, 
    RateLimitMiddleware, 
    RequestLoggingMiddleware
)
from app.core.scheduler import scheduler
from app.api.v1.api import api_router
from app.api.v1.health import router as health_router

# Logging'i başlat
setup_logging()
logger = get_logger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Uygulama yaşam döngüsü yönetimi
    """
    # Startup banner
    print("\n" + "="*60)
    print("🌱 EcoTrack Backend API")
    print("="*60)
    print(f"🔧 Version: {settings.VERSION}")
    print(f"📊 Environment: {settings.ENVIRONMENT.upper()}")
    print(f"🌐 Debug Mode: {'ON' if settings.DEBUG else 'OFF'}")
    print(f"🔒 HTTPS Enforced: {'YES' if settings.FORCE_HTTPS else 'NO'}")

    print(f"⏰ Scheduler: {'ENABLED' if settings.SCHEDULER_ENABLED else 'DISABLED'}")
    
    # AI Categorizer durumunu kontrol et
    try:
        from app.services.ai_categorizer import ai_categorizer
        ai_status = "ENABLED" if ai_categorizer._model_available else "RULE-BASED ONLY"
    except:
        ai_status = "DISABLED"
    print(f"🤖 AI Categorizer: {ai_status}")
    
    print("="*60 + "\n")
    
    logger.info("🚀 Starting EcoTrack API...")
    
    # Scheduler'ı başlat (eğer aktifse)
    if settings.SCHEDULER_ENABLED:
        scheduler_task = asyncio.create_task(scheduler.start())
        logger.info("⏰ Scheduler started")
    
    logger.info("✅ EcoTrack API started successfully")
    
    yield
    
    # Shutdown
    logger.info("Shutting down EcoTrack API...")
    
    if settings.SCHEDULER_ENABLED:
        await scheduler.stop()
        logger.info("Scheduler stopped")
    
    logger.info("EcoTrack API shutdown complete")

# Initialize FastAPI app
app = FastAPI(
    title=settings.PROJECT_NAME,
    description="QR-Based Digital Expense Tracking Application API",
    version=settings.VERSION,
    lifespan=lifespan
)

# Security configurations
security = HTTPBearer()

# HTTPS Redirect Middleware (production için)
if settings.FORCE_HTTPS:
    app.add_middleware(HTTPSRedirectMiddleware, force_https=True)

# Security Headers Middleware
app.add_middleware(SecurityHeadersMiddleware)

# Rate Limiting Middleware
app.add_middleware(
    RateLimitMiddleware, 
    calls=settings.RATE_LIMIT_CALLS, 
    period=settings.RATE_LIMIT_PERIOD
)

# Request Logging Middleware
app.add_middleware(RequestLoggingMiddleware)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["X-Process-Time"]
)

# Request ID middleware
@app.middleware("http")
async def add_request_id(request, call_next):
    """
    Her isteğe benzersiz ID ekle
    """
    request_id = str(uuid.uuid4())
    request.state.request_id = request_id
    
    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id
    
    return response

# Auth dependency
async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    JWT token doğrulama ve kullanıcı bilgilerini alma
    """
    try:
        # Verify JWT token with Supabase
        user = settings.supabase.auth.get_user(credentials.credentials)
        return user
    except Exception as e:
        logger.warning(f"Authentication failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

# Include health check router (public endpoints)
app.include_router(health_router, tags=["Health Check"])

# Include API router
app.include_router(api_router, prefix=settings.API_V1_STR)

# Mount static files for templates (CSS, JS, images)
static_path = os.path.join(os.path.dirname(__file__), "app", "static")
if os.path.exists(static_path):
    app.mount("/static", StaticFiles(directory=static_path), name="static")

@app.get("/")
async def root():
    """
    Ana endpoint - API bilgileri
    """
    return {
        "message": "Welcome to EcoTrack API",
        "version": settings.VERSION,
        "environment": settings.ENVIRONMENT,
        "docs_url": "/docs",
        "health_check": "/health"
    }

@app.get("/protected")
async def protected_route(user = Depends(get_current_user)):
    """
    Korumalı test endpoint'i
    """
    return {
        "message": "This is a protected route", 
        "user": user.dict() if hasattr(user, 'dict') else str(user)
    }

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """
    Global hata yakalayıcı
    """
    from app.core.logging_config import log_error
    
    request_id = getattr(request.state, 'request_id', 'unknown')
    
    log_error(exc, {
        "request_id": request_id,
        "path": request.url.path,
        "method": request.method,
        "client_ip": request.client.host if request.client else "unknown"
    })
    
    # Production'da detaylı hata mesajlarını gizle
    if settings.ENVIRONMENT == "production":
        return HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )
    else:
        return HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Internal server error: {str(exc)}"
        )

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_config=None  # Kendi logging config'imizi kullan
    ) 