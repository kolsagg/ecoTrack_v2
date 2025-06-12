"""
Expenses Integration Tests
Expense endpoint'lerinin integration testleri
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from tests.utils.test_helpers import TestClient, AuthHelper, DataFactory, AssertionHelper, TestReporter
from datetime import datetime
import uuid


class ExpensesIntegrationTest:
    """Expenses endpoint integration testleri"""
    
    def __init__(self):
        self.client = AuthHelper.get_admin_client()
        self.reporter = TestReporter()
        self.created_expense_ids = []
    
    def test_create_expense(self):
        """Expense oluşturma testi"""
        try:
            expense_data = DataFactory.create_expense_data(150.0)
            response = self.client.post("/api/v1/expenses/", expense_data)
            
            AssertionHelper.assert_response_success(response, 201)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["id", "amount", "currency", "description"])
            AssertionHelper.assert_valid_uuid(data["id"])
            
            assert data["amount"] == 150.0
            assert data["currency"] == "TRY"
            
            self.created_expense_ids.append(data["id"])
            self.reporter.add_result("Create Expense", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Create Expense", "FAIL", str(e))
    
    def test_list_expenses(self):
        """Expense listeleme testi"""
        try:
            response = self.client.get("/api/v1/expenses/")
            
            AssertionHelper.assert_response_success(response, 200)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["expenses", "total", "page", "size"])
            assert isinstance(data["expenses"], list)
            assert data["total"] >= 0
            
            self.reporter.add_result("List Expenses", "PASS")
            
        except Exception as e:
            self.reporter.add_result("List Expenses", "FAIL", str(e))
    
    def test_get_expense_by_id(self):
        """ID ile expense getirme testi"""
        try:
            if not self.created_expense_ids:
                self.test_create_expense()
            
            if self.created_expense_ids:
                expense_id = self.created_expense_ids[0]
                response = self.client.get(f"/api/v1/expenses/{expense_id}")
                
                AssertionHelper.assert_response_success(response, 200)
                data = response.json()
                
                AssertionHelper.assert_has_fields(data, ["id", "amount", "currency"])
                assert data["id"] == expense_id
                
                self.reporter.add_result("Get Expense by ID", "PASS")
            else:
                self.reporter.add_result("Get Expense by ID", "FAIL", "No expense created")
                
        except Exception as e:
            self.reporter.add_result("Get Expense by ID", "FAIL", str(e))
    
    def test_update_expense(self):
        """Expense güncelleme testi"""
        try:
            if not self.created_expense_ids:
                self.test_create_expense()
            
            if self.created_expense_ids:
                expense_id = self.created_expense_ids[0]
                update_data = {
                    "description": "Updated test expense",
                    "amount": 200.0
                }
                
                response = self.client.put(f"/api/v1/expenses/{expense_id}", update_data)
                
                AssertionHelper.assert_response_success(response, 200)
                data = response.json()
                
                assert data["description"] == "Updated test expense"
                assert data["amount"] == 200.0
                
                self.reporter.add_result("Update Expense", "PASS")
            else:
                self.reporter.add_result("Update Expense", "FAIL", "No expense created")
                
        except Exception as e:
            self.reporter.add_result("Update Expense", "FAIL", str(e))
    
    def test_delete_expense(self):
        """Expense silme testi"""
        try:
            if not self.created_expense_ids:
                self.test_create_expense()
            
            if self.created_expense_ids:
                expense_id = self.created_expense_ids[0]
                response = self.client.delete(f"/api/v1/expenses/{expense_id}")
                
                AssertionHelper.assert_response_success(response, 204)
                
                # Silindiğini kontrol et
                get_response = self.client.get(f"/api/v1/expenses/{expense_id}")
                AssertionHelper.assert_response_error(get_response, 404)
                
                self.reporter.add_result("Delete Expense", "PASS")
            else:
                self.reporter.add_result("Delete Expense", "FAIL", "No expense created")
                
        except Exception as e:
            self.reporter.add_result("Delete Expense", "FAIL", str(e))
    
    def test_expense_categories(self):
        """Expense kategorileri testi"""
        try:
            response = self.client.get("/api/v1/expenses/categories")
            
            AssertionHelper.assert_response_success(response, 200)
            data = response.json()
            
            assert isinstance(data, list)
            assert len(data) > 0
            
            self.reporter.add_result("Expense Categories", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Expense Categories", "FAIL", str(e))
    
    def test_expense_statistics(self):
        """Expense istatistikleri testi"""
        try:
            response = self.client.get("/api/v1/expenses/statistics")
            
            AssertionHelper.assert_response_success(response, 200)
            data = response.json()
            
            AssertionHelper.assert_has_fields(data, ["total_expenses", "total_amount"])
            assert isinstance(data["total_expenses"], int)
            assert isinstance(data["total_amount"], (int, float))
            
            self.reporter.add_result("Expense Statistics", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Expense Statistics", "FAIL", str(e))
    
    def test_expense_validation_errors(self):
        """Expense validation hataları testi"""
        try:
            # Geçersiz data ile expense oluşturmaya çalış
            invalid_data = {
                "amount": -100,  # Negatif amount
                "currency": "INVALID",  # Geçersiz currency
                "description": "",  # Boş description
            }
            
            response = self.client.post("/api/v1/expenses/", invalid_data)
            AssertionHelper.assert_response_error(response, 422)
            
            self.reporter.add_result("Expense Validation Errors", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Expense Validation Errors", "FAIL", str(e))
    
    def test_unauthorized_access(self):
        """Yetkisiz erişim testi"""
        try:
            # Auth token olmadan istek gönder
            unauthorized_client = TestClient()
            response = unauthorized_client.get("/api/v1/expenses/")
            
            AssertionHelper.assert_response_error(response, 401)
            
            self.reporter.add_result("Unauthorized Access", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Unauthorized Access", "FAIL", str(e))
    
    def run_all_tests(self):
        """Tüm testleri çalıştır"""
        print("🧪 Expenses Integration Tests Başlıyor...")
        print("=" * 60)
        
        test_methods = [
            self.test_create_expense,
            self.test_list_expenses,
            self.test_get_expense_by_id,
            self.test_update_expense,
            self.test_expense_categories,
            self.test_expense_statistics,
            self.test_expense_validation_errors,
            self.test_unauthorized_access,
            self.test_delete_expense,  # Son olarak sil
        ]
        
        for test_method in test_methods:
            try:
                test_method()
            except Exception as e:
                print(f"❌ Test failed: {test_method.__name__}: {str(e)}")
        
        self.reporter.print_summary()


if __name__ == "__main__":
    test_runner = ExpensesIntegrationTest()
    test_runner.run_all_tests() 