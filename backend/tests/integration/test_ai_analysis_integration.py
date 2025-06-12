"""
AI Analysis Integration Tests
Test AI analysis endpoints with real service integration
"""

import pytest
import asyncio
from datetime import datetime, timedelta
from tests.utils.test_helpers import TestClient, AuthHelper, DataFactory


class TestAIAnalysisIntegration:
    """Test AI Analysis endpoints"""
    
    def __init__(self):
        self.client = TestClient()
        self.auth = AuthHelper()
        self.data_factory = DataFactory()
    
    async def test_ai_health_endpoint(self):
        """Test AI service health endpoint"""
        print("🔍 Testing AI health endpoint...")
        
        response = await self.client.get("/api/ai/health")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] == "healthy"
        assert "ai_model_available" in data
        assert "services" in data
        assert data["services"]["spending_analysis"] is True
        
        print("✅ AI health endpoint working")
        return True
    
    async def test_analytics_summary_unauthorized(self):
        """Test analytics summary without authentication"""
        print("🔍 Testing analytics summary unauthorized access...")
        
        response = await self.client.get("/api/ai/analytics/summary")
        
        assert response.status_code == 401
        print("✅ Analytics summary properly requires authentication")
        return True
    
    async def test_analytics_summary_with_auth(self):
        """Test analytics summary with authentication"""
        print("🔍 Testing analytics summary with authentication...")
        
        # Get admin client
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/analytics/summary")
        
        # Should work even with no data (returns empty structure)
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] == "success"
        assert "overview" in data
        assert "category_breakdown" in data
        assert "daily_spending" in data
        assert "top_merchants" in data
        
        print("✅ Analytics summary working with authentication")
        return True
    
    async def test_savings_suggestions_with_auth(self):
        """Test savings suggestions with authentication"""
        print("🔍 Testing savings suggestions with authentication...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/suggestions/savings")
        
        # Should work even with no data
        assert response.status_code == 200
        data = response.json()
        
        # With no data, should return no_data status or empty suggestions
        assert data["status"] in ["success", "no_data"]
        assert "suggestions" in data
        
        print("✅ Savings suggestions working")
        return True
    
    async def test_budget_suggestions_with_auth(self):
        """Test budget suggestions with authentication"""
        print("🔍 Testing budget suggestions with authentication...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/suggestions/budget")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] in ["success", "no_data"]
        assert "budget_recommendations" in data
        
        print("✅ Budget suggestions working")
        return True
    
    async def test_recurring_expenses_with_auth(self):
        """Test recurring expenses analysis with authentication"""
        print("🔍 Testing recurring expenses analysis...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/analysis/recurring-expenses?days=90")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] == "success"
        assert "recurring_expenses" in data
        assert "total_patterns" in data
        assert data["analysis_period"] == "90 days"
        
        print("✅ Recurring expenses analysis working")
        return True
    
    async def test_price_changes_with_auth(self):
        """Test price changes tracking with authentication"""
        print("🔍 Testing price changes tracking...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/analysis/price-changes?days=180")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] == "success"
        assert "price_changes" in data
        assert "total_changes" in data
        assert data["analysis_period"] == "180 days"
        
        print("✅ Price changes tracking working")
        return True
    
    async def test_product_expiration_with_auth(self):
        """Test product expiration tracking with authentication"""
        print("🔍 Testing product expiration tracking...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/analysis/product-expiration")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] == "success"
        assert "expiring_products" in data
        assert "total_alerts" in data
        
        print("✅ Product expiration tracking working")
        return True
    
    async def test_spending_patterns_with_auth(self):
        """Test spending patterns analysis with authentication"""
        print("🔍 Testing spending patterns analysis...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/analysis/spending-patterns?days=60")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] in ["success", "no_data"]
        
        print("✅ Spending patterns analysis working")
        return True
    
    async def test_advanced_analysis_with_auth(self):
        """Test comprehensive advanced analysis"""
        print("🔍 Testing advanced analysis (comprehensive)...")
        
        admin_client = await self.auth.get_admin_client()
        
        response = await admin_client.get("/api/ai/analysis/advanced")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] == "success"
        assert "recurring_expenses" in data
        assert "price_changes" in data
        assert "expiration_alerts" in data
        
        print("✅ Advanced analysis working")
        return True
    
    async def test_spending_patterns_post_request(self):
        """Test spending patterns POST request with body"""
        print("🔍 Testing spending patterns POST request...")
        
        admin_client = await self.auth.get_admin_client()
        
        request_body = {
            "analysis_period": "30_days",
            "include_ai_insights": True
        }
        
        response = await admin_client.post("/api/ai/analysis/spending-patterns", json=request_body)
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["status"] in ["success", "no_data"]
        
        print("✅ Spending patterns POST request working")
        return True


async def run_ai_analysis_tests():
    """Run all AI analysis integration tests"""
    print("🤖 AI ANALYSIS INTEGRATION TESTS BAŞLIYOR...")
    print("=" * 60)
    
    test_suite = TestAIAnalysisIntegration()
    
    tests = [
        test_suite.test_ai_health_endpoint,
        test_suite.test_analytics_summary_unauthorized,
        test_suite.test_analytics_summary_with_auth,
        test_suite.test_savings_suggestions_with_auth,
        test_suite.test_budget_suggestions_with_auth,
        test_suite.test_recurring_expenses_with_auth,
        test_suite.test_price_changes_with_auth,
        test_suite.test_product_expiration_with_auth,
        test_suite.test_spending_patterns_with_auth,
        test_suite.test_advanced_analysis_with_auth,
        test_suite.test_spending_patterns_post_request
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            await test()
            passed += 1
        except Exception as e:
            print(f"❌ {test.__name__} failed: {str(e)}")
            failed += 1
    
    print("=" * 60)
    print(f"🎯 AI Analysis Tests: {passed} passed, {failed} failed")
    
    if failed == 0:
        print("🎉 Tüm AI Analysis testleri başarılı!")
    
    return failed == 0


if __name__ == "__main__":
    asyncio.run(run_ai_analysis_tests()) 