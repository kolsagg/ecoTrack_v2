import logging
import logging.handlers
import os
import sys
import threading
from datetime import datetime
from typing import Dict, Any
import json
from app.core.config import settings

# ANSI renk kodları
class Colors:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    DIM = '\033[2m'
    
    # Renkler
    BLACK = '\033[30m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    YELLOW = '\033[33m'
    BLUE = '\033[34m'
    MAGENTA = '\033[35m'
    CYAN = '\033[36m'
    WHITE = '\033[37m'
    
    # Parlak renkler
    BRIGHT_RED = '\033[91m'
    BRIGHT_GREEN = '\033[92m'
    BRIGHT_YELLOW = '\033[93m'
    BRIGHT_BLUE = '\033[94m'
    BRIGHT_MAGENTA = '\033[95m'
    BRIGHT_CYAN = '\033[96m'

class JSONFormatter(logging.Formatter):
    """
    JSON formatında log çıktısı veren formatter
    """
    def format(self, record: logging.LogRecord) -> str:
        log_entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        
        # Exception bilgilerini ekle
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        
        # Extra alanları ekle
        if hasattr(record, 'user_id'):
            log_entry["user_id"] = record.user_id
        
        if hasattr(record, 'request_id'):
            log_entry["request_id"] = record.request_id
        
        if hasattr(record, 'ip_address'):
            log_entry["ip_address"] = record.ip_address
        
        return json.dumps(log_entry, ensure_ascii=False)

class ColoredFormatter(logging.Formatter):
    """
    Gelişmiş renkli ve düzenli terminal çıktısı için formatter
    """
    
    # Log seviyesi renkleri ve ikonları
    LEVEL_STYLES = {
        'DEBUG': {'color': Colors.DIM + Colors.WHITE, 'icon': '🔍', 'badge': ' DBG '},
        'INFO': {'color': Colors.BRIGHT_GREEN, 'icon': '📝', 'badge': ' INF '},
        'WARNING': {'color': Colors.BRIGHT_YELLOW, 'icon': '⚠️ ', 'badge': ' WRN '},
        'ERROR': {'color': Colors.BRIGHT_RED, 'icon': '❌', 'badge': ' ERR '},
        'CRITICAL': {'color': Colors.BOLD + Colors.BRIGHT_RED, 'icon': '💥', 'badge': ' CRT '}
    }
    
    # Modül renkleri ve ikonları
    MODULE_STYLES = {
        'uvicorn': {'color': Colors.BRIGHT_BLUE, 'icon': '🚀'},
        'fastapi': {'color': Colors.BRIGHT_GREEN, 'icon': '⚡'},
        'main': {'color': Colors.BRIGHT_MAGENTA, 'icon': '🎯'},
        'request': {'color': Colors.CYAN, 'icon': '📥'},
        'response': {'color': Colors.GREEN, 'icon': '📤'},
        'security': {'color': Colors.YELLOW, 'icon': '🔒'},
        'business': {'color': Colors.MAGENTA, 'icon': '💼'},
        'scheduler': {'color': Colors.BRIGHT_MAGENTA, 'icon': '⏰'},
        'ai_service': {'color': Colors.BLUE, 'icon': '🤖'},
        'health': {'color': Colors.BRIGHT_CYAN, 'icon': '💚'},
        'auth': {'color': Colors.YELLOW, 'icon': '🔐'},
        'database': {'color': Colors.BRIGHT_BLUE, 'icon': '🗄️ '},
        'webhook': {'color': Colors.MAGENTA, 'icon': '🔗'},
        'loyalty': {'color': Colors.BRIGHT_YELLOW, 'icon': '🏆'},
        'merchant': {'color': Colors.CYAN, 'icon': '🏪'},
        'expense': {'color': Colors.GREEN, 'icon': '💰'},
        'receipt': {'color': Colors.BLUE, 'icon': '🧾'},
        'category': {'color': Colors.MAGENTA, 'icon': '📂'}
    }
    
    # HTTP status code renkleri ve açıklamaları
    STATUS_INFO = {
        200: {'color': Colors.BRIGHT_GREEN, 'text': 'OK'},
        201: {'color': Colors.BRIGHT_GREEN, 'text': 'Created'},
        204: {'color': Colors.BRIGHT_GREEN, 'text': 'No Content'},
        400: {'color': Colors.BRIGHT_YELLOW, 'text': 'Bad Request'},
        401: {'color': Colors.BRIGHT_RED, 'text': 'Unauthorized'},
        403: {'color': Colors.BRIGHT_RED, 'text': 'Forbidden'},
        404: {'color': Colors.YELLOW, 'text': 'Not Found'},
        405: {'color': Colors.YELLOW, 'text': 'Method Not Allowed'},
        422: {'color': Colors.BRIGHT_YELLOW, 'text': 'Validation Error'},
        429: {'color': Colors.BRIGHT_RED, 'text': 'Rate Limited'},
        500: {'color': Colors.BOLD + Colors.BRIGHT_RED, 'text': 'Server Error'},
        502: {'color': Colors.BOLD + Colors.BRIGHT_RED, 'text': 'Bad Gateway'},
        503: {'color': Colors.BOLD + Colors.BRIGHT_RED, 'text': 'Service Unavailable'}
    }
    
    def format(self, record):
        # Zaman damgası (milisaniye ile)
        dt = datetime.fromtimestamp(record.created)
        timestamp = dt.strftime('%H:%M:%S') + f".{int(record.msecs):03d}"
        
        # Log seviyesi stili
        level_style = self.LEVEL_STYLES.get(record.levelname, self.LEVEL_STYLES['INFO'])
        level_badge = f"{level_style['color']}{level_style['badge']}{Colors.RESET}"
        
        # Modül adı ve ikonu
        module_name = self._get_clean_module_name(record.name)
        module_style = self.MODULE_STYLES.get(module_name, {'color': Colors.WHITE, 'icon': '📄'})
        module_icon = module_style['icon']
        module_colored = f"{module_style['color']}{module_name:12}{Colors.RESET}"
        
        # Mesaj işleme
        message = record.getMessage()
        formatted_message = self._format_message(message, record)
        
        # Thread ID (eğer varsa)
        thread_info = ""
        if hasattr(record, 'thread') and record.thread != threading.main_thread().ident:
            thread_info = f"{Colors.DIM}[T{record.thread}]{Colors.RESET} "
        
        # Request ID (eğer varsa)
        request_info = ""
        if hasattr(record, 'request_id'):
            request_info = f"{Colors.DIM}[{record.request_id[:8]}]{Colors.RESET} "
        
        # Final format - daha kompakt ve okunabilir
        return (f"{Colors.DIM}{timestamp}{Colors.RESET} "
                f"{level_badge} "
                f"{module_icon} {module_colored} "
                f"{thread_info}{request_info}"
                f"{formatted_message}")
    
    def _get_clean_module_name(self, logger_name: str) -> str:
        """Logger adından temiz modül adı çıkar"""
        parts = logger_name.split('.')
        
        # Özel durumlar
        if 'uvicorn' in logger_name:
            return 'uvicorn'
        elif 'fastapi' in logger_name:
            return 'fastapi'
        elif len(parts) >= 3 and parts[0] == 'app':
            # app.api.v1.health -> health
            return parts[-1]
        else:
            return parts[-1] if parts else logger_name
    
    def _format_message(self, message: str, record) -> str:
        """Mesajı özel formatlarla düzenle"""
        
        # HTTP istekleri
        if "Request:" in message:
            parts = message.replace("Request:", "").strip().split()
            if len(parts) >= 4:
                method, path, _, ip = parts[0], parts[1], parts[2], parts[3]
                return f"{Colors.BRIGHT_CYAN}→{Colors.RESET} {Colors.BOLD}{method}{Colors.RESET} {path} {Colors.DIM}from {ip}{Colors.RESET}"
        
        # HTTP yanıtları
        elif "Response:" in message:
            parts = message.replace("Response:", "").strip().split()
            if len(parts) >= 4:
                status_code = int(parts[0])
                time_info = " ".join(parts[2:])
                
                # Status code bilgilerini al
                status_info = self.STATUS_INFO.get(status_code, {
                    'color': Colors.WHITE, 
                    'text': 'Unknown'
                })
                
                status_colored = f"{status_info['color']}{status_code} {status_info['text']}{Colors.RESET}"
                return f"{Colors.BRIGHT_GREEN}←{Colors.RESET} {status_colored} {Colors.DIM}{time_info}{Colors.RESET}"
        
        # Başlangıç mesajları
        elif any(word in message.lower() for word in ["starting", "started", "✓"]):
            return f"{Colors.BRIGHT_GREEN}✓{Colors.RESET} {message}"
        
        # Bitiş mesajları
        elif any(word in message.lower() for word in ["stopping", "stopped", "shutdown"]):
            return f"{Colors.BRIGHT_RED}✗{Colors.RESET} {message}"
        
        # Hata mesajları
        elif any(word in message.lower() for word in ["error", "failed", "exception"]):
            return f"{Colors.BRIGHT_RED}✗{Colors.RESET} {message}"
        
        # Başarı mesajları
        elif any(word in message.lower() for word in ["completed", "success", "successful"]):
            return f"{Colors.BRIGHT_GREEN}✓{Colors.RESET} {message}"
        
        # Uyarı mesajları
        elif any(word in message.lower() for word in ["warning", "deprecated", "rate limit"]):
            return f"{Colors.BRIGHT_YELLOW}⚠{Colors.RESET} {message}"
        
        # Database işlemleri
        elif any(word in message.lower() for word in ["query", "database", "sql"]):
            return f"{Colors.BRIGHT_BLUE}🗄️{Colors.RESET} {message}"
        
        # API endpoint'leri
        elif any(word in message.lower() for word in ["endpoint", "route", "api"]):
            return f"{Colors.BRIGHT_CYAN}🔗{Colors.RESET} {message}"
        
        # Varsayılan
        return message

class SecurityFilter(logging.Filter):
    """
    Güvenlik açısından hassas bilgileri filtreleyen filter
    """
    SENSITIVE_FIELDS = [
        'password', 'token', 'key', 'secret', 'authorization',
        'jwt', 'api_key', 'card_number', 'cvv', 'ssn'
    ]
    
    def filter(self, record: logging.LogRecord) -> bool:
        # Log mesajında hassas bilgi var mı kontrol et
        message = record.getMessage().lower()
        
        for field in self.SENSITIVE_FIELDS:
            if field in message:
                # Hassas bilgiyi maskele
                record.msg = self._mask_sensitive_data(record.msg)
                break
        
        return True
    
    def _mask_sensitive_data(self, message: str) -> str:
        """
        Hassas verileri maskele
        """
        # Basit maskeleme - gerçek uygulamada daha sofistike olabilir
        for field in self.SENSITIVE_FIELDS:
            if field in message.lower():
                # Field'dan sonraki değeri maskele
                import re
                pattern = f'({field}["\']?\\s*[:=]\\s*["\']?)([^"\'\\s,}}]+)'
                message = re.sub(pattern, r'\1***MASKED***', message, flags=re.IGNORECASE)
        
        return message

def setup_logging():
    """
    Logging yapılandırmasını ayarla
    """
    # Root logger'ı yapılandır
    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, settings.LOG_LEVEL.upper()))
    
    # Mevcut handler'ları temizle
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    
    if settings.ENVIRONMENT == "production":
        # Production'da JSON formatter kullan
        console_formatter = JSONFormatter()
    else:
        # Development'da daha okunabilir ve renkli format
        console_formatter = ColoredFormatter()
    
    console_handler.setFormatter(console_formatter)
    console_handler.addFilter(SecurityFilter())
    root_logger.addHandler(console_handler)
    
    # File handler (rotating)
    if settings.LOG_FILE:
        # Logs dizinini oluştur
        log_dir = os.path.dirname(settings.LOG_FILE) or "logs"
        os.makedirs(log_dir, exist_ok=True)
        
        file_handler = logging.handlers.RotatingFileHandler(
            settings.LOG_FILE,
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5
        )
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(JSONFormatter())
        file_handler.addFilter(SecurityFilter())
        root_logger.addHandler(file_handler)
    
    # Error file handler (sadece error ve critical)
    if settings.LOG_FILE:
        error_log_file = settings.LOG_FILE.replace('.log', '_error.log')
        error_handler = logging.handlers.RotatingFileHandler(
            error_log_file,
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=3
        )
        error_handler.setLevel(logging.ERROR)
        error_handler.setFormatter(JSONFormatter())
        error_handler.addFilter(SecurityFilter())
        root_logger.addHandler(error_handler)
    
    # Specific logger configurations
    
    # Supabase client loglarını azalt
    logging.getLogger("supabase").setLevel(logging.WARNING)
    logging.getLogger("httpx").setLevel(logging.WARNING)
    logging.getLogger("httpcore").setLevel(logging.WARNING)
    
    # Uvicorn loglarını ayarla
    uvicorn_access_logger = logging.getLogger("uvicorn.access")
    uvicorn_access_logger.setLevel(logging.WARNING)  # Access loglarını azalt
    
    uvicorn_error_logger = logging.getLogger("uvicorn.error")
    uvicorn_error_logger.setLevel(logging.INFO)
    
    # FastAPI loglarını ayarla
    logging.getLogger("fastapi").setLevel(logging.INFO)
    
    logging.info("Logging configuration completed")

def get_logger(name: str) -> logging.Logger:
    """
    İsimlendirilmiş logger al
    """
    return logging.getLogger(name)

def log_request(request_id: str, method: str, path: str, ip_address: str, user_id: str = None):
    """
    HTTP isteğini logla
    """
    logger = get_logger("request")
    extra = {
        "request_id": request_id,
        "ip_address": ip_address
    }
    if user_id:
        extra["user_id"] = user_id
    
    logger.info(f"{method} {path}", extra=extra)

def log_response(request_id: str, status_code: int, response_time: float):
    """
    HTTP yanıtını logla
    """
    logger = get_logger("response")
    logger.info(
        f"Response: {status_code} in {response_time:.4f}s",
        extra={"request_id": request_id}
    )

def log_error(error: Exception, context: Dict[str, Any] = None):
    """
    Hata logla
    """
    logger = get_logger("error")
    extra = context or {}
    logger.error(f"Error: {str(error)}", exc_info=True, extra=extra)

def log_security_event(event_type: str, details: Dict[str, Any], ip_address: str = None):
    """
    Güvenlik olayını logla
    """
    logger = get_logger("security")
    extra = {"event_type": event_type}
    if ip_address:
        extra["ip_address"] = ip_address
    
    logger.warning(f"Security event: {event_type} - {details}", extra=extra)

def log_business_event(event_type: str, user_id: str, details: Dict[str, Any]):
    """
    İş mantığı olayını logla
    """
    logger = get_logger("business")
    logger.info(
        f"Business event: {event_type} - {details}",
        extra={"user_id": user_id, "event_type": event_type}
    ) 