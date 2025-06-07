import qrcode
import json
from io import BytesIO
import base64
from datetime import datetime
from typing import Dict, Any, Optional

class QRGenerator:
    """QR Code generator for receipts"""
    
    def __init__(self):
        self.qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
    
    def generate_receipt_qr(
        self,
        receipt_id: str,
        merchant_name: str,
        total_amount: float,
        currency: str = "TRY",
        transaction_date: Optional[datetime] = None
    ) -> str:
        """
        Generate QR code for a receipt in Turkish e-receipt format
        Returns base64 encoded QR code image
        """
        if not transaction_date:
            transaction_date = datetime.now()
        
        # Create Turkish e-receipt format QR data
        qr_data = self._create_turkish_receipt_format(
            receipt_id=receipt_id,
            merchant_name=merchant_name,
            total_amount=total_amount,
            currency=currency,
            transaction_date=transaction_date
        )
        
        return self._generate_qr_image(qr_data)
    
    def _create_turkish_receipt_format(
        self,
        receipt_id: str,
        merchant_name: str,
        total_amount: float,
        currency: str,
        transaction_date: datetime
    ) -> str:
        """Create Turkish e-receipt format QR data"""
        
        # Format similar to Turkish e-receipt QR codes
        qr_lines = [
            f"{merchant_name}",
            f"Fiş No: {receipt_id[:8]}",
            f"Tarih: {transaction_date.strftime('%d.%m.%Y %H:%M')}",
            f"Toplam: {total_amount:.2f} {currency}",
            f"EcoTrack Dijital Fiş",
            f"Receipt ID: {receipt_id}"
        ]
        
        return "\n".join(qr_lines)
    
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
        Returns receipt_id if found, None otherwise
        """
        try:
            lines = qr_data.strip().split('\n')
            
            # Look for Receipt ID line
            for line in lines:
                if line.startswith("Receipt ID:"):
                    return line.split("Receipt ID:")[1].strip()
            
            return None
            
        except Exception:
            return None 