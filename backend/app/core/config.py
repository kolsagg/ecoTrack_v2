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
    
    # Environment settings
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "dev")
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # CORS settings
    CORS_ORIGINS: List[str] = [
        "http://localhost:8080",  # Flutter frontend
        "http://localhost:8000",  # FastAPI backend
    ]
    
    # Supabase settings
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
    
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