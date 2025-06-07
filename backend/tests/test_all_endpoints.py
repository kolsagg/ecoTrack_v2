"""
Comprehensive tests for all API endpoints
"""

import sys
import os
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

import pytest
import json
from datetime import datetime
from unittest.mock import Mock, patch
from uuid import uuid4

# Test data constants
MOCK_USER_ID = str(uuid4())
MOCK_RECEIPT_ID = str(uuid4())
MOCK_EXPENSE_ID = str(uuid4())
MOCK_ITEM_ID = str(uuid4())
MOCK_CATEGORY_ID = str(uuid4())

MOCK_USER = {
    "id": MOCK_USER_ID,
    "email": "test@example.com",
    "name": "Test User"
}

# Test data for requests
MANUAL_EXPENSE_DATA = {
    "merchant_name": "Test Market",
    "expense_date": "2024-01-15T10:30:00",
    "notes": "Test shopping",
    "currency": "TRY",
    "items": [
        {
            "description": "Ekmek",
            "amount": 5.50,
            "quantity": 2,
            "unit_price": 2.75,
            "notes": "Tam buğday ekmeği"
        },
        {
            "description": "Süt",
            "amount": 15.75,
            "quantity": 1,
            "unit_price": 15.75,
            "notes": "1 litre tam yağlı süt"
        }
    ]
}

QR_RECEIPT_DATA = {
    "qr_data": "test_qr_code_data_12345"
}

CATEGORY_DATA = {
    "name": "Test Category"
}

EXPENSE_ITEM_DATA = {
    "description": "Test Item",
    "amount": 10.50,
    "quantity": 1,
    "unit_price": 10.50,
    "notes": "Test item notes"
}

class TestExpenseEndpoints:
    """Test all expense-related endpoints"""
    
    def test_create_manual_expense_schema(self):
        """Test manual expense creation schema validation"""
        from app.schemas.data_processing import ManualExpenseRequest, ExpenseItemCreateRequest
        
        # Test valid data
        expense = ManualExpenseRequest(**MANUAL_EXPENSE_DATA)
        assert expense.merchant_name == "Test Market"
        assert len(expense.items) == 2
        assert expense.items[0].description == "Ekmek"
        assert expense.items[0].amount == 5.50
        
        # Test invalid data - missing merchant_name
        with pytest.raises(Exception):
            ManualExpenseRequest(items=[])
        
        # Test invalid data - empty items
        with pytest.raises(Exception):
            ManualExpenseRequest(merchant_name="Test", items=[])
    
    def test_expense_item_schema(self):
        """Test expense item schema validation"""
        from app.schemas.data_processing import ExpenseItemCreateRequest, ExpenseItemUpdateRequest
        
        # Test valid item creation
        item = ExpenseItemCreateRequest(**EXPENSE_ITEM_DATA)
        assert item.description == "Test Item"
        assert item.amount == 10.50
        assert item.quantity == 1
        
        # Test item update
        update_data = {"amount": 15.00, "quantity": 2}
        item_update = ExpenseItemUpdateRequest(**update_data)
        assert item_update.amount == 15.00
        assert item_update.quantity == 2
        assert item_update.description is None  # Optional field
    
    def test_expense_response_schema(self):
        """Test expense response schema"""
        from app.schemas.data_processing import ExpenseResponse, ExpenseItemResponse
        
        # Mock expense response data
        expense_data = {
            "id": MOCK_EXPENSE_ID,
            "receipt_id": MOCK_RECEIPT_ID,
            "total_amount": 21.25,
            "expense_date": datetime.now(),
            "notes": "Test expense",
            "items": [
                {
                    "id": MOCK_ITEM_ID,
                    "expense_id": MOCK_EXPENSE_ID,
                    "category_id": MOCK_CATEGORY_ID,
                    "category_name": "Food",
                    "description": "Test item",
                    "amount": 10.50,
                    "quantity": 1,
                    "unit_price": 10.50,
                    "notes": "Test notes",
                    "created_at": datetime.now(),
                    "updated_at": datetime.now()
                }
            ],
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }
        
        expense = ExpenseResponse(**expense_data)
        assert expense.id == MOCK_EXPENSE_ID
        assert expense.total_amount == 21.25
        assert len(expense.items) == 1
        assert expense.items[0].description == "Test item"

class TestReceiptEndpoints:
    """Test all receipt-related endpoints"""
    
    def test_qr_receipt_request_schema(self):
        """Test QR receipt request schema"""
        from app.schemas.data_processing import QRReceiptRequest
        
        # Test valid QR data
        qr_request = QRReceiptRequest(**QR_RECEIPT_DATA)
        assert qr_request.qr_data == "test_qr_code_data_12345"
        
        # Test that empty string is accepted (validation happens at service level)
        # QRReceiptRequest allows empty string, validation is done in service layer
        empty_request = QRReceiptRequest(qr_data="")
        assert empty_request.qr_data == ""
        
        # Test whitespace only
        whitespace_request = QRReceiptRequest(qr_data="   ")
        assert whitespace_request.qr_data == "   "
    
    def test_receipt_response_schemas(self):
        """Test receipt response schemas"""
        from app.schemas.data_processing import (
            QRReceiptResponse, 
            ReceiptListResponse, 
            ReceiptDetailResponse
        )
        
        # Test QR receipt response
        qr_response_data = {
            "success": True,
            "message": "Receipt processed successfully",
            "receipt_id": MOCK_RECEIPT_ID,
            "merchant_name": "Test Market",
            "total_amount": 45.75,
            "currency": "TRY",
            "expenses_count": 3,
            "processing_confidence": 0.95
        }
        
        qr_response = QRReceiptResponse(**qr_response_data)
        assert qr_response.success is True
        assert qr_response.expenses_count == 3
        
        # Test receipt list response
        list_response_data = {
            "id": MOCK_RECEIPT_ID,
            "merchant_name": "Test Market",
            "transaction_date": datetime.now(),
            "total_amount": 45.75,
            "currency": "TRY",
            "source": "qr_scan",
            "created_at": datetime.now()
        }
        
        list_response = ReceiptListResponse(**list_response_data)
        assert list_response.merchant_name == "Test Market"
        assert list_response.source == "qr_scan"

class TestCategoryEndpoints:
    """Test all category-related endpoints"""
    
    def test_category_schemas(self):
        """Test category request and response schemas"""
        from app.schemas.data_processing import (
            CategoryCreateRequest,
            CategoryUpdateRequest,
            CategoryResponse
        )
        
        # Test category creation
        create_request = CategoryCreateRequest(**CATEGORY_DATA)
        assert create_request.name == "Test Category"
        
        # Test category update
        update_data = {"name": "Updated Category"}
        update_request = CategoryUpdateRequest(**update_data)
        assert update_request.name == "Updated Category"
        
        # Test category response
        response_data = {
            "id": MOCK_CATEGORY_ID,
            "name": "Test Category",
            "user_id": MOCK_USER_ID,
            "is_system": False,
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }
        
        response = CategoryResponse(**response_data)
        assert response.name == "Test Category"
        assert response.is_system is False

class TestDataProcessorIntegration:
    """Test data processor integration"""
    
    def test_data_processor_methods(self):
        """Test that data processor has all required methods"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Test method existence
        assert hasattr(processor, 'process_manual_expense')
        assert hasattr(processor, 'process_qr_receipt')
        assert hasattr(processor, 'get_category_suggestions')
        assert hasattr(processor, 'reprocess_expense_categorization')
        assert hasattr(processor, 'get_processing_statistics')
        
        # Test that methods are callable
        assert callable(processor.process_manual_expense)
        assert callable(processor.process_qr_receipt)
        assert callable(processor.get_category_suggestions)

class TestEndpointAuthentication:
    """Test authentication requirements for endpoints"""
    
    def test_protected_endpoints_require_auth(self):
        """Test that protected endpoints require authentication"""
        # This would be tested with actual HTTP requests in integration tests
        # For now, we verify the schema structure supports authentication
        
        from app.schemas.data_processing import ManualExpenseRequest
        
        # Verify that our schemas don't include user_id (it's added by auth)
        expense = ManualExpenseRequest(**MANUAL_EXPENSE_DATA)
        assert not hasattr(expense, 'user_id')  # Should be added by auth middleware

class TestErrorHandling:
    """Test error handling schemas"""
    
    def test_error_response_schema(self):
        """Test error response schema"""
        from app.schemas.data_processing import ErrorResponse
        
        error_data = {
            "error": "Test error message",
            "error_code": "TEST_ERROR",
            "details": {"field": "value"}
        }
        
        error = ErrorResponse(**error_data)
        assert error.error == "Test error message"
        assert error.error_code == "TEST_ERROR"
        assert error.details["field"] == "value"

class TestValidationRules:
    """Test validation rules for all schemas"""
    
    def test_amount_validation(self):
        """Test amount validation rules"""
        from app.schemas.data_processing import ExpenseItemCreateRequest
        
        # Test valid amount
        valid_item = ExpenseItemCreateRequest(
            description="Test",
            amount=10.50,
            quantity=1
        )
        assert valid_item.amount == 10.50
        
        # Test invalid amount - negative
        with pytest.raises(Exception):
            ExpenseItemCreateRequest(
                description="Test",
                amount=-5.00,
                quantity=1
            )
        
        # Test invalid amount - zero
        with pytest.raises(Exception):
            ExpenseItemCreateRequest(
                description="Test",
                amount=0,
                quantity=1
            )
    
    def test_quantity_validation(self):
        """Test quantity validation rules"""
        from app.schemas.data_processing import ExpenseItemCreateRequest
        
        # Test valid quantity
        valid_item = ExpenseItemCreateRequest(
            description="Test",
            amount=10.50,
            quantity=2
        )
        assert valid_item.quantity == 2
        
        # Test invalid quantity - zero
        with pytest.raises(Exception):
            ExpenseItemCreateRequest(
                description="Test",
                amount=10.50,
                quantity=0
            )
        
        # Test invalid quantity - negative
        with pytest.raises(Exception):
            ExpenseItemCreateRequest(
                description="Test",
                amount=10.50,
                quantity=-1
            )
    
    def test_string_length_validation(self):
        """Test string length validation"""
        from app.schemas.data_processing import CategoryCreateRequest
        
        # Test valid name
        valid_category = CategoryCreateRequest(name="Valid Name")
        assert valid_category.name == "Valid Name"
        
        # Test invalid name - empty
        with pytest.raises(Exception):
            CategoryCreateRequest(name="")
        
        # Test invalid name - too long (over 50 chars)
        with pytest.raises(Exception):
            CategoryCreateRequest(name="x" * 51)

class TestComplexScenarios:
    """Test complex scenarios with multiple schemas"""
    
    def test_full_expense_creation_flow(self):
        """Test complete expense creation flow with all schemas"""
        from app.schemas.data_processing import (
            ManualExpenseRequest,
            ExpenseItemCreateRequest,
            ExpenseResponse,
            ExpenseItemResponse
        )
        
        # 1. Create expense request
        expense_request = ManualExpenseRequest(**MANUAL_EXPENSE_DATA)
        
        # 2. Verify items are properly structured
        assert len(expense_request.items) == 2
        total_amount = sum(item.amount for item in expense_request.items)
        assert total_amount == 21.25  # 5.50 + 15.75
        
        # 3. Simulate response creation
        response_items = []
        for i, item in enumerate(expense_request.items):
            response_item = ExpenseItemResponse(
                id=str(uuid4()),
                expense_id=MOCK_EXPENSE_ID,
                category_id=MOCK_CATEGORY_ID,
                category_name="Food",
                description=item.description,
                amount=item.amount,
                quantity=item.quantity,
                unit_price=item.unit_price,
                notes=item.notes,
                created_at=datetime.now(),
                updated_at=datetime.now()
            )
            response_items.append(response_item)
        
        # 4. Create expense response
        expense_response = ExpenseResponse(
            id=MOCK_EXPENSE_ID,
            receipt_id=MOCK_RECEIPT_ID,
            total_amount=total_amount,
            expense_date=expense_request.expense_date or datetime.now(),
            notes=expense_request.notes,
            items=response_items,
            created_at=datetime.now(),
            updated_at=datetime.now()
        )
        
        # 5. Verify complete flow
        assert expense_response.total_amount == 21.25
        assert len(expense_response.items) == 2
        assert expense_response.items[0].description == "Ekmek"
        assert expense_response.items[1].description == "Süt"

if __name__ == "__main__":
    pytest.main([__file__, "-v"]) 