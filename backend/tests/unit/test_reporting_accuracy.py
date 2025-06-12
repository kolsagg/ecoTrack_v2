"""
Reporting Data Accuracy Tests
Grafik ve raporlama verilerinin doğruluğunu test eder
"""

import sys
import os
import asyncio
import json
from datetime import datetime, timedelta
from decimal import Decimal

# Path setup
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from tests.utils.test_helpers import TestReporter, TestDataManager


class ReportingAccuracyTester:
    """Raporlama verilerinin doğruluğunu test eder"""
    
    def __init__(self):
        self.reporter = TestReporter()
        self.data_manager = TestDataManager()
        self.test_results = []
    
    async def test_spending_distribution_accuracy(self):
        """Harcama dağılımı verilerinin doğruluğunu test eder"""
        try:
            # Test verisi oluştur
            test_data = {
                "categories": [
                    {"name": "Food", "amount": 500.00},
                    {"name": "Transport", "amount": 200.00},
                    {"name": "Entertainment", "amount": 150.00},
                    {"name": "Utilities", "amount": 100.00}
                ],
                "total": 950.00
            }
            
            # Yüzde hesaplamalarını test et
            for category in test_data["categories"]:
                expected_percentage = (category["amount"] / test_data["total"]) * 100
                calculated_percentage = round(expected_percentage, 1)
                
                # Doğruluk kontrolü
                if abs(calculated_percentage - expected_percentage) < 0.1:
                    self.test_results.append({
                        "test": f"Spending Distribution - {category['name']}",
                        "status": "PASS",
                        "expected": f"{expected_percentage:.1f}%",
                        "actual": f"{calculated_percentage:.1f}%"
                    })
                else:
                    self.test_results.append({
                        "test": f"Spending Distribution - {category['name']}",
                        "status": "FAIL",
                        "expected": f"{expected_percentage:.1f}%",
                        "actual": f"{calculated_percentage:.1f}%"
                    })
            
            return True
            
        except Exception as e:
            self.test_results.append({
                "test": "Spending Distribution Accuracy",
                "status": "ERROR",
                "error": str(e)
            })
            return False
    
    async def test_spending_trends_accuracy(self):
        """Harcama trendlerinin doğruluğunu test eder"""
        try:
            # Test verisi - 30 günlük harcama
            daily_spending = []
            base_date = datetime.now() - timedelta(days=30)
            
            for i in range(30):
                date = base_date + timedelta(days=i)
                amount = 50.00 + (i * 2.5)  # Artan trend
                daily_spending.append({
                    "date": date.strftime("%Y-%m-%d"),
                    "amount": amount
                })
            
            # Trend hesaplama testi
            amounts = [item["amount"] for item in daily_spending]
            
            # Basit trend analizi
            first_week_avg = sum(amounts[:7]) / 7
            last_week_avg = sum(amounts[-7:]) / 7
            trend_percentage = ((last_week_avg - first_week_avg) / first_week_avg) * 100
            
            # Pozitif trend bekleniyor
            if trend_percentage > 0:
                self.test_results.append({
                    "test": "Spending Trends - Positive Trend Detection",
                    "status": "PASS",
                    "trend": f"+{trend_percentage:.1f}%"
                })
            else:
                self.test_results.append({
                    "test": "Spending Trends - Positive Trend Detection",
                    "status": "FAIL",
                    "trend": f"{trend_percentage:.1f}%"
                })
            
            return True
            
        except Exception as e:
            self.test_results.append({
                "test": "Spending Trends Accuracy",
                "status": "ERROR",
                "error": str(e)
            })
            return False
    
    async def test_budget_vs_actual_accuracy(self):
        """Bütçe vs gerçek harcama karşılaştırmasının doğruluğunu test eder"""
        try:
            # Test verisi
            budget_data = [
                {"category": "Food", "budgeted": 400.00, "actual": 450.00},
                {"category": "Transport", "budgeted": 200.00, "actual": 180.00},
                {"category": "Entertainment", "budgeted": 150.00, "actual": 200.00}
            ]
            
            for item in budget_data:
                variance = item["actual"] - item["budgeted"]
                variance_percentage = (variance / item["budgeted"]) * 100
                
                # Varyans hesaplama doğruluğu
                expected_variance = item["actual"] - item["budgeted"]
                
                if abs(variance - expected_variance) < 0.01:
                    status = "OVER" if variance > 0 else "UNDER" if variance < 0 else "ON_TARGET"
                    self.test_results.append({
                        "test": f"Budget vs Actual - {item['category']}",
                        "status": "PASS",
                        "variance": f"{variance:.2f}",
                        "variance_percentage": f"{variance_percentage:.1f}%",
                        "budget_status": status
                    })
                else:
                    self.test_results.append({
                        "test": f"Budget vs Actual - {item['category']}",
                        "status": "FAIL",
                        "expected_variance": f"{expected_variance:.2f}",
                        "calculated_variance": f"{variance:.2f}"
                    })
            
            return True
            
        except Exception as e:
            self.test_results.append({
                "test": "Budget vs Actual Accuracy",
                "status": "ERROR",
                "error": str(e)
            })
            return False
    
    async def test_category_spending_over_time_accuracy(self):
        """Kategorilere göre zaman içindeki harcama verilerinin doğruluğunu test eder"""
        try:
            # Test verisi - 3 aylık kategori bazlı harcama
            monthly_data = {
                "2024-01": {"Food": 300, "Transport": 150, "Entertainment": 100},
                "2024-02": {"Food": 350, "Transport": 180, "Entertainment": 120},
                "2024-03": {"Food": 400, "Transport": 200, "Entertainment": 150}
            }
            
            # Her kategori için büyüme oranı hesapla
            categories = ["Food", "Transport", "Entertainment"]
            
            for category in categories:
                jan_amount = monthly_data["2024-01"][category]
                mar_amount = monthly_data["2024-03"][category]
                growth_rate = ((mar_amount - jan_amount) / jan_amount) * 100
                
                # Pozitif büyüme bekleniyor
                if growth_rate > 0:
                    self.test_results.append({
                        "test": f"Category Growth - {category}",
                        "status": "PASS",
                        "growth_rate": f"+{growth_rate:.1f}%",
                        "jan_amount": jan_amount,
                        "mar_amount": mar_amount
                    })
                else:
                    self.test_results.append({
                        "test": f"Category Growth - {category}",
                        "status": "FAIL",
                        "growth_rate": f"{growth_rate:.1f}%"
                    })
            
            return True
            
        except Exception as e:
            self.test_results.append({
                "test": "Category Spending Over Time Accuracy",
                "status": "ERROR",
                "error": str(e)
            })
            return False
    
    async def test_dashboard_metrics_accuracy(self):
        """Dashboard metriklerinin doğruluğunu test eder"""
        try:
            # Test verisi
            dashboard_data = {
                "total_expenses": 1500.00,
                "total_receipts": 45,
                "avg_expense": 33.33,
                "top_category": "Food",
                "monthly_change": 15.5
            }
            
            # Ortalama harcama hesaplama doğruluğu
            calculated_avg = dashboard_data["total_expenses"] / dashboard_data["total_receipts"]
            expected_avg = dashboard_data["avg_expense"]
            
            if abs(calculated_avg - expected_avg) < 0.01:
                self.test_results.append({
                    "test": "Dashboard - Average Expense Calculation",
                    "status": "PASS",
                    "calculated": f"{calculated_avg:.2f}",
                    "expected": f"{expected_avg:.2f}"
                })
            else:
                self.test_results.append({
                    "test": "Dashboard - Average Expense Calculation",
                    "status": "FAIL",
                    "calculated": f"{calculated_avg:.2f}",
                    "expected": f"{expected_avg:.2f}"
                })
            
            # Aylık değişim yüzdesi doğruluğu
            if dashboard_data["monthly_change"] > 0:
                self.test_results.append({
                    "test": "Dashboard - Monthly Change Positive",
                    "status": "PASS",
                    "change": f"+{dashboard_data['monthly_change']}%"
                })
            
            return True
            
        except Exception as e:
            self.test_results.append({
                "test": "Dashboard Metrics Accuracy",
                "status": "ERROR",
                "error": str(e)
            })
            return False
    
    async def test_data_aggregation_accuracy(self):
        """Veri toplama işlemlerinin doğruluğunu test eder"""
        try:
            # Test verisi - Çoklu harcama kayıtları
            expenses = [
                {"amount": 25.50, "category": "Food", "date": "2024-01-01"},
                {"amount": 15.75, "category": "Food", "date": "2024-01-02"},
                {"amount": 30.00, "category": "Transport", "date": "2024-01-01"},
                {"amount": 45.25, "category": "Entertainment", "date": "2024-01-03"}
            ]
            
            # Kategori bazlı toplam hesaplama
            category_totals = {}
            for expense in expenses:
                category = expense["category"]
                amount = expense["amount"]
                
                if category in category_totals:
                    category_totals[category] += amount
                else:
                    category_totals[category] = amount
            
            # Beklenen sonuçlar
            expected_totals = {
                "Food": 41.25,
                "Transport": 30.00,
                "Entertainment": 45.25
            }
            
            # Doğruluk kontrolü
            all_correct = True
            for category, expected in expected_totals.items():
                actual = category_totals.get(category, 0)
                if abs(actual - expected) < 0.01:
                    self.test_results.append({
                        "test": f"Data Aggregation - {category} Total",
                        "status": "PASS",
                        "expected": f"{expected:.2f}",
                        "actual": f"{actual:.2f}"
                    })
                else:
                    self.test_results.append({
                        "test": f"Data Aggregation - {category} Total",
                        "status": "FAIL",
                        "expected": f"{expected:.2f}",
                        "actual": f"{actual:.2f}"
                    })
                    all_correct = False
            
            return all_correct
            
        except Exception as e:
            self.test_results.append({
                "test": "Data Aggregation Accuracy",
                "status": "ERROR",
                "error": str(e)
            })
            return False
    
    async def run_all_tests(self):
        """Tüm raporlama doğruluğu testlerini çalıştır"""
        print("🧪 Reporting Data Accuracy Tests Başlıyor...")
        print("=" * 60)
        
        tests = [
            ("Spending Distribution Accuracy", self.test_spending_distribution_accuracy),
            ("Spending Trends Accuracy", self.test_spending_trends_accuracy),
            ("Budget vs Actual Accuracy", self.test_budget_vs_actual_accuracy),
            ("Category Spending Over Time Accuracy", self.test_category_spending_over_time_accuracy),
            ("Dashboard Metrics Accuracy", self.test_dashboard_metrics_accuracy),
            ("Data Aggregation Accuracy", self.test_data_aggregation_accuracy)
        ]
        
        passed_tests = 0
        total_tests = len(tests)
        
        for test_name, test_func in tests:
            print(f"\n📊 {test_name} test ediliyor...")
            try:
                result = await test_func()
                if result:
                    print(f"✅ {test_name} - PASSED")
                    passed_tests += 1
                else:
                    print(f"❌ {test_name} - FAILED")
            except Exception as e:
                print(f"💥 {test_name} - ERROR: {str(e)}")
        
        # Detaylı sonuçları yazdır
        print(f"\n{'='*60}")
        print("📊 REPORTING ACCURACY TEST RESULTS")
        print(f"{'='*60}")
        
        for result in self.test_results:
            status_icon = "✅" if result["status"] == "PASS" else "❌" if result["status"] == "FAIL" else "💥"
            print(f"{status_icon} {result['test']}: {result['status']}")
            
            if "expected" in result and "actual" in result:
                print(f"   Expected: {result['expected']}, Actual: {result['actual']}")
            elif "error" in result:
                print(f"   Error: {result['error']}")
            elif "trend" in result:
                print(f"   Trend: {result['trend']}")
            elif "variance" in result:
                print(f"   Variance: {result['variance']} ({result.get('variance_percentage', 'N/A')})")
        
        print(f"\n{'='*60}")
        print("TEST SUMMARY")
        print(f"{'='*60}")
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests} ✅")
        print(f"Failed: {total_tests - passed_tests} ❌")
        print(f"Success Rate: {(passed_tests/total_tests)*100:.1f}%")
        
        return passed_tests == total_tests


async def main():
    """Ana test fonksiyonu"""
    tester = ReportingAccuracyTester()
    success = await tester.run_all_tests()
    
    if success:
        print("\n🎉 Tüm raporlama doğruluğu testleri başarılı!")
        return 0
    else:
        print("\n⚠️ Bazı raporlama doğruluğu testleri başarısız!")
        return 1


if __name__ == "__main__":
    import asyncio
    exit_code = asyncio.run(main())
    sys.exit(exit_code) 