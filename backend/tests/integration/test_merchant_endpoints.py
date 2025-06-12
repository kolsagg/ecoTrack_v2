import pytest
from fastapi.testclient import TestClient
from unittest.mock import Mock, patch, AsyncMock
from uuid import uuid4
from datetime import datetime, timezone

from main import app
from app.auth.dependencies import get_current_user, get_current_active_user, require_admin
from app.api.v1.webhooks import validate_merchant_api_key


class TestMerchantEndpoints:
    """Test merchant management endpoints"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.client = TestClient(app)
        self.admin_user = {
            "id": str(uuid4()),
            "email": "admin@example.com",
            "app_metadata": {"role": "admin"}
        }
        self.regular_user = {
            "id": str(uuid4()),
            "email": "user@example.com",
            "app_metadata": {},
            "user_metadata": {}
        }
    
    def test_create_merchant_success(self):
        """Test successful merchant creation"""
        # Override dependencies
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        # Mock the service method directly
        with patch('app.services.merchant_service.MerchantService.create_merchant') as mock_create:
            mock_merchant_data = {
                "id": str(uuid4()),
                "name": "Test Restaurant",
                "business_type": "restaurant",
                "api_key": "mk_test123",
                "webhook_url": "https://restaurant.com/webhook",
                "is_active": True,
                "contact_email": "test@restaurant.com",
                "contact_phone": "+905551234567",
                "address": "Istanbul, Turkey",
                "tax_number": None,
                "settings": {},
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            mock_create.return_value = mock_merchant_data
            
            # Test data
            merchant_data = {
                "name": "Test Restaurant",
                "business_type": "restaurant",
                "contact_email": "test@restaurant.com",
                "contact_phone": "+905551234567",
                "address": "Istanbul, Turkey",
                "webhook_url": "https://restaurant.com/webhook"
            }
            
            # Make request
            response = self.client.post("/api/v1/merchants/", json=merchant_data)
            
            # Assertions
            assert response.status_code == 201
            data = response.json()
            assert data["name"] == "Test Restaurant"
            assert data["business_type"] == "restaurant"
            assert data["is_active"] is True
            assert "api_key" in data
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_create_merchant_unauthorized(self):
        """Test merchant creation without admin privileges"""
        from fastapi import HTTPException
        
        def mock_require_admin():
            raise HTTPException(status_code=403, detail="Admin privileges required")
        
        app.dependency_overrides[require_admin] = mock_require_admin
        
        merchant_data = {
            "name": "Test Restaurant",
            "business_type": "restaurant"
        }
        
        response = self.client.post("/api/v1/merchants/", json=merchant_data)
        
        assert response.status_code == 403
        assert "Admin privileges required" in response.json()["detail"]
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_create_merchant_no_auth(self):
        """Test merchant creation without authentication"""
        merchant_data = {
            "name": "Test Restaurant",
            "business_type": "restaurant"
        }
        
        response = self.client.post("/api/v1/merchants/", json=merchant_data)
        
        assert response.status_code == 403
        assert "Not authenticated" in response.json()["detail"]
    
    def test_list_merchants_success(self):
        """Test listing merchants"""
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        # Mock the service method directly
        with patch('app.services.merchant_service.MerchantService.list_merchants') as mock_list:
            mock_merchants = [
                {
                    "id": str(uuid4()),
                    "name": "Merchant 1",
                    "business_type": "restaurant",
                    "api_key": "mk_test123",
                    "webhook_url": None,
                    "is_active": True,
                    "contact_email": None,
                    "contact_phone": None,
                    "address": None,
                    "tax_number": None,
                    "settings": {},
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
            ]
            mock_list.return_value = (mock_merchants, 1)  # merchants, total
            
            # Make request
            response = self.client.get("/api/v1/merchants/")
            
            # Assertions
            assert response.status_code == 200
            data = response.json()
            assert "merchants" in data
            assert "total" in data
            assert "page" in data
            assert "size" in data
            assert "has_next" in data
            assert len(data["merchants"]) == 1
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_get_merchant_by_id_success(self):
        """Test getting merchant by ID"""
        merchant_id = uuid4()
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        # Mock the service method directly
        with patch('app.services.merchant_service.MerchantService.get_merchant_by_id') as mock_get:
            mock_merchant_data = {
                "id": str(merchant_id),
                "name": "Test Merchant",
                "business_type": "retail",
                "api_key": "mk_test123",
                "webhook_url": None,
                "is_active": True,
                "contact_email": None,
                "contact_phone": None,
                "address": None,
                "tax_number": None,
                "settings": {},
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            mock_get.return_value = mock_merchant_data
            
            # Make request
            response = self.client.get(f"/api/v1/merchants/{merchant_id}")
            
            # Assertions
            assert response.status_code == 200
            data = response.json()
            assert data["id"] == str(merchant_id)
            assert data["name"] == "Test Merchant"
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_get_merchant_not_found(self):
        """Test getting non-existent merchant"""
        merchant_id = uuid4()
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        with patch('app.db.supabase_client.get_supabase_client') as mock_get_supabase:
            # Mock empty Supabase response
            mock_supabase = Mock()
            mock_response = Mock()
            mock_response.data = []
            mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response
            mock_get_supabase.return_value = mock_supabase
            
            # Make request
            response = self.client.get(f"/api/v1/merchants/{merchant_id}")
            
            # Assertions
            assert response.status_code == 404
            assert "Merchant not found" in response.json()["detail"]
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_merchant_validation_errors(self):
        """Test merchant creation with validation errors"""
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        # Invalid email
        invalid_data = {
            "name": "Test Merchant",
            "contact_email": "invalid-email"
        }
        
        response = self.client.post("/api/v1/merchants/", json=invalid_data)
        
        assert response.status_code == 422  # Validation error
        
        # Clean up
        app.dependency_overrides.clear()


class TestWebhookEndpoints:
    """Test webhook endpoints"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.client = TestClient(app)
        self.merchant_id = uuid4()
        self.webhook_headers = {"X-API-Key": "test-api-key"}
        self.admin_user = {
            "id": str(uuid4()),
            "email": "admin@example.com",
            "app_metadata": {"role": "admin"}
        }
    
    def create_sample_transaction_data(self):
        """Create sample transaction data for testing"""
        return {
            "transaction_id": "TXN-123456",
            "total_amount": 150.75,
            "currency": "TRY",
            "transaction_date": datetime.now(timezone.utc).isoformat(),
            "customer_info": {
                "email": "customer@example.com",
                "phone": "+905551234567",
                "card_last_four": "1234"
            },
            "items": [
                {
                    "description": "Coffee",
                    "quantity": 2,
                    "unit_price": 25.50,
                    "total_price": 51.00,
                    "category": "beverages"
                },
                {
                    "description": "Sandwich",
                    "quantity": 1,
                    "unit_price": 99.75,
                    "total_price": 99.75,
                    "category": "food"
                }
            ],
            "payment_method": "credit_card",
            "location": "Istanbul Store",
            "notes": "Customer pickup order"
        }
    
    def test_webhook_transaction_missing_api_key(self):
        """Test webhook transaction without API key"""
        transaction_data = self.create_sample_transaction_data()
        
        response = self.client.post(
            f"/api/v1/webhooks/merchant/{self.merchant_id}/transaction",
            json=transaction_data
        )
        
        assert response.status_code == 422
        # API key validation error comes as 422 from FastAPI
    
    def test_webhook_transaction_invalid_data(self):
        """Test webhook transaction with invalid data"""
        # Mock API key validation
        def mock_validate_api_key():
            return {"merchant_id": str(self.merchant_id), "is_active": True}
        
        app.dependency_overrides[validate_merchant_api_key] = mock_validate_api_key
        
        invalid_data = {
            "transaction_id": "TXN-123",
            # Missing required fields
        }
        
        response = self.client.post(
            f"/api/v1/webhooks/merchant/{self.merchant_id}/transaction",
            json=invalid_data,
            headers=self.webhook_headers
        )
        
        assert response.status_code == 422
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_webhook_transaction_merchant_not_found(self):
        """Test webhook transaction with non-existent merchant"""
        from fastapi import HTTPException
        
        def mock_validate_api_key():
            raise HTTPException(status_code=404, detail="Merchant not found")
        
        app.dependency_overrides[validate_merchant_api_key] = mock_validate_api_key
        
        transaction_data = self.create_sample_transaction_data()
        
        response = self.client.post(
            f"/api/v1/webhooks/merchant/{self.merchant_id}/transaction",
            json=transaction_data,
            headers=self.webhook_headers
        )
        
        assert response.status_code == 404
        assert "Merchant not found" in response.json()["detail"]
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_test_transaction_endpoint(self):
        """Test the test transaction endpoint"""
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        test_data = {
            "transaction_data": self.create_sample_transaction_data(),
            "test_mode": True
        }
        
        # Mock webhook service method
        with patch('app.services.webhook_service.WebhookService.process_merchant_transaction') as mock_process:
            mock_process.return_value = {
                "success": True,
                "message": "Test transaction processed successfully",
                "transaction_id": "TXN-123456",
                "processing_time_ms": 150
            }
            
            response = self.client.post(
                f"/api/v1/webhooks/merchant/{self.merchant_id}/test-transaction",
                json=test_data
            )
            
            assert response.status_code == 200
            data = response.json()
            assert data["success"] is True
            assert "Test transaction processed successfully" in data["message"]
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_get_webhook_logs(self):
        """Test getting webhook logs"""
        app.dependency_overrides[require_admin] = lambda: self.admin_user
        
        # Mock webhook service method
        with patch('app.services.webhook_service.WebhookService.get_webhook_logs') as mock_get_logs:
            mock_logs = [
                {
                    "id": str(uuid4()),
                    "merchant_id": str(self.merchant_id),
                    "transaction_id": "TXN-123",
                    "status": "success",
                    "response_code": 200,
                    "error_message": None,
                    "processing_time_ms": 150,
                    "retry_count": 0,
                    "created_at": datetime.now().isoformat()
                }
            ]
            mock_get_logs.return_value = (mock_logs, 1)  # logs, total
            
            response = self.client.get(f"/api/v1/webhooks/merchant/{self.merchant_id}/logs")
            
            assert response.status_code == 200
            data = response.json()
            assert "logs" in data
            assert "total" in data
            assert len(data["logs"]) == 1
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_webhook_logs_unauthorized(self):
        """Test getting webhook logs without admin privileges"""
        response = self.client.get(f"/api/v1/webhooks/merchant/{self.merchant_id}/logs")
        
        assert response.status_code == 403  # Forbidden due to missing auth
        # Without proper auth, the endpoint returns 403


class TestWebhookValidation:
    """Test webhook data validation"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.client = TestClient(app)
        self.merchant_id = uuid4()
    
    def test_transaction_item_validation(self):
        """Test transaction item validation"""
        # Mock API key validation
        def mock_validate_api_key():
            return {"merchant_id": str(self.merchant_id), "is_active": True}
        
        app.dependency_overrides[validate_merchant_api_key] = mock_validate_api_key
        
        # Test with invalid quantity (negative)
        invalid_item_data = {
            "transaction_id": "TXN-123",
            "total_amount": 100.0,
            "currency": "TRY",
            "transaction_date": datetime.now(timezone.utc).isoformat(),
            "customer_info": {"email": "test@example.com"},
            "items": [
                {
                    "description": "Test Item",
                    "quantity": -1,  # Invalid: negative quantity
                    "unit_price": 100.0,
                    "total_price": 100.0
                }
            ]
        }
        
        response = self.client.post(
            f"/api/v1/webhooks/merchant/{self.merchant_id}/transaction",
            json=invalid_item_data,
            headers={"X-API-Key": "test-key"}
        )
        
        assert response.status_code == 422
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_customer_info_validation(self):
        """Test customer info validation"""
        # Mock API key validation
        def mock_validate_api_key():
            return {"merchant_id": str(self.merchant_id), "is_active": True}
        
        app.dependency_overrides[validate_merchant_api_key] = mock_validate_api_key
        
        # Test with invalid card_last_four (wrong length)
        invalid_customer_data = {
            "transaction_id": "TXN-123",
            "total_amount": 100.0,
            "currency": "TRY",
            "transaction_date": datetime.now(timezone.utc).isoformat(),
            "customer_info": {
                "email": "test@example.com",
                "card_last_four": "12345"  # Invalid: too long
            },
            "items": [
                {
                    "description": "Test Item",
                    "quantity": 1,
                    "unit_price": 100.0,
                    "total_price": 100.0
                }
            ]
        }
        
        response = self.client.post(
            f"/api/v1/webhooks/merchant/{self.merchant_id}/transaction",
            json=invalid_customer_data,
            headers={"X-API-Key": "test-key"}
        )
        
        assert response.status_code == 422
        
        # Clean up
        app.dependency_overrides.clear()
    
    def test_currency_validation(self):
        """Test currency validation"""
        # Mock API key validation
        def mock_validate_api_key():
            return {"merchant_id": str(self.merchant_id), "is_active": True}
        
        app.dependency_overrides[validate_merchant_api_key] = mock_validate_api_key
        
        # Test with invalid currency
        invalid_currency_data = {
            "transaction_id": "TXN-123",
            "total_amount": 100.0,
            "currency": "INVALID",  # Invalid currency
            "transaction_date": datetime.now(timezone.utc).isoformat(),
            "customer_info": {"email": "test@example.com"},
            "items": [
                {
                    "description": "Test Item",
                    "quantity": 1,
                    "unit_price": 100.0,
                    "total_price": 100.0
                }
            ]
        }
        
        response = self.client.post(
            f"/api/v1/webhooks/merchant/{self.merchant_id}/transaction",
            json=invalid_currency_data,
            headers={"X-API-Key": "test-key"}
        )
        
        assert response.status_code == 422
        
        # Clean up
        app.dependency_overrides.clear()


class TestMerchantEndpointIntegration:
    """Integration tests for merchant endpoints"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.client = TestClient(app)
    
    def test_api_documentation_includes_merchant_endpoints(self):
        """Test that merchant endpoints are included in API documentation"""
        response = self.client.get("/openapi.json")
        
        assert response.status_code == 200
        openapi_spec = response.json()
        
        # Check for merchant endpoints
        paths = openapi_spec.get("paths", {})
        merchant_endpoints = [
            "/api/v1/merchants/",
            "/api/v1/merchants/{merchant_id}",
            "/api/v1/merchants/{merchant_id}/regenerate-api-key"
        ]
        
        for endpoint in merchant_endpoints:
            assert endpoint in paths, f"Merchant endpoint {endpoint} not found in API documentation"
        
        # Check for webhook endpoints
        webhook_endpoints = [
            "/api/v1/webhooks/merchant/{merchant_id}/transaction",
            "/api/v1/webhooks/merchant/{merchant_id}/test-transaction",
            "/api/v1/webhooks/merchant/{merchant_id}/logs"
        ]
        
        for endpoint in webhook_endpoints:
            assert endpoint in paths, f"Webhook endpoint {endpoint} not found in API documentation"
    
    def test_endpoint_response_schemas(self):
        """Test that endpoints have proper response schemas"""
        response = self.client.get("/openapi.json")
        openapi_spec = response.json()
        
        # Check merchant creation endpoint has proper response schema
        merchant_create_path = openapi_spec["paths"]["/api/v1/merchants/"]["post"]
        assert "201" in merchant_create_path["responses"]
        
        # Check webhook transaction endpoint has proper request schema
        webhook_path = openapi_spec["paths"]["/api/v1/webhooks/merchant/{merchant_id}/transaction"]["post"]
        assert "requestBody" in webhook_path
        assert "application/json" in webhook_path["requestBody"]["content"]


if __name__ == "__main__":
    # Run tests if script is executed directly
    pytest.main([__file__, "-v"]) 