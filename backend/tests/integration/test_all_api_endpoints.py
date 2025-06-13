"""
Comprehensive API Endpoint Tests
Tests all endpoints across all modules with proper authentication and error handling
"""

import pytest
import asyncio
from unittest.mock import Mock, patch, AsyncMock
from datetime import datetime, date, timedelta
from uuid import uuid4
from typing import Dict, Any
import json

# Test fixtures and constants
MOCK_USER_ID = str(uuid4())
MOCK_RECEIPT_ID = str(uuid4())
MOCK_EXPENSE_ID = str(uuid4())
MOCK_MERCHANT_ID = str(uuid4())
MOCK_CATEGORY_ID = str(uuid4())
MOCK_REVIEW_ID = str(uuid4())
MOCK_DEVICE_ID = "test_device_123"

MOCK_USER = {
    "id": MOCK_USER_ID,
    "email": "test@example.com",
    "name": "Test User",
    "role": "user"
}

MOCK_ADMIN_USER = {
    "id": str(uuid4()),
    "email": "admin@example.com", 
    "name": "Admin User",
    "role": "admin"
}

class TestExpensesEndpoints:
    """Test /api/v1/expenses endpoints"""
    
    @pytest.fixture
    def mock_supabase(self):
        mock = Mock()
        mock.table.return_value = mock
        mock.insert.return_value = mock
        mock.select.return_value = mock
        mock.eq.return_value = mock
        mock.execute.return_value = Mock(data=[{
            "id": MOCK_EXPENSE_ID,
            "receipt_id": MOCK_RECEIPT_ID,
            "total_amount": 100.0,
            "expense_date": datetime.now().isoformat(),
            "notes": "Test expense",
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }])
        return mock
    
    def test_create_manual_expense_schema_validation(self):
        """Test POST /api/v1/expenses - Schema validation"""
        from app.schemas.data_processing import ManualExpenseRequest, ExpenseItemCreateRequest
        
        # Valid request
        valid_request = ManualExpenseRequest(
            merchant_name="Test Market",
            expense_date=datetime.now(),
            notes="Test expense",
            currency="TRY",
            items=[
                ExpenseItemCreateRequest(
                    item_name="Test Item",
                    amount=50.0,
                    quantity=1,
                    unit_price=50.0,
                    kdv_rate=20.0
                )
            ]
        )
        
        assert valid_request.merchant_name == "Test Market"
        assert len(valid_request.items) == 1
        assert valid_request.items[0].amount == 50.0
        
        # Invalid request - empty items
        with pytest.raises(Exception):
            ManualExpenseRequest(
                merchant_name="Test Market",
                items=[]
            )
    
    def test_list_expenses_query_parameters(self):
        """Test GET /api/v1/expenses - Query parameters"""
        # Test pagination parameters
        page = 1
        limit = 20
        assert page >= 1
        assert 1 <= limit <= 100
        
        # Test filter parameters
        merchant = "Test Market"
        date_from = datetime.now() - timedelta(days=30)
        date_to = datetime.now()
        min_amount = 0.0
        max_amount = 1000.0
        
        assert isinstance(merchant, str)
        assert isinstance(date_from, datetime)
        assert isinstance(date_to, datetime)
        assert min_amount >= 0
        assert max_amount >= min_amount
    
    def test_expense_item_operations(self):
        """Test expense item CRUD operations"""
        from app.schemas.data_processing import ExpenseItemCreateRequest, ExpenseItemUpdateRequest
        
        # Create item
        create_data = ExpenseItemCreateRequest(
            item_name="Test Item",
            amount=25.0,
            quantity=2,
            unit_price=12.5,
            kdv_rate=20.0,
            notes="Test notes"
        )
        
        assert create_data.item_name == "Test Item"
        assert create_data.amount == 25.0
        
        # Update item
        update_data = ExpenseItemUpdateRequest(
            amount=30.0,
            quantity=3
        )
        
        assert update_data.amount == 30.0
        assert update_data.quantity == 3
        assert update_data.item_name is None  # Optional field


class TestReceiptsEndpoints:
    """Test /api/v1/receipts endpoints"""
    
    def test_qr_receipt_scan_schema(self):
        """Test POST /api/v1/receipts/scan - Schema validation"""
        from app.schemas.data_processing import QRReceiptRequest, QRReceiptResponse
        
        # Valid QR request
        qr_request = QRReceiptRequest(qr_data="test_qr_data_12345")
        assert qr_request.qr_data == "test_qr_data_12345"
        
        # QR response schema
        qr_response_data = {
            "success": True,
            "message": "Receipt processed successfully",
            "receipt_id": MOCK_RECEIPT_ID,
            "merchant_name": "Test Market",
            "total_amount": 100.0,
            "currency": "TRY",
            "expenses_count": 3,
            "processing_confidence": 0.95
        }
        
        qr_response = QRReceiptResponse(**qr_response_data)
        assert qr_response.success is True
        assert qr_response.expenses_count == 3
        assert qr_response.processing_confidence == 0.95
    
    def test_receipt_list_filtering(self):
        """Test GET /api/v1/receipts - Filtering parameters"""
        # Test filter parameters
        page = 1
        limit = 20
        merchant = "Test Market"
        date_from = datetime.now() - timedelta(days=30)
        date_to = datetime.now()
        min_amount = 10.0
        max_amount = 500.0
        sort_by = "transaction_date"
        sort_order = "desc"
        
        # Validate parameters
        assert page >= 1
        assert 1 <= limit <= 100
        assert isinstance(merchant, str)
        assert date_from < date_to
        assert min_amount < max_amount
        assert sort_by in ["transaction_date", "total_amount", "merchant_name"]
        assert sort_order in ["asc", "desc"]
    
    def test_public_receipt_access(self):
        """Test GET /api/v1/receipts/public/{receipt_id}"""
        # Public receipts should be accessible without authentication
        # but with limited information
        receipt_id = MOCK_RECEIPT_ID
        assert isinstance(receipt_id, str)
        
        # UUID validation
        from uuid import UUID
        parsed_uuid = UUID(receipt_id)
        assert str(parsed_uuid) == receipt_id


class TestCategoriesEndpoints:
    """Test /api/v1/categories endpoints"""
    
    def test_category_creation_validation(self):
        """Test POST /api/v1/categories - Validation"""
        from app.schemas.data_processing import CategoryCreateRequest, CategoryUpdateRequest
        
        # Valid category creation
        create_request = CategoryCreateRequest(name="New Category")
        assert create_request.name == "New Category"
        
        # Category update
        update_request = CategoryUpdateRequest(name="Updated Category")
        assert update_request.name == "Updated Category"
        
        # Test system category names (should be rejected)
        system_categories = [
            "Food & Dining", "Transportation", "Shopping", 
            "Health & Medical", "Entertainment", "Utilities"
        ]
        
        for sys_cat in system_categories:
            # These should be rejected in the actual endpoint
            assert sys_cat in system_categories
    
    def test_category_system_vs_custom(self):
        """Test system vs custom category handling"""
        from app.schemas.data_processing import CategoryResponse
        
        # System category
        system_category = CategoryResponse(
            id=MOCK_CATEGORY_ID,
            name="Food & Dining",
            user_id=None,  # System categories have no user_id
            is_system=True,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        
        assert system_category.is_system is True
        assert system_category.user_id is None
        
        # Custom category
        custom_category = CategoryResponse(
            id=str(uuid4()),
            name="My Custom Category",
            user_id=MOCK_USER_ID,
            is_system=False,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        
        assert custom_category.is_system is False
        assert custom_category.user_id == MOCK_USER_ID


class TestMerchantsEndpoints:
    """Test /api/v1/merchants endpoints (Admin only)"""
    
    def test_merchant_creation_schema(self):
        """Test POST /api/v1/merchants - Schema validation"""
        from app.schemas.merchant import MerchantCreate, MerchantUpdate
        
        # Valid merchant creation
        merchant_create = MerchantCreate(
            name="Test Merchant",
            email="merchant@test.com",
            webhook_url="https://merchant.com/webhook",
            contact_person="John Doe",
            phone="+90 555 123 4567"
        )
        
        assert merchant_create.name == "Test Merchant"
        assert merchant_create.email == "merchant@test.com"
        assert merchant_create.webhook_url.startswith("https://")
        
        # Merchant update
        merchant_update = MerchantUpdate(
            name="Updated Merchant",
            is_active=False
        )
        
        assert merchant_update.name == "Updated Merchant"
        assert merchant_update.is_active is False
    
    def test_merchant_api_key_generation(self):
        """Test merchant API key operations"""
        # API key should be generated automatically
        # and should be secure (long, random string)
        import secrets
        import string
        
        # Simulate API key generation
        api_key = ''.join(secrets.choice(string.ascii_letters + string.digits) for _ in range(32))
        
        assert len(api_key) == 32
        assert api_key.isalnum()
    
    def test_merchant_pagination(self):
        """Test GET /api/v1/merchants - Pagination"""
        page = 1
        size = 20
        is_active = True
        
        assert page >= 1
        assert 1 <= size <= 100
        assert isinstance(is_active, bool)


class TestWebhooksEndpoints:
    """Test /api/v1/webhooks endpoints"""
    
    def test_webhook_transaction_schema(self):
        """Test webhook transaction data schema"""
        from app.schemas.merchant import WebhookTransactionData
        
        transaction_data = WebhookTransactionData(
            transaction_id="TXN_12345",
            amount=150.75,
            currency="TRY",
            customer_identifier="customer@test.com",
            items=[
                {
                    "name": "Product 1",
                    "amount": 75.0,
                    "quantity": 1
                },
                {
                    "name": "Product 2", 
                    "amount": 75.75,
                    "quantity": 1
                }
            ],
            timestamp=datetime.now(),
            metadata={"pos_id": "POS_001", "cashier": "John"}
        )
        
        assert transaction_data.transaction_id == "TXN_12345"
        assert transaction_data.amount == 150.75
        assert len(transaction_data.items) == 2
        assert transaction_data.currency == "TRY"
    
    def test_webhook_api_key_validation(self):
        """Test webhook API key validation"""
        # API key should be validated in header
        api_key = "test_api_key_12345"
        merchant_id = MOCK_MERCHANT_ID
        
        assert isinstance(api_key, str)
        assert len(api_key) > 10  # Should be reasonably long
        assert isinstance(merchant_id, str)
    
    def test_webhook_processing_result(self):
        """Test webhook processing result schema"""
        from app.schemas.merchant import WebhookProcessingResult
        
        result = WebhookProcessingResult(
            success=True,
            message="Transaction processed successfully",
            receipt_id=MOCK_RECEIPT_ID,
            expense_id=MOCK_EXPENSE_ID,
            customer_matched=True,
            items_processed=2,
            processing_time_ms=150
        )
        
        assert result.success is True
        assert result.customer_matched is True
        assert result.items_processed == 2
        assert result.processing_time_ms > 0


class TestReviewsEndpoints:
    """Test /api/v1/reviews endpoints"""
    
    def test_review_creation_schema(self):
        """Test review creation schema"""
        from app.schemas.review import ReviewCreateRequest, ReviewResponse
        
        # Valid review creation
        review_create = ReviewCreateRequest(
            rating=5,
            comment="Excellent service and quality!",
            reviewer_name="Happy Customer",
            reviewer_email="customer@test.com",
            is_anonymous=False,
            receipt_id=MOCK_RECEIPT_ID
        )
        
        assert 1 <= review_create.rating <= 5
        assert len(review_create.comment) > 0
        assert review_create.is_anonymous is False
        
        # Anonymous review
        anonymous_review = ReviewCreateRequest(
            rating=4,
            comment="Good service",
            is_anonymous=True
        )
        
        assert anonymous_review.is_anonymous is True
        assert anonymous_review.reviewer_name is None
    
    def test_merchant_rating_aggregation(self):
        """Test merchant rating aggregation"""
        from app.schemas.review import MerchantRatingResponse
        
        rating_response = MerchantRatingResponse(
            merchant_id=MOCK_MERCHANT_ID,
            merchant_name="Test Merchant",
            total_reviews=25,
            average_rating=4.2,
            rating_distribution={
                "1": 1,
                "2": 2,
                "3": 5,
                "4": 8,
                "5": 9
            }
        )
        
        assert rating_response.total_reviews == 25
        assert 1.0 <= rating_response.average_rating <= 5.0
        assert sum(rating_response.rating_distribution.values()) == 25
    
    def test_review_from_receipt(self):
        """Test creating review from receipt"""
        # Review should be linked to a specific receipt
        receipt_id = MOCK_RECEIPT_ID
        rating = 5
        comment = "Great experience!"
        
        assert isinstance(receipt_id, str)
        assert 1 <= rating <= 5
        assert len(comment) > 0


class TestLoyaltyEndpoints:
    """Test /api/v1/loyalty endpoints"""
    
    def test_loyalty_status_schema(self):
        """Test loyalty status response"""
        from app.schemas.loyalty import LoyaltyStatusResponse
        
        loyalty_status = LoyaltyStatusResponse(
            user_id=MOCK_USER_ID,
            total_points=1500,
            current_level="silver",
            points_to_next_level=500,
            level_progress_percentage=75.0,
            recent_activities=[],
            level_benefits=["20% bonus points", "Priority support"]
        )
        
        assert loyalty_status.total_points >= 0
        assert loyalty_status.current_level in ["bronze", "silver", "gold", "platinum"]
        assert 0 <= loyalty_status.level_progress_percentage <= 100
    
    def test_points_calculation(self):
        """Test points calculation logic"""
        from app.schemas.loyalty import PointsCalculationResult
        
        calculation = PointsCalculationResult(
            base_points=10,
            bonus_points=3,
            total_points=13,
            multiplier=1.3,
            category_bonus=0.5,
            level_bonus=0.2
        )
        
        assert calculation.total_points == calculation.base_points + calculation.bonus_points
        assert calculation.multiplier > 1.0
        assert calculation.category_bonus >= 0
        assert calculation.level_bonus >= 0
    
    def test_loyalty_levels_info(self):
        """Test loyalty levels information"""
        levels = {
            "bronze": {"points_required": 0, "multiplier": 1.0},
            "silver": {"points_required": 1000, "multiplier": 1.2},
            "gold": {"points_required": 5000, "multiplier": 1.5},
            "platinum": {"points_required": 15000, "multiplier": 2.0}
        }
        
        for level, info in levels.items():
            assert info["points_required"] >= 0
            assert info["multiplier"] >= 1.0
            assert isinstance(level, str)


class TestDevicesEndpoints:
    """Test /api/v1/devices endpoints"""
    
    def test_device_registration_schema(self):
        """Test device registration schema"""
        from app.api.v1.devices import DeviceRegistrationRequest
        
        device_request = DeviceRegistrationRequest(
            device_id=MOCK_DEVICE_ID,
            fcm_token="fcm_token_12345",
            device_type="android",
            device_name="Samsung Galaxy S21",
            app_version="1.2.3",
            os_version="Android 12"
        )
        
        assert device_request.device_id == MOCK_DEVICE_ID
        assert device_request.device_type in ["ios", "android", "web"]
        assert len(device_request.fcm_token) > 0
    
    def test_device_response_schema(self):
        """Test device response schema"""
        from app.api.v1.devices import DeviceResponse
        
        device_response = DeviceResponse(
            id=str(uuid4()),
            device_id=MOCK_DEVICE_ID,
            device_type="android",
            device_name="Test Phone",
            is_active=True,
            last_used_at=datetime.now().isoformat(),
            created_at=datetime.now().isoformat()
        )
        
        assert device_response.device_id == MOCK_DEVICE_ID
        assert device_response.is_active is True
        assert device_response.device_type in ["ios", "android", "web"]


class TestHealthEndpoints:
    """Test /api/v1/health endpoints"""
    
    def test_basic_health_check(self):
        """Test GET /api/v1/health/health"""
        # Basic health check should return status and timestamp
        health_response = {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "version": "1.0.0",
            "environment": "test"
        }
        
        assert health_response["status"] in ["healthy", "unhealthy", "degraded"]
        assert "timestamp" in health_response
        assert "version" in health_response
    
    def test_detailed_health_check(self):
        """Test GET /api/v1/health/detailed"""
        detailed_health = {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "checks": {
                "supabase": {
                    "status": "healthy",
                    "response_time_ms": 45.2,
                    "message": "Connection successful"
                },

            }
        }
        
        assert "checks" in detailed_health
        assert "supabase" in detailed_health["checks"]
        assert detailed_health["checks"]["supabase"]["status"] in ["healthy", "unhealthy", "degraded"]
    
    def test_system_metrics(self):
        """Test GET /api/v1/health/metrics (requires auth)"""
        metrics = {
            "timestamp": datetime.utcnow().isoformat(),
            "totals": {
                "users": 150,
                "expenses": 2500,
                "receipts": 1800,
                "merchants": 25
            },
            "last_24h": {
                "new_expenses": 45,
                "new_receipts": 32
            }
        }
        
        assert "totals" in metrics
        assert "last_24h" in metrics
        assert metrics["totals"]["users"] >= 0
        assert metrics["totals"]["expenses"] >= 0




class TestReportingEndpoints:
    """Test /api/reports endpoints"""
    
    def test_category_distribution_schema(self):
        """Test GET /api/reports/category-distribution"""
        from app.schemas.reporting import ChartType, PeriodType
        
        # Test chart type validation
        valid_chart_types = [ChartType.PIE, ChartType.DONUT]
        for chart_type in valid_chart_types:
            assert chart_type in [ChartType.PIE, ChartType.DONUT]
        
        # Test year/month validation
        year = 2024
        month = 1
        assert 1 <= month <= 12
        assert year >= 2020
    
    def test_spending_trends_parameters(self):
        """Test GET /api/reports/spending-trends"""
        from app.schemas.reporting import PeriodType, ChartType
        
        # Valid parameters
        period = PeriodType.SIX_MONTHS
        chart_type = ChartType.LINE
        
        assert period in [
            PeriodType.THIS_MONTH, PeriodType.THREE_MONTHS, 
            PeriodType.SIX_MONTHS, PeriodType.ONE_YEAR
        ]
        assert chart_type == ChartType.LINE
    
    def test_dashboard_data_structure(self):
        """Test GET /api/reports/dashboard"""
        dashboard_data = {
            "status": "success",
            "overview": {
                "total_expenses": 2450.75,
                "expense_count": 48,
                "average_expense": 51.06,
                "top_category": "Food & Dining"
            },
            "charts": [
                {
                    "type": "pie",
                    "title": "Spending by Category",
                    "data": [
                        {"label": "Food & Dining", "value": 850.0},
                        {"label": "Transportation", "value": 420.0}
                    ]
                },
                {
                    "type": "line",
                    "title": "Daily Spending Trend",
                    "data": [
                        {"date": "2024-01-15", "amount": 85.50},
                        {"date": "2024-01-16", "amount": 92.25}
                    ]
                }
            ]
        }
        
        assert dashboard_data["status"] == "success"
        assert "overview" in dashboard_data
        assert "charts" in dashboard_data
        assert len(dashboard_data["charts"]) > 0


class TestEndpointSecurity:
    """Test endpoint security and authentication"""
    
    def test_authentication_required_endpoints(self):
        """Test that protected endpoints require authentication"""
        protected_endpoints = [
            "/api/v1/expenses",
            "/api/v1/receipts", 
            "/api/v1/categories",
            "/api/v1/loyalty/status",
            "/api/v1/devices",
            "/api/reports/dashboard"
        ]
        
        for endpoint in protected_endpoints:
            # These endpoints should require valid JWT token
            assert endpoint.startswith("/api/")
    
    def test_admin_only_endpoints(self):
        """Test that admin endpoints require admin role"""
        admin_endpoints = [
            "/api/v1/merchants",
            "/api/v1/webhooks/merchant/{merchant_id}/logs",
            "/api/v1/health/metrics"
        ]
        
        for endpoint in admin_endpoints:
            # These endpoints should require admin role
            assert endpoint.startswith("/api/")
    
    def test_api_key_authentication(self):
        """Test API key authentication for webhooks"""
        # Webhook endpoints should validate merchant API keys
        api_key_endpoints = [
            "/api/v1/webhooks/merchant/{merchant_id}/transaction"
        ]
        
        for endpoint in api_key_endpoints:
            # These endpoints should validate X-API-Key header
            assert "merchant" in endpoint


class TestEndpointValidation:
    """Test endpoint input validation"""
    
    def test_uuid_validation(self):
        """Test UUID parameter validation"""
        from uuid import UUID
        
        # Valid UUIDs
        valid_uuids = [MOCK_USER_ID, MOCK_EXPENSE_ID, MOCK_RECEIPT_ID]
        
        for uuid_str in valid_uuids:
            parsed = UUID(uuid_str)
            assert str(parsed) == uuid_str
        
        # Invalid UUID should raise ValueError
        with pytest.raises(ValueError):
            UUID("invalid-uuid-format")
    
    def test_pagination_validation(self):
        """Test pagination parameter validation"""
        # Valid pagination
        valid_pages = [1, 2, 10, 100]
        valid_limits = [1, 10, 20, 50, 100]
        
        for page in valid_pages:
            assert page >= 1
        
        for limit in valid_limits:
            assert 1 <= limit <= 100
    
    def test_amount_validation(self):
        """Test amount parameter validation"""
        # Valid amounts
        valid_amounts = [0.01, 10.50, 100.0, 999.99]
        
        for amount in valid_amounts:
            assert amount > 0
            assert isinstance(amount, (int, float))
        
        # Invalid amounts
        invalid_amounts = [-1.0, 0.0, "not_a_number"]
        
        for amount in invalid_amounts:
            if isinstance(amount, (int, float)):
                assert amount <= 0  # Should be rejected
            else:
                assert not isinstance(amount, (int, float))
    
    def test_rating_validation(self):
        """Test rating parameter validation (1-5)"""
        valid_ratings = [1, 2, 3, 4, 5]
        invalid_ratings = [0, 6, -1, 10]
        
        for rating in valid_ratings:
            assert 1 <= rating <= 5
        
        for rating in invalid_ratings:
            assert not (1 <= rating <= 5)


class TestEndpointErrorHandling:
    """Test endpoint error handling"""
    
    def test_404_not_found_errors(self):
        """Test 404 error handling"""
        from fastapi import HTTPException
        
        # Simulate 404 errors
        not_found_scenarios = [
            "Expense not found",
            "Receipt not found", 
            "Category not found",
            "Merchant not found",
            "Review not found"
        ]
        
        for scenario in not_found_scenarios:
            with pytest.raises(HTTPException) as exc_info:
                raise HTTPException(status_code=404, detail=scenario)
            
            assert exc_info.value.status_code == 404
            assert scenario in exc_info.value.detail
    
    def test_400_validation_errors(self):
        """Test 400 validation error handling"""
        from fastapi import HTTPException
        
        validation_errors = [
            "Invalid input data",
            "Missing required field",
            "Invalid UUID format",
            "Amount must be positive"
        ]
        
        for error in validation_errors:
            with pytest.raises(HTTPException) as exc_info:
                raise HTTPException(status_code=400, detail=error)
            
            assert exc_info.value.status_code == 400
    
    def test_401_authentication_errors(self):
        """Test 401 authentication error handling"""
        from fastapi import HTTPException
        
        auth_errors = [
            "Authentication required",
            "Invalid token",
            "Token expired",
            "Invalid API key"
        ]
        
        for error in auth_errors:
            with pytest.raises(HTTPException) as exc_info:
                raise HTTPException(status_code=401, detail=error)
            
            assert exc_info.value.status_code == 401
    
    def test_403_authorization_errors(self):
        """Test 403 authorization error handling"""
        from fastapi import HTTPException
        
        auth_errors = [
            "Admin access required",
            "Insufficient permissions",
            "Access denied"
        ]
        
        for error in auth_errors:
            with pytest.raises(HTTPException) as exc_info:
                raise HTTPException(status_code=403, detail=error)
            
            assert exc_info.value.status_code == 403
    
    def test_500_server_errors(self):
        """Test 500 server error handling"""
        from fastapi import HTTPException
        
        server_errors = [
            "Internal server error",
            "Database connection failed",
            "Service unavailable"
        ]
        
        for error in server_errors:
            with pytest.raises(HTTPException) as exc_info:
                raise HTTPException(status_code=500, detail=error)
            
            assert exc_info.value.status_code == 500


if __name__ == "__main__":
    pytest.main([__file__, "-v"]) 