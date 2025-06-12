"""
End-to-End Complete Workflow Tests
Tam iş akışı e2e testleri
"""

import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from tests.utils.test_helpers import TestClient, AuthHelper, DataFactory, AssertionHelper, TestReporter
from datetime import datetime
import time


class CompleteWorkflowE2ETest:
    """Complete workflow e2e testleri"""
    
    def __init__(self):
        self.client = AuthHelper.get_admin_client()
        self.reporter = TestReporter()
        self.created_resources = {
            "merchants": [],
            "receipts": [],
            "expenses": []
        }
    
    def test_merchant_to_expense_workflow(self):
        """Merchant'tan expense'e kadar tam workflow testi"""
        try:
            print("🔄 Merchant to Expense Workflow başlıyor...")
            
            # 1. Merchant oluştur
            merchant_data = DataFactory.create_merchant_data("E2E Test Restaurant")
            merchant_response = self.client.post("/api/v1/merchants/", merchant_data)
            AssertionHelper.assert_response_success(merchant_response, 201)
            
            merchant = merchant_response.json()
            merchant_id = merchant["id"]
            api_key = merchant["api_key"]
            self.created_resources["merchants"].append(merchant_id)
            
            print(f"✅ Merchant oluşturuldu: {merchant_id}")
            
            # 2. Webhook transaction gönder
            webhook_data = DataFactory.create_webhook_transaction_data()
            webhook_client = TestClient()
            webhook_client.set_api_key(api_key)
            
            webhook_response = webhook_client.post(
                f"/api/v1/webhooks/merchant/{merchant_id}/transaction",
                webhook_data
            )
            AssertionHelper.assert_response_success(webhook_response, 200)
            
            webhook_result = webhook_response.json()
            print(f"✅ Webhook işlendi: {webhook_result.get('status', 'success')}")
            
            # 3. Receipt oluşturulduğunu kontrol et
            time.sleep(1)  # Async işlem için bekle
            receipts_response = self.client.get("/api/v1/receipts/")
            AssertionHelper.assert_response_success(receipts_response, 200)
            
            receipts_data = receipts_response.json()
            assert len(receipts_data["receipts"]) > 0
            
            latest_receipt = receipts_data["receipts"][0]
            self.created_resources["receipts"].append(latest_receipt["id"])
            print(f"✅ Receipt oluşturuldu: {latest_receipt['id']}")
            
            # 4. Expense oluşturulduğunu kontrol et
            expenses_response = self.client.get("/api/v1/expenses/")
            AssertionHelper.assert_response_success(expenses_response, 200)
            
            expenses_data = expenses_response.json()
            assert len(expenses_data["expenses"]) > 0
            
            latest_expense = expenses_data["expenses"][0]
            self.created_resources["expenses"].append(latest_expense["id"])
            print(f"✅ Expense oluşturuldu: {latest_expense['id']}")
            
            # 5. İstatistiklerin güncellendiğini kontrol et
            stats_response = self.client.get("/api/v1/expenses/statistics")
            AssertionHelper.assert_response_success(stats_response, 200)
            
            stats_data = stats_response.json()
            assert stats_data["total_expenses"] > 0
            assert stats_data["total_amount"] > 0
            print(f"✅ İstatistikler güncellendi: {stats_data['total_expenses']} expenses")
            
            self.reporter.add_result("Merchant to Expense Workflow", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Merchant to Expense Workflow", "FAIL", str(e))
    
    def test_receipt_processing_workflow(self):
        """Receipt processing tam workflow testi"""
        try:
            print("🔄 Receipt Processing Workflow başlıyor...")
            
            # 1. Receipt oluştur
            receipt_data = DataFactory.create_receipt_data()
            receipt_response = self.client.post("/api/v1/receipts/", receipt_data)
            AssertionHelper.assert_response_success(receipt_response, 201)
            
            receipt = receipt_response.json()
            receipt_id = receipt["id"]
            self.created_resources["receipts"].append(receipt_id)
            print(f"✅ Receipt oluşturuldu: {receipt_id}")
            
            # 2. Receipt items kontrol et
            items_response = self.client.get(f"/api/v1/receipts/{receipt_id}/items")
            if items_response.status_code == 200:
                items_data = items_response.json()
                assert isinstance(items_data, list)
                print(f"✅ Receipt items alındı: {len(items_data)} items")
            
            # 3. Receipt'i expense'e dönüştür
            expense_data = {
                "amount": receipt["total_amount"],
                "currency": receipt["currency"],
                "description": f"Expense from receipt: {receipt['merchant_name']}",
                "category": "food",
                "date": datetime.now().isoformat(),
                "payment_method": "credit_card",
                "receipt_id": receipt_id
            }
            
            expense_response = self.client.post("/api/v1/expenses/", expense_data)
            AssertionHelper.assert_response_success(expense_response, 201)
            
            expense = expense_response.json()
            self.created_resources["expenses"].append(expense["id"])
            print(f"✅ Expense oluşturuldu: {expense['id']}")
            
            # 4. Receipt ve expense ilişkisini kontrol et
            expense_detail_response = self.client.get(f"/api/v1/expenses/{expense['id']}")
            AssertionHelper.assert_response_success(expense_detail_response, 200)
            
            expense_detail = expense_detail_response.json()
            if "receipt_id" in expense_detail:
                assert expense_detail["receipt_id"] == receipt_id
                print("✅ Receipt-Expense ilişkisi kuruldu")
            
            self.reporter.add_result("Receipt Processing Workflow", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Receipt Processing Workflow", "FAIL", str(e))
    
    def test_ai_integration_workflow(self):
        """AI integration tam workflow testi"""
        try:
            print("🔄 AI Integration Workflow başlıyor...")
            
            # 1. Expense oluştur
            expense_data = DataFactory.create_expense_data(75.0)
            expense_data["description"] = "McDonald's Big Mac menü"
            
            expense_response = self.client.post("/api/v1/expenses/", expense_data)
            AssertionHelper.assert_response_success(expense_response, 201)
            
            expense = expense_response.json()
            self.created_resources["expenses"].append(expense["id"])
            print(f"✅ Expense oluşturuldu: {expense['id']}")
            
            # 2. AI kategorilendirme test et
            categorization_data = {
                "description": expense_data["description"],
                "merchant_name": "McDonald's",
                "amount": expense_data["amount"]
            }
            
            ai_response = self.client.post("/api/v1/ai/categorize", categorization_data)
            if ai_response.status_code == 200:
                ai_data = ai_response.json()
                print(f"✅ AI kategorilendirme: {ai_data.get('category', 'N/A')}")
            else:
                print("⚠️ AI kategorilendirme endpoint mevcut değil")
            
            # 3. Spending insights al
            insights_response = self.client.get("/api/v1/ai/insights/spending")
            if insights_response.status_code == 200:
                insights_data = insights_response.json()
                print(f"✅ Spending insights alındı: {len(insights_data.get('insights', []))} insights")
            else:
                print("⚠️ AI insights endpoint mevcut değil")
            
            # 4. Budget recommendations al
            budget_response = self.client.get("/api/v1/ai/recommendations/budget")
            if budget_response.status_code == 200:
                budget_data = budget_response.json()
                print(f"✅ Budget recommendations alındı: {len(budget_data.get('recommendations', []))} recommendations")
            else:
                print("⚠️ AI budget recommendations endpoint mevcut değil")
            
            self.reporter.add_result("AI Integration Workflow", "PASS")
            
        except Exception as e:
            self.reporter.add_result("AI Integration Workflow", "FAIL", str(e))
    
    def test_search_and_filter_workflow(self):
        """Search ve filter tam workflow testi"""
        try:
            print("🔄 Search and Filter Workflow başlıyor...")
            
            # 1. Birkaç expense oluştur
            for i in range(3):
                expense_data = DataFactory.create_expense_data(50.0 + i * 25)
                expense_data["description"] = f"Test expense {i+1}"
                expense_data["category"] = ["food", "transport", "shopping"][i]
                
                expense_response = self.client.post("/api/v1/expenses/", expense_data)
                AssertionHelper.assert_response_success(expense_response, 201)
                
                expense = expense_response.json()
                self.created_resources["expenses"].append(expense["id"])
            
            print("✅ Test expenses oluşturuldu")
            
            # 2. Expense listeleme ve filtreleme
            list_response = self.client.get("/api/v1/expenses/?page=1&size=10")
            AssertionHelper.assert_response_success(list_response, 200)
            
            list_data = list_response.json()
            assert len(list_data["expenses"]) >= 3
            print(f"✅ Expense listesi alındı: {len(list_data['expenses'])} expenses")
            
            # 3. Kategori bazlı filtreleme
            category_response = self.client.get("/api/v1/expenses/?category=food")
            if category_response.status_code == 200:
                category_data = category_response.json()
                print(f"✅ Kategori filtresi çalışıyor: {len(category_data.get('expenses', []))} food expenses")
            
            # 4. Receipt search test et
            receipt_search_response = self.client.get("/api/v1/receipts/search?q=Test")
            if receipt_search_response.status_code == 200:
                search_data = receipt_search_response.json()
                print(f"✅ Receipt search çalışıyor: {len(search_data.get('receipts', []))} results")
            else:
                print("⚠️ Receipt search endpoint mevcut değil")
            
            self.reporter.add_result("Search and Filter Workflow", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Search and Filter Workflow", "FAIL", str(e))
    
    def test_statistics_and_reporting_workflow(self):
        """Statistics ve reporting tam workflow testi"""
        try:
            print("🔄 Statistics and Reporting Workflow başlıyor...")
            
            # 1. Expense statistics
            expense_stats_response = self.client.get("/api/v1/expenses/statistics")
            AssertionHelper.assert_response_success(expense_stats_response, 200)
            
            expense_stats = expense_stats_response.json()
            print(f"✅ Expense statistics: {expense_stats['total_expenses']} expenses, {expense_stats['total_amount']} total")
            
            # 2. Receipt statistics
            receipt_stats_response = self.client.get("/api/v1/receipts/statistics")
            if receipt_stats_response.status_code == 200:
                receipt_stats = receipt_stats_response.json()
                print(f"✅ Receipt statistics: {receipt_stats.get('total_receipts', 0)} receipts")
            
            # 3. Merchant statistics
            merchant_stats_response = self.client.get("/api/v1/merchants/")
            AssertionHelper.assert_response_success(merchant_stats_response, 200)
            
            merchant_stats = merchant_stats_response.json()
            print(f"✅ Merchant statistics: {len(merchant_stats.get('merchants', []))} merchants")
            
            # 4. Webhook statistics
            if self.created_resources["merchants"]:
                merchant_id = self.created_resources["merchants"][0]
                webhook_stats_response = self.client.get(f"/api/v1/webhooks/merchant/{merchant_id}/stats")
                if webhook_stats_response.status_code == 200:
                    webhook_stats = webhook_stats_response.json()
                    print(f"✅ Webhook statistics alındı")
            
            self.reporter.add_result("Statistics and Reporting Workflow", "PASS")
            
        except Exception as e:
            self.reporter.add_result("Statistics and Reporting Workflow", "FAIL", str(e))
    
    def cleanup_resources(self):
        """Test sonrası temizlik"""
        try:
            print("🧹 Test resources temizleniyor...")
            
            # Expenses sil
            for expense_id in self.created_resources["expenses"]:
                try:
                    self.client.delete(f"/api/v1/expenses/{expense_id}")
                except:
                    pass
            
            # Receipts sil
            for receipt_id in self.created_resources["receipts"]:
                try:
                    self.client.delete(f"/api/v1/receipts/{receipt_id}")
                except:
                    pass
            
            # Merchants sil
            for merchant_id in self.created_resources["merchants"]:
                try:
                    self.client.delete(f"/api/v1/merchants/{merchant_id}")
                except:
                    pass
            
            print("✅ Temizlik tamamlandı")
            
        except Exception as e:
            print(f"⚠️ Temizlik hatası: {str(e)}")
    
    def run_all_tests(self):
        """Tüm e2e testleri çalıştır"""
        print("🧪 Complete Workflow E2E Tests Başlıyor...")
        print("=" * 60)
        
        test_methods = [
            self.test_merchant_to_expense_workflow,
            self.test_receipt_processing_workflow,
            self.test_ai_integration_workflow,
            self.test_search_and_filter_workflow,
            self.test_statistics_and_reporting_workflow,
        ]
        
        for test_method in test_methods:
            try:
                test_method()
                print()  # Boş satır
            except Exception as e:
                print(f"❌ Test failed: {test_method.__name__}: {str(e)}")
        
        # Temizlik
        self.cleanup_resources()
        
        self.reporter.print_summary()


if __name__ == "__main__":
    test_runner = CompleteWorkflowE2ETest()
    test_runner.run_all_tests() 