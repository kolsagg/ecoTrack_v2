"""
Test Helper Functions
Tüm testlerde kullanılacak yardımcı fonksiyonlar
"""

import requests
import json
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from uuid import UUID
import os
import sys

# Test config'i import et
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from tests.config import test_config

class TestClient:
    """Test için HTTP client wrapper"""
    
    def __init__(self, base_url: str = None):
        self.base_url = base_url or test_config.API_BASE_URL
        self.session = requests.Session()
    
    def set_auth_token(self, token: str):
        """Auth token ayarla"""
        self.session.headers.update({"Authorization": f"Bearer {token}"})
    
    def set_api_key(self, api_key: str):
        """API key ayarla"""
        self.session.headers.update({"X-API-Key": api_key})
    
    def clear_headers(self):
        """Tüm header'ları temizle"""
        self.session.headers.clear()
        self.session.headers.update({"Content-Type": "application/json"})
    
    def get(self, endpoint: str, **kwargs) -> requests.Response:
        """GET request"""
        return self.session.get(f"{self.base_url}{endpoint}", **kwargs)
    
    def post(self, endpoint: str, data: Optional[Dict] = None, **kwargs) -> requests.Response:
        """POST request"""
        if data:
            kwargs['json'] = data
        return self.session.post(f"{self.base_url}{endpoint}", **kwargs)
    
    def put(self, endpoint: str, data: Optional[Dict] = None, **kwargs) -> requests.Response:
        """PUT request"""
        if data:
            kwargs['json'] = data
        return self.session.put(f"{self.base_url}{endpoint}", **kwargs)
    
    def delete(self, endpoint: str, **kwargs) -> requests.Response:
        """DELETE request"""
        return self.session.delete(f"{self.base_url}{endpoint}", **kwargs)


class AuthHelper:
    """Authentication helper"""
    
    @staticmethod
    def get_service_role_token() -> str:
        """Service role token al"""
        return test_config.get_service_role_token()
    
    @staticmethod
    def get_admin_client() -> TestClient:
        """Admin yetkili test client al"""
        client = TestClient()
        client.set_auth_token(AuthHelper.get_service_role_token())
        return client


class DataFactory:
    """Test data factory"""
    
    @staticmethod
    def create_merchant_data(name: str = "Test Merchant") -> Dict[str, Any]:
        """Merchant test data oluştur"""
        return {
            "name": name,
            "business_type": "restaurant",
            "contact_email": f"test-{datetime.now().timestamp()}@merchant.com",
            "contact_phone": "+905551234567",
            "address": "Test Mahallesi, Test Sokak No:1, İstanbul"
        }
    
    @staticmethod
    def create_expense_data(amount: float = 100.0) -> Dict[str, Any]:
        """Expense test data oluştur"""
        return {
            "amount": amount,
            "currency": "TRY",
            "description": "Test expense",
            "category": "food",
            "date": datetime.now().isoformat(),
            "payment_method": "credit_card"
        }
    
    @staticmethod
    def create_receipt_data() -> Dict[str, Any]:
        """Receipt test data oluştur"""
        return {
            "merchant_name": "Test Market",
            "total_amount": 125.50,
            "currency": "TRY",
            "date": datetime.now().isoformat(),
            "items": [
                {
                    "name": "Test Item",
                    "description": "Test açıklama",
                    "quantity": 2,
                    "unit_price": 50.0,
                    "total_price": 100.0,
                    "category": "food"
                }
            ],
            "payment_method": "credit_card",
            "location": {
                "address": "Test Market, İstanbul",
                "latitude": 41.0082,
                "longitude": 28.9784
            }
        }
    
    @staticmethod
    def create_webhook_transaction_data() -> Dict[str, Any]:
        """Webhook transaction test data oluştur"""
        return {
            "transaction_id": f"test-txn-{int(datetime.now().timestamp())}",
            "total_amount": 125.50,
            "currency": "TRY",
            "transaction_date": datetime.now().isoformat(),
            "customer_info": {
                "email": "customer@test.com",
                "phone": "+905559876543",
                "card_last_four": "1234"
            },
            "items": [
                {
                    "name": "Hamburger",
                    "description": "Lezzetli hamburger menü",
                    "quantity": 2,
                    "unit_price": 45.00,
                    "total_price": 90.00,
                    "category": "food"
                },
                {
                    "name": "Kola",
                    "description": "Soğuk içecek",
                    "quantity": 2,
                    "unit_price": 17.75,
                    "total_price": 35.50,
                    "category": "beverage"
                }
            ],
            "payment_method": "credit_card",
            "location": {
                "address": "Test Restaurant, İstanbul",
                "latitude": 41.0082,
                "longitude": 28.9784
            }
        }


class AssertionHelper:
    """Test assertion helper"""
    
    @staticmethod
    def assert_response_success(response: requests.Response, expected_status: int = 200):
        """Response başarılı mı kontrol et"""
        assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}: {response.text}"
    
    @staticmethod
    def assert_response_error(response: requests.Response, expected_status: int = 400):
        """Response hatalı mı kontrol et"""
        assert response.status_code == expected_status, f"Expected {expected_status}, got {response.status_code}: {response.text}"
    
    @staticmethod
    def assert_has_fields(data: Dict, required_fields: list):
        """Gerekli field'lar var mı kontrol et"""
        for field in required_fields:
            assert field in data, f"Missing required field: {field}"
    
    @staticmethod
    def assert_valid_uuid(uuid_string: str):
        """Geçerli UUID mı kontrol et"""
        try:
            UUID(uuid_string)
        except ValueError:
            assert False, f"Invalid UUID: {uuid_string}"


class TestDataManager:
    """Test data management helper"""
    
    def __init__(self):
        self.created_data = []
        self.client = AuthHelper.get_admin_client()
    
    def track_created_data(self, data_type: str, data_id: str):
        """Oluşturulan test verisini takip et"""
        self.created_data.append({"type": data_type, "id": data_id})
    
    def cleanup_all(self):
        """Tüm test verilerini temizle"""
        for data in self.created_data:
            try:
                if data["type"] == "merchant":
                    self.client.delete(f"/api/merchants/{data['id']}")
                elif data["type"] == "expense":
                    self.client.delete(f"/api/expenses/{data['id']}")
                elif data["type"] == "receipt":
                    self.client.delete(f"/api/receipts/{data['id']}")
            except Exception as e:
                print(f"Cleanup error for {data['type']} {data['id']}: {e}")
        
        self.created_data.clear()
    
    def create_test_merchant(self, name: str = "Test Merchant") -> Optional[str]:
        """Test merchant oluştur"""
        try:
            merchant_data = DataFactory.create_merchant_data(name)
            response = self.client.post("/api/merchants", merchant_data)
            
            if response.status_code == 201:
                merchant_id = response.json().get("id")
                self.track_created_data("merchant", merchant_id)
                return merchant_id
        except Exception as e:
            print(f"Test merchant creation error: {e}")
        
        return None
    
    def create_test_expense(self, amount: float = 100.0) -> Optional[str]:
        """Test expense oluştur"""
        try:
            expense_data = DataFactory.create_expense_data(amount)
            response = self.client.post("/api/expenses", expense_data)
            
            if response.status_code == 201:
                expense_id = response.json().get("id")
                self.track_created_data("expense", expense_id)
                return expense_id
        except Exception as e:
            print(f"Test expense creation error: {e}")
        
        return None
    
    def generate_test_data_set(self, count: int = 10) -> Dict[str, Any]:
        """Test veri seti oluştur"""
        data_set = {
            "merchants": [],
            "expenses": [],
            "receipts": []
        }
        
        # Test merchant'ları oluştur
        for i in range(min(count, 3)):
            merchant_id = self.create_test_merchant(f"Test Merchant {i+1}")
            if merchant_id:
                data_set["merchants"].append(merchant_id)
        
        # Test expense'ları oluştur
        for i in range(count):
            amount = 50.0 + (i * 10.0)
            expense_id = self.create_test_expense(amount)
            if expense_id:
                data_set["expenses"].append(expense_id)
        
        return data_set
        # Bu method gerçek cleanup logic'i içerebilir
        self.created_data.clear()


class TestReporter:
    """Test sonuçları reporter"""
    
    def __init__(self):
        self.results = []
    
    def add_result(self, test_name: str, status: str, details: str = ""):
        """Test sonucu ekle"""
        self.results.append({
            "test": test_name,
            "status": status,
            "details": details,
            "timestamp": datetime.now().isoformat()
        })
    
    def print_summary(self):
        """Özet yazdır"""
        total = len(self.results)
        passed = len([r for r in self.results if r["status"] == "PASS"])
        failed = len([r for r in self.results if r["status"] == "FAIL"])
        
        print(f"\n{'='*60}")
        print(f"TEST SUMMARY")
        print(f"{'='*60}")
        print(f"Total Tests: {total}")
        print(f"Passed: {passed} ✅")
        print(f"Failed: {failed} ❌")
        print(f"Success Rate: {(passed/total*100):.1f}%" if total > 0 else "0%")
        
        if failed > 0:
            print(f"\n❌ FAILED TESTS:")
            for result in self.results:
                if result["status"] == "FAIL":
                    print(f"  - {result['test']}: {result['details']}") 