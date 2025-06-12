from fastapi import Request, HTTPException, status
from fastapi.responses import Response
from starlette.middleware.base import BaseHTTPMiddleware
import logging
from typing import Callable
import time

logger = logging.getLogger(__name__)

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """
    Güvenlik başlıklarını ekleyen middleware
    """
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        response = await call_next(request)
        
        # Güvenlik başlıklarını ekle
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
        
        # HTTPS zorlaması (production ortamında)
        if request.headers.get("x-forwarded-proto") == "http":
            response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains; preload"
        
        return response

class HTTPSRedirectMiddleware(BaseHTTPMiddleware):
    """
    HTTP isteklerini HTTPS'e yönlendiren middleware
    """
    def __init__(self, app, force_https: bool = False):
        super().__init__(app)
        self.force_https = force_https
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Production ortamında HTTPS zorlaması
        if self.force_https and request.url.scheme == "http":
            # Health check endpoint'lerini hariç tut
            if not request.url.path.startswith("/health"):
                https_url = request.url.replace(scheme="https")
                return Response(
                    status_code=status.HTTP_301_MOVED_PERMANENTLY,
                    headers={"Location": str(https_url)}
                )
        
        return await call_next(request)

class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Basit rate limiting middleware
    """
    def __init__(self, app, calls: int = 100, period: int = 60):
        super().__init__(app)
        self.calls = calls
        self.period = period
        self.clients = {}
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        client_ip = request.client.host
        current_time = time.time()
        
        # Eski kayıtları temizle
        self.clients = {
            ip: times for ip, times in self.clients.items()
            if any(t > current_time - self.period for t in times)
        }
        
        # İstemci için kayıtları kontrol et
        if client_ip not in self.clients:
            self.clients[client_ip] = []
        
        # Son period içindeki istekleri filtrele
        self.clients[client_ip] = [
            t for t in self.clients[client_ip]
            if t > current_time - self.period
        ]
        
        # Rate limit kontrolü
        if len(self.clients[client_ip]) >= self.calls:
            logger.warning(f"Rate limit exceeded for IP: {client_ip}")
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded"
            )
        
        # Yeni isteği kaydet
        self.clients[client_ip].append(current_time)
        
        return await call_next(request)

class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """
    İstek loglama middleware
    """
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        start_time = time.time()
        
        # İstek bilgilerini logla (health check'leri hariç)
        if not request.url.path.startswith("/health"):
            logger.info(
                f"Request: {request.method} {request.url.path} "
                f"from {request.client.host if request.client else 'unknown'}"
            )
        
        response = await call_next(request)
        
        # Yanıt süresini hesapla ve logla
        process_time = time.time() - start_time
        
        # Sadece önemli endpoint'leri logla
        if not request.url.path.startswith("/health") or response.status_code >= 400:
            status_emoji = "✅" if response.status_code < 400 else "❌" if response.status_code >= 500 else "⚠️"
            logger.info(
                f"Response: {response.status_code} "
                f"in {process_time:.3f}s {status_emoji}"
            )
        
        # Yanıt başlığına süreyi ekle
        response.headers["X-Process-Time"] = str(process_time)
        
        return response

def validate_api_key(api_key: str) -> bool:
    """
    API anahtarı doğrulama fonksiyonu
    """
    if not api_key:
        return False
    
    # API anahtarı formatını kontrol et
    if not api_key.startswith("mk_"):
        return False
    
    if len(api_key) < 35:  # mk_ + 32 karakter
        return False
    
    return True

def sanitize_input(data: str) -> str:
    """
    Kullanıcı girdilerini temizleme fonksiyonu
    """
    if not data:
        return ""
    
    # Tehlikeli karakterleri temizle
    dangerous_chars = ["<", ">", "&", "\"", "'", "/", "\\"]
    for char in dangerous_chars:
        data = data.replace(char, "")
    
    # Fazla boşlukları temizle
    data = " ".join(data.split())
    
    return data.strip() 