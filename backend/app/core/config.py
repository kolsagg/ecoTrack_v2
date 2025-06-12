from supabase import create_client, Client
from dotenv import load_dotenv
import os
import json
from typing import List
from pydantic_settings import BaseSettings

# Load environment variables
load_dotenv()

class Settings(BaseSettings):
    # Project information
    PROJECT_NAME: str = "EcoTrack API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    FRONTEND_URL: str = "http://localhost:8080"  # Flutter frontend URL
    
    # Web application settings
    WEB_BASE_URL: str = os.getenv("WEB_BASE_URL", "http://localhost:8000")  # Base URL for web receipt viewing
    
    # Environment settings
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "dev")
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # Security settings
    FORCE_HTTPS: bool = os.getenv("FORCE_HTTPS", "False").lower() == "true"
    RATE_LIMIT_CALLS: int = int(os.getenv("RATE_LIMIT_CALLS", "100"))
    RATE_LIMIT_PERIOD: int = int(os.getenv("RATE_LIMIT_PERIOD", "60"))
    
    # CORS settings
    CORS_ORIGINS: List[str] = [
        "http://localhost:8080",  # Flutter frontend
        "http://localhost:8000",  # FastAPI backend
    ]
    
    # Supabase settings
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    
    # Ollama settings
    OLLAMA_ENABLED: bool = os.getenv("OLLAMA_ENABLED", "true").lower() == "true"
    OLLAMA_HOST: str = os.getenv("OLLAMA_HOST", "http://localhost:11434")
    OLLAMA_MODEL: str = os.getenv("OLLAMA_MODEL", "qwen2.5:3b")
    OLLAMA_TIMEOUT: int = int(os.getenv("OLLAMA_TIMEOUT", "30"))
    
    # Merchant Integration settings
    MERCHANT_API_KEY_LENGTH: int = 32
    MERCHANT_API_KEY_PREFIX: str = "mk_"
    WEBHOOK_TIMEOUT: int = int(os.getenv("WEBHOOK_TIMEOUT", "30"))
    WEBHOOK_RETRY_ATTEMPTS: int = int(os.getenv("WEBHOOK_RETRY_ATTEMPTS", "3"))
    WEBHOOK_RETRY_DELAY: int = int(os.getenv("WEBHOOK_RETRY_DELAY", "60"))  # seconds
    
    # Security settings
    JWT_SECRET_KEY: str = os.getenv("JWT_SECRET_KEY", "")
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # Push Notification settings
    FCM_SERVER_KEY: str = os.getenv("FCM_SERVER_KEY", "")
    
    # Logging settings
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
    LOG_FILE: str = os.getenv("LOG_FILE", "logs/app.log")
    
    # Scheduler settings
    SCHEDULER_ENABLED: bool = os.getenv("SCHEDULER_ENABLED", "True").lower() == "true"
    
    # Initialize Supabase client
    @property
    def supabase(self) -> Client:
        return create_client(self.SUPABASE_URL, self.SUPABASE_KEY)
    
    # Initialize Supabase admin client with service role key
    @property
    def supabase_admin(self) -> Client:
        return create_client(self.SUPABASE_URL, self.SUPABASE_SERVICE_ROLE_KEY)

    class Config:
        env_file = ".env"

# Create global settings object
settings = Settings() 