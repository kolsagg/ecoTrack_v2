"""
Receipts Integration Tests
Receipt endpoint'lerinin integration testleri
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from tests.utils.test_helpers import TestClient, AuthHelper, DataFactory, AssertionHelper, TestReporter
from datetime import datetime
import uuid


class ReceiptsIntegrationTest:
    """Receipts endpoint integration testleri"""
    
    def __init__(self):
        self.client = AuthHelper.get_admin_client()
        self.reporter = TestReporter()
        self.created_receipt_ids = []
    
    def test_create_receipt(self):
        """Receipt oluşturma testi"""
        try:
            receipt_data = DataFactory.create_receipt_data()
            response = self.client.post("/api/v1/receipts/", receipt_data)
            
            AssertionHelper.assert_response_success(response, 201)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["id", "merchant_name", "total_amount", "currency"])
            AssertionHelper.assert_valid_uuid(data["id"])
            
            assert data["merchant_name"] == "Test Market"
            assert data["total_amount"] == 125.50
            assert data["currency"] == "TRY"
            
            self.created_receipt_ids.append(data["id"])
            self.reporter.add_result("Create Receipt", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Create Receipt", "FAIL", str(e))
    
    def test_list_receipts(self):
        """Receipt listeleme testi"""
        try:
            response = self.client.get("/api/v1/receipts/")
            
            AssertionHelper.assert_response_success(response, 200)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["receipts", "total", "page", "size"])
            assert isinstance(data["receipts"], list)
            assert data["total"] >= 0
            
            self.reporter.add_result("List Receipts", "PASS")
            
        except Exception as e:
            self.reporter.add_result("List Receipts", "FAIL", str(e))
    
    def test_get_receipt_by_id(self):
        """ID ile receipt getirme testi"""
        try:
            if not self.created_receipt_ids:
                self.test_create_receipt()
            
            if self.created_receipt_ids:
                receipt_id = self.created_receipt_ids[0]
                response = self.client.get(f"/api/v1/receipts/{receipt_id}")
                
                AssertionHelper.assert_response_success(response, 200)
                data = response.json()
                
                AssertionHelper.assert_has_fields(data, ["id", "merchant_name", "total_amount"])
                assert data["id"] == receipt_id
                
                self.reporter.add_result("Get Receipt by ID", "PASS")
            else:
                self.reporter.add_result("Get Receipt by ID", "FAIL", "No receipt created")
                
        except Exception as e:
            self.reporter.add_result("Get Receipt by ID", "FAIL", str(e))
    
    def test_update_receipt(self):
        """Receipt güncelleme testi"""
        try:
            if not self.created_receipt_ids:
                self.test_create_receipt()
            
            if self.created_receipt_ids:
                receipt_id = self.created_receipt_ids[0]
                update_data = {
                    "merchant_name": "Updated Test Market",
                    "total_amount": 200.0
                }
                
                response = self.client.put(f"/api/v1/receipts/{receipt_id}", update_data)
                
                AssertionHelper.assert_response_success(response, 200)
                data = response.json()
                
                assert data["merchant_name"] == "Updated Test Market"
                assert data["total_amount"] == 200.0
                
                self.reporter.add_result("Update Receipt", "PASS")
            else:
                self.reporter.add_result("Update Receipt", "FAIL", "No receipt created")
                
        except Exception as e:
            self.reporter.add_result("Update Receipt", "FAIL", str(e))
    
    def test_delete_receipt(self):
        """Receipt silme testi"""
        try:
            if not self.created_receipt_ids:
                self.test_create_receipt()
            
            if self.created_receipt_ids:
                receipt_id = self.created_receipt_ids[0]
                response = self.client.delete(f"/api/v1/receipts/{receipt_id}")
                
                AssertionHelper.assert_response_success(response, 204)
                
                # Silindiğini kontrol et
                get_response = self.client.get(f"/api/v1/receipts/{receipt_id}")
                AssertionHelper.assert_response_error(get_response, 404)
                
                self.reporter.add_result("Delete Receipt", "PASS")
            else:
                self.reporter.add_result("Delete Receipt", "FAIL", "No receipt created")
                
        except Exception as e:
            self.reporter.add_result("Delete Receipt", "FAIL", str(e))
    
    def test_receipt_items(self):
        """Receipt items testi"""
        try:
            if not self.created_receipt_ids:
                self.test_create_receipt()
            
            if self.created_receipt_ids:
                receipt_id = self.created_receipt_ids[0]
                response = self.client.get(f"/api/v1/receipts/{receipt_id}/items")
                
                AssertionHelper.assert_response_success(response, 200)
                data = response.json()
                
                assert isinstance(data, list)
                
                self.reporter.add_result("Receipt Items", "PASS")
            else:
                self.reporter.add_result("Receipt Items", "FAIL", "No receipt created")
                
        except Exception as e:
            self.reporter.add_result("Receipt Items", "FAIL", str(e))
    
    def test_receipt_statistics(self):
        """Receipt istatistikleri testi"""
        try:
            response = self.client.get("/api/v1/receipts/statistics")
            
            AssertionHelper.assert_response_success(response, 200)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["total_receipts", "total_amount"])
            assert isinstance(data["total_receipts"], int)
            assert isinstance(data["total_amount"], (int, float))
            
            self.reporter.add_result("Receipt Statistics", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Receipt Statistics", "FAIL", str(e))
    
    def test_receipt_search(self):
        """Receipt arama testi"""
        try:
            response = self.client.get("/api/v1/receipts/search?q=Test")
            
            AssertionHelper.assert_response_success(response, 200)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["receipts", "total"])
            assert isinstance(data["receipts"], list)
            
            self.reporter.add_result("Receipt Search", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Receipt Search", "FAIL", str(e))
    
    def test_receipt_validation_errors(self):
        """Receipt validation hataları testi"""
        try:
            # Geçersiz data ile receipt oluşturmaya çalış
            invalid_data = {
                "merchant_name": "",  # Boş merchant name
                "total_amount": -100,  # Negatif amount
                "currency": "INVALID",  # Geçersiz currency
                "items": []  # Boş items
            }
            
            response = self.client.post("/api/v1/receipts/", invalid_data)
            AssertionHelper.assert_response_error(response, 422)
            
            self.reporter.add_result("Receipt Validation Errors", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Receipt Validation Errors", "FAIL", str(e))
    
    def test_unauthorized_access(self):
        """Yetkisiz erişim testi"""
        try:
            # Auth token olmadan istek gönder
            unauthorized_client = TestClient()
            response = unauthorized_client.get("/api/v1/receipts/")
            
            AssertionHelper.assert_response_error(response, 401)
            
            self.reporter.add_result("Unauthorized Access", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Unauthorized Access", "FAIL", str(e))
    
    def test_receipt_export(self):
        """Receipt export testi"""
        try:
            response = self.client.get("/api/v1/receipts/export?format=json")
            
            # Export endpoint varsa test et, yoksa skip
            if response.status_code == 404:
                self.reporter.add_result("Receipt Export", "SKIP", "Endpoint not implemented")
            else:
                AssertionHelper.assert_response_success(response, 200)
                self.reporter.add_result("Receipt Export", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Receipt Export", "FAIL", str(e))
    
    def run_all_tests(self):
        """Tüm testleri çalıştır"""
        print("🧪 Receipts Integration Tests Başlıyor...")
        print("=" * 60)
        
        test_methods = [
            self.test_create_receipt,
            self.test_list_receipts,
            self.test_get_receipt_by_id,
            self.test_update_receipt,
            self.test_receipt_items,
            self.test_receipt_statistics,
            self.test_receipt_search,
            self.test_receipt_validation_errors,
            self.test_unauthorized_access,
            self.test_receipt_export,
            self.test_delete_receipt,  # Son olarak sil
        ]
        
        for test_method in test_methods:
            try:
                test_method()
            except Exception as e:
                print(f"❌ Test failed: {test_method.__name__}: {str(e)}")
        
        self.reporter.print_summary()


if __name__ == "__main__":
    test_runner = ReceiptsIntegrationTest()
    test_runner.run_all_tests() 