"""
Test Configuration
Test ortamı için konfigürasyon ayarları

KURULUM:
1. .env.test dosyası oluşturun (root dizinde)
2. Aşağıdaki environment variable'ları ayarlayın:
   - TEST_SUPABASE_URL=https://your-project.supabase.co
   - TEST_SUPABASE_KEY=your_test_supabase_anon_key
   - TEST_SUPABASE_SERVICE_ROLE_KEY=your_test_supabase_service_role_key
   - TEST_API_BASE_URL=http://localhost:8000
"""

import os
from typing import Optional
from dotenv import load_dotenv

# .env.test dosyasını yükle
load_dotenv(".env.test")

class TestConfig:
    """Test ortamı konfigürasyonu"""
    
    # Test ortamı için Supabase ayarları
    SUPABASE_URL: str = os.getenv("TEST_SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("TEST_SUPABASE_KEY", "")
    SUPABASE_SERVICE_ROLE_KEY: str = os.getenv("TEST_SUPABASE_SERVICE_ROLE_KEY", "")
    
    # Test API ayarları
    API_BASE_URL: str = os.getenv("TEST_API_BASE_URL", "http://localhost:8000")
    
    @classmethod
    def get_service_role_token(cls) -> str:
        """Service role token al"""
        token = cls.SUPABASE_SERVICE_ROLE_KEY
        if not token:
            raise ValueError(
                "❌ TEST_SUPABASE_SERVICE_ROLE_KEY environment variable gerekli!\n"
                "Lütfen .env.test dosyasında bu değişkeni ayarlayın:\n"
                "TEST_SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here"
            )
        return token
    
    @classmethod
    def get_anon_key(cls) -> str:
        """Anon key al"""
        key = cls.SUPABASE_KEY
        if not key:
            raise ValueError(
                "❌ TEST_SUPABASE_KEY environment variable gerekli!\n"
                "Lütfen .env.test dosyasında bu değişkeni ayarlayın:\n"
                "TEST_SUPABASE_KEY=your_anon_key_here"
            )
        return key
    
    @classmethod
    def validate_config(cls) -> bool:
        """Test konfigürasyonunu doğrula"""
        required_vars = [
            ("TEST_SUPABASE_URL", cls.SUPABASE_URL),
            ("TEST_SUPABASE_KEY", cls.SUPABASE_KEY),
            ("TEST_SUPABASE_SERVICE_ROLE_KEY", cls.SUPABASE_SERVICE_ROLE_KEY),
        ]
        
        missing_vars = []
        for var_name, var_value in required_vars:
            if not var_value:
                missing_vars.append(var_name)
        
        if missing_vars:
            print(f"❌ Eksik environment variable'lar: {', '.join(missing_vars)}")
            print("\n📝 .env.test dosyası oluşturun ve aşağıdaki değişkenleri ayarlayın:")
            print("TEST_SUPABASE_URL=https://your-project.supabase.co")
            print("TEST_SUPABASE_KEY=your_test_supabase_anon_key")
            print("TEST_SUPABASE_SERVICE_ROLE_KEY=your_test_supabase_service_role_key")
            print("TEST_API_BASE_URL=http://localhost:8000")
            return False
        
        return True

# Global test config instance
test_config = TestConfig() 