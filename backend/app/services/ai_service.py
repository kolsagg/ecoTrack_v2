import httpx
import logging
from typing import Optional
from app.core.config import settings

logger = logging.getLogger(__name__)

class AIService:
    """
    Ollama AI servisi için basit wrapper
    """
    def __init__(self):
        self.base_url = settings.OLLAMA_HOST
        self.model = settings.OLLAMA_MODEL
        self.timeout = settings.OLLAMA_TIMEOUT
    
    async def test_connection(self) -> bool:
        """
        Ollama bağlantısını test et
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.get(f"{self.base_url}/api/tags")
                return response.status_code == 200
        except Exception as e:
            logger.error(f"Ollama connection test failed: {e}")
            raise
    
    async def generate_simple_response(self, prompt: str) -> Optional[str]:
        """
        Basit AI yanıtı oluştur
        """
        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                payload = {
                    "model": self.model,
                    "prompt": prompt,
                    "stream": False
                }
                response = await client.post(
                    f"{self.base_url}/api/generate",
                    json=payload
                )
                if response.status_code == 200:
                    result = response.json()
                    return result.get("response", "")
                return None
        except Exception as e:
            logger.error(f"AI generation failed: {e}")
            return None 