"""
Performance ve Load Testing
API endpoint'lerin performans testleri
"""

import asyncio
import time
import statistics
import sys
import os
from concurrent.futures import ThreadPoolExecutor
import threading
from typing import List, Dict, Any

# Path setup
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))

from fastapi.testclient import TestClient
from main import app
from tests.utils.test_helpers import TestDataManager, TestReporter


class PerformanceTestRunner:
    """Performance test runner"""
    
    def __init__(self):
        self.client = TestClient(app)
        self.test_data_manager = TestDataManager()
        self.reporter = TestReporter()
        self.results = []
        
    def measure_response_time(self, method: str, url: str, **kwargs) -> Dict[str, Any]:
        """Tek bir request'in response time'ını ölç"""
        start_time = time.time()
        
        try:
            if method.upper() == "GET":
                response = self.client.get(url, **kwargs)
            elif method.upper() == "POST":
                response = self.client.post(url, **kwargs)
            elif method.upper() == "PUT":
                response = self.client.put(url, **kwargs)
            elif method.upper() == "DELETE":
                response = self.client.delete(url, **kwargs)
            else:
                raise ValueError(f"Unsupported method: {method}")
                
            end_time = time.time()
            response_time = (end_time - start_time) * 1000  # milliseconds
            
            return {
                "success": True,
                "response_time": response_time,
                "status_code": response.status_code,
                "response_size": len(response.content) if response.content else 0
            }
            
        except Exception as e:
            end_time = time.time()
            response_time = (end_time - start_time) * 1000
            
            return {
                "success": False,
                "response_time": response_time,
                "error": str(e),
                "status_code": None,
                "response_size": 0
            }
    
    def load_test_endpoint(self, method: str, url: str, concurrent_users: int = 10, 
                          requests_per_user: int = 5, **kwargs) -> Dict[str, Any]:
        """Endpoint'e load test uygula"""
        print(f"🔥 Load testing {method} {url} with {concurrent_users} users, {requests_per_user} requests each")
        
        all_results = []
        
        def user_simulation():
            """Tek bir kullanıcının request'lerini simüle et"""
            user_results = []
            for _ in range(requests_per_user):
                result = self.measure_response_time(method, url, **kwargs)
                user_results.append(result)
                time.sleep(0.1)  # Kısa bekleme
            return user_results
        
        # Concurrent users ile test et
        with ThreadPoolExecutor(max_workers=concurrent_users) as executor:
            futures = [executor.submit(user_simulation) for _ in range(concurrent_users)]
            
            for future in futures:
                try:
                    user_results = future.result(timeout=30)
                    all_results.extend(user_results)
                except Exception as e:
                    print(f"❌ User simulation failed: {e}")
        
        # Sonuçları analiz et
        successful_requests = [r for r in all_results if r["success"]]
        failed_requests = [r for r in all_results if not r["success"]]
        
        if successful_requests:
            response_times = [r["response_time"] for r in successful_requests]
            
            analysis = {
                "endpoint": f"{method} {url}",
                "total_requests": len(all_results),
                "successful_requests": len(successful_requests),
                "failed_requests": len(failed_requests),
                "success_rate": len(successful_requests) / len(all_results) * 100,
                "avg_response_time": statistics.mean(response_times),
                "min_response_time": min(response_times),
                "max_response_time": max(response_times),
                "median_response_time": statistics.median(response_times),
                "p95_response_time": sorted(response_times)[int(len(response_times) * 0.95)] if len(response_times) > 20 else max(response_times),
                "requests_per_second": len(successful_requests) / (max(response_times) / 1000) if response_times else 0
            }
        else:
            analysis = {
                "endpoint": f"{method} {url}",
                "total_requests": len(all_results),
                "successful_requests": 0,
                "failed_requests": len(failed_requests),
                "success_rate": 0,
                "error": "All requests failed"
            }
        
        return analysis
    
    def test_api_endpoints_performance(self):
        """Ana API endpoint'lerin performansını test et"""
        print("🚀 API ENDPOINT PERFORMANCE TESTING")
        print("=" * 60)
        
        # Test edilecek endpoint'ler
        endpoints_to_test = [
            {"method": "GET", "url": "/", "name": "Health Check"},
            {"method": "GET", "url": "/api/categories", "name": "Categories List"},
            {"method": "GET", "url": "/api/receipts", "name": "Receipts List"},
            {"method": "GET", "url": "/api/expenses", "name": "Expenses List"},
            {"method": "GET", "url": "/api/reports/dashboard", "name": "Dashboard Data"},
            {"method": "GET", "url": "/api/reports/spending-distribution", "name": "Spending Distribution"},
            {"method": "GET", "url": "/api/loyalty/status", "name": "Loyalty Status"}
        ]
        
        performance_results = []
        
        for endpoint in endpoints_to_test:
            print(f"\n📊 Testing {endpoint['name']}...")
            
            # Tek request performansı
            single_result = self.measure_response_time(
                endpoint["method"], 
                endpoint["url"]
            )
            
            if single_result["success"]:
                print(f"   Single Request: {single_result['response_time']:.2f}ms")
                
                # Load test (sadece başarılı endpoint'ler için)
                if single_result["response_time"] < 5000:  # 5 saniyeden az ise
                    load_result = self.load_test_endpoint(
                        endpoint["method"], 
                        endpoint["url"],
                        concurrent_users=5,
                        requests_per_user=3
                    )
                    performance_results.append(load_result)
                else:
                    print(f"   ⚠️ Skipping load test (too slow: {single_result['response_time']:.2f}ms)")
            else:
                print(f"   ❌ Failed: {single_result.get('error', 'Unknown error')}")
        
        return performance_results
    
    def test_database_query_performance(self):
        """Database query performansını test et"""
        print("\n💾 DATABASE QUERY PERFORMANCE TESTING")
        print("=" * 60)
        
        # Reporting endpoint'leri (database-heavy)
        db_heavy_endpoints = [
            {"method": "GET", "url": "/api/reports/spending-trends", "name": "Spending Trends"},
            {"method": "GET", "url": "/api/reports/category-spending-over-time", "name": "Category Spending Over Time"},
            {"method": "GET", "url": "/api/reports/budget-vs-actual", "name": "Budget vs Actual"}
        ]
        
        db_performance_results = []
        
        for endpoint in db_heavy_endpoints:
            print(f"\n🔍 Testing {endpoint['name']}...")
            
            # Farklı parametre kombinasyonları ile test et
            test_params = [
                {},  # Default parameters
                {"start_date": "2024-01-01", "end_date": "2024-12-31"},  # Date range
                {"period": "monthly"},  # Aggregation period
            ]
            
            for i, params in enumerate(test_params):
                print(f"   Test {i+1}: {params}")
                
                result = self.measure_response_time(
                    endpoint["method"], 
                    endpoint["url"],
                    params=params
                )
                
                if result["success"]:
                    print(f"   ✅ Response time: {result['response_time']:.2f}ms")
                    print(f"   📦 Response size: {result['response_size']} bytes")
                    
                    db_performance_results.append({
                        "endpoint": endpoint["name"],
                        "params": params,
                        "response_time": result["response_time"],
                        "response_size": result["response_size"]
                    })
                else:
                    print(f"   ❌ Failed: {result.get('error', 'Unknown error')}")
        
        return db_performance_results
    
    def test_concurrent_user_simulation(self):
        """Gerçekçi kullanıcı davranışını simüle et"""
        print("\n👥 CONCURRENT USER SIMULATION")
        print("=" * 60)
        
        def realistic_user_session():
            """Gerçekçi bir kullanıcı oturumunu simüle et"""
            session_results = []
            
            # Tipik kullanıcı akışı
            user_flow = [
                {"method": "GET", "url": "/api/categories", "wait": 0.5},
                {"method": "GET", "url": "/api/receipts", "wait": 1.0},
                {"method": "GET", "url": "/api/expenses", "wait": 0.8},
                {"method": "GET", "url": "/api/reports/dashboard", "wait": 1.2},
                {"method": "GET", "url": "/api/loyalty/status", "wait": 0.3}
            ]
            
            for step in user_flow:
                result = self.measure_response_time(step["method"], step["url"])
                session_results.append(result)
                time.sleep(step["wait"])  # Kullanıcı düşünme süresi
            
            return session_results
        
        # 3 concurrent user ile test et
        concurrent_users = 3
        print(f"🎭 Simulating {concurrent_users} concurrent users...")
        
        with ThreadPoolExecutor(max_workers=concurrent_users) as executor:
            futures = [executor.submit(realistic_user_session) for _ in range(concurrent_users)]
            
            all_session_results = []
            for i, future in enumerate(futures):
                try:
                    session_results = future.result(timeout=60)
                    all_session_results.extend(session_results)
                    print(f"   ✅ User {i+1} session completed")
                except Exception as e:
                    print(f"   ❌ User {i+1} session failed: {e}")
        
        # Session analizi
        successful_requests = [r for r in all_session_results if r["success"]]
        if successful_requests:
            avg_response_time = statistics.mean([r["response_time"] for r in successful_requests])
            print(f"   📊 Average response time across all users: {avg_response_time:.2f}ms")
            print(f"   ✅ Success rate: {len(successful_requests)/len(all_session_results)*100:.1f}%")
        
        return all_session_results
    
    def generate_performance_report(self, results: List[Dict[str, Any]]):
        """Performance test sonuçlarının raporunu oluştur"""
        print(f"\n{'='*80}")
        print("📈 PERFORMANCE TEST REPORT")
        print(f"{'='*80}")
        
        if not results:
            print("❌ No performance results to report")
            return
        
        # Genel istatistikler
        total_tests = len(results)
        successful_tests = len([r for r in results if r.get("success_rate", 0) > 80])
        
        print(f"📊 Total Performance Tests: {total_tests}")
        print(f"✅ Successful Tests (>80% success rate): {successful_tests}")
        print(f"📈 Overall Success Rate: {successful_tests/total_tests*100:.1f}%")
        
        # En yavaş endpoint'ler
        print(f"\n🐌 SLOWEST ENDPOINTS:")
        sorted_by_response_time = sorted(
            [r for r in results if "avg_response_time" in r], 
            key=lambda x: x["avg_response_time"], 
            reverse=True
        )
        
        for i, result in enumerate(sorted_by_response_time[:5]):
            print(f"   {i+1}. {result['endpoint']}: {result['avg_response_time']:.2f}ms")
        
        # Performance kriterleri
        print(f"\n⚡ PERFORMANCE CRITERIA:")
        fast_endpoints = [r for r in results if r.get("avg_response_time", float('inf')) < 200]
        medium_endpoints = [r for r in results if 200 <= r.get("avg_response_time", float('inf')) < 1000]
        slow_endpoints = [r for r in results if r.get("avg_response_time", float('inf')) >= 1000]
        
        print(f"   🟢 Fast (<200ms): {len(fast_endpoints)} endpoints")
        print(f"   🟡 Medium (200-1000ms): {len(medium_endpoints)} endpoints")
        print(f"   🔴 Slow (>1000ms): {len(slow_endpoints)} endpoints")
        
        # Öneriler
        print(f"\n💡 PERFORMANCE RECOMMENDATIONS:")
        if slow_endpoints:
            print("   🔧 Consider optimizing slow endpoints:")
            for endpoint in slow_endpoints[:3]:
                print(f"      - {endpoint['endpoint']}")
        
        if any(r.get("success_rate", 100) < 95 for r in results):
            print("   🛠️ Some endpoints have low success rates - investigate error handling")
        
        print("   📊 Consider implementing caching for frequently accessed data")
        print("   🗄️ Review database query optimization for reporting endpoints")


def main():
    """Ana test fonksiyonu"""
    print("🚀 PERFORMANCE & LOAD TESTING BAŞLIYOR...")
    print("=" * 80)
    
    runner = PerformanceTestRunner()
    
    try:
        # API endpoint performance testleri
        api_results = runner.test_api_endpoints_performance()
        
        # Database query performance testleri
        db_results = runner.test_database_query_performance()
        
        # Concurrent user simulation
        user_simulation_results = runner.test_concurrent_user_simulation()
        
        # Tüm sonuçları birleştir
        all_results = api_results + db_results
        
        # Rapor oluştur
        runner.generate_performance_report(all_results)
        
        print(f"\n✅ Performance testing completed successfully!")
        print(f"📊 Total tests run: {len(all_results)}")
        
    except Exception as e:
        print(f"❌ Performance testing failed: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main() 