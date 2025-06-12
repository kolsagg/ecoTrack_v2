import qrcode
import json
from io import BytesIO
import base64
from datetime import datetime
from typing import Dict, Any, Optional
from app.core.config import settings

class QRGenerator:
    """QR Code generator for receipts"""
    
    def __init__(self):
        self.qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        # Base URL for receipt viewing from config
        self.base_url = f"{settings.WEB_BASE_URL}/api/v1/receipts/receipt"
    
    def generate_receipt_qr(
        self,
        receipt_id: str,
        merchant_name: str,
        total_amount: float,
        currency: str = "TRY",
        transaction_date: Optional[datetime] = None
    ) -> str:
        """
        Generate QR code for a receipt with URL format
        Returns base64 encoded QR code image
        """
        if not transaction_date:
            transaction_date = datetime.now()
        
        # Create URL-based QR data for both app and web access
        qr_url = f"{self.base_url}/{receipt_id}"
        
        return self._generate_qr_image(qr_url)
    
    def _create_turkish_receipt_format(
        self,
        receipt_id: str,
        merchant_name: str,
        total_amount: float,
        currency: str,
        transaction_date: datetime
    ) -> str:
        """
        Create URL format for receipt access
        This method is kept for backward compatibility but now returns URL
        """
        return f"{self.base_url}/{receipt_id}"
    
    def _generate_qr_image(self, data: str) -> str:
        """Generate QR code image and return as base64 string"""
        
        # Clear previous data
        self.qr.clear()
        
        # Add new data
        self.qr.add_data(data)
        self.qr.make(fit=True)
        
        # Create QR code image
        qr_image = self.qr.make_image(fill_color="black", back_color="white")
        
        # Convert to base64
        buffer = BytesIO()
        qr_image.save(buffer, format='PNG')
        buffer.seek(0)
        
        qr_base64 = base64.b64encode(buffer.getvalue()).decode()
        return f"data:image/png;base64,{qr_base64}"
    
    def parse_receipt_qr(self, qr_data: str) -> Optional[str]:
        """
        Parse QR data to extract receipt ID
        Now supports both old format and new URL format
        Returns receipt_id if found, None otherwise
        """
        try:
            # Check if it's the new URL format
            if qr_data.startswith(f"{self.base_url}/"):
                receipt_id = qr_data.replace(f"{self.base_url}/", "")
                return receipt_id
            
            # Check for alternative URL formats
            if "ecotrack.com/receipt/" in qr_data:
                parts = qr_data.split("/receipt/")
                if len(parts) > 1:
                    return parts[1].split("?")[0].split("#")[0]  # Remove query params and fragments
            
            # Backward compatibility: Check old text format
            lines = qr_data.strip().split('\n')
            
            # Look for Receipt ID line in old format
            for line in lines:
                if line.startswith("Receipt ID:"):
                    return line.split("Receipt ID:")[1].strip()
            
            return None
            
        except Exception:
            return None

    def extract_receipt_id_from_url(self, url: str) -> Optional[str]:
        """
        Extract receipt ID from various URL formats
        Supports: 
        - https://ecotrack.com/receipt/abc123
        - https://ecotrack.com/receipt/abc123?param=value
        - ecotrack.com/receipt/abc123
        """
        try:
            if "/receipt/" in url:
                parts = url.split("/receipt/")
                if len(parts) > 1:
                    receipt_id = parts[1].split("?")[0].split("#")[0]
                    return receipt_id.strip()
            return None
        except Exception:
            return None 