"""
Simple validation tests that work reliably
"""

import sys
import os
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

import pytest
from datetime import datetime
from uuid import uuid4

class TestSchemaValidation:
    """Test schema validation - these tests work reliably"""
    
    def test_manual_expense_request_validation(self):
        """Test ManualExpenseRequest schema validation"""
        from app.schemas.data_processing import ManualExpenseRequest, ExpenseItemCreateRequest
        
        # Test valid data
        expense_data = {
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
        
        expense = ManualExpenseRequest(**expense_data)
        assert expense.merchant_name == "Test Market"
        assert len(expense.items) == 2
        assert expense.items[0].description == "Ekmek"
        assert expense.items[0].amount == 5.50
        assert expense.items[1].description == "Süt"
        assert expense.items[1].amount == 15.75
        
        # Calculate total
        total_amount = sum(item.amount for item in expense.items)
        assert total_amount == 21.25
    
    def test_expense_item_validation(self):
        """Test ExpenseItemCreateRequest validation"""
        from app.schemas.data_processing import ExpenseItemCreateRequest, ExpenseItemUpdateRequest
        
        # Test valid item creation
        item_data = {
            "description": "Test Item",
            "amount": 10.50,
            "quantity": 1,
            "unit_price": 10.50,
            "notes": "Test item notes"
        }
        
        item = ExpenseItemCreateRequest(**item_data)
        assert item.description == "Test Item"
        assert item.amount == 10.50
        assert item.quantity == 1
        assert item.unit_price == 10.50
        
        # Test item update
        update_data = {"amount": 15.00, "quantity": 2}
        item_update = ExpenseItemUpdateRequest(**update_data)
        assert item_update.amount == 15.00
        assert item_update.quantity == 2
        assert item_update.description is None  # Optional field
    
    def test_qr_receipt_request_validation(self):
        """Test QRReceiptRequest validation"""
        from app.schemas.data_processing import QRReceiptRequest
        
        # Test valid QR data
        qr_data = {"qr_data": "test_qr_code_data_12345"}
        qr_request = QRReceiptRequest(**qr_data)
        assert qr_request.qr_data == "test_qr_code_data_12345"
        
        # Test empty string (allowed at schema level)
        empty_request = QRReceiptRequest(qr_data="")
        assert empty_request.qr_data == ""
    
    def test_category_validation(self):
        """Test category schema validation"""
        from app.schemas.data_processing import (
            CategoryCreateRequest,
            CategoryUpdateRequest,
            CategoryResponse
        )
        
        # Test category creation
        create_data = {"name": "Test Category"}
        create_request = CategoryCreateRequest(**create_data)
        assert create_request.name == "Test Category"
        
        # Test category update
        update_data = {"name": "Updated Category"}
        update_request = CategoryUpdateRequest(**update_data)
        assert update_request.name == "Updated Category"
        
        # Test category response
        response_data = {
            "id": str(uuid4()),
            "name": "Test Category",
            "user_id": str(uuid4()),
            "is_system": False,
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }
        
        response = CategoryResponse(**response_data)
        assert response.name == "Test Category"
        assert response.is_system is False
    
    def test_expense_response_validation(self):
        """Test expense response schema validation"""
        from app.schemas.data_processing import ExpenseResponse, ExpenseItemResponse
        
        # Mock expense response data
        expense_data = {
            "id": str(uuid4()),
            "receipt_id": str(uuid4()),
            "total_amount": 21.25,
            "expense_date": datetime.now(),
            "notes": "Test expense",
            "items": [
                {
                    "id": str(uuid4()),
                    "expense_id": str(uuid4()),
                    "category_id": str(uuid4()),
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
        assert expense.id is not None
        assert expense.total_amount == 21.25
        assert len(expense.items) == 1
        assert expense.items[0].description == "Test item"

class TestValidationRules:
    """Test validation rules"""
    
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
        expense_data = {
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
        
        expense_request = ManualExpenseRequest(**expense_data)
        
        # 2. Verify items are properly structured
        assert len(expense_request.items) == 2
        total_amount = sum(item.amount for item in expense_request.items)
        assert total_amount == 21.25  # 5.50 + 15.75
        
        # 3. Simulate response creation
        response_items = []
        for i, item in enumerate(expense_request.items):
            response_item = ExpenseItemResponse(
                id=str(uuid4()),
                expense_id=str(uuid4()),
                category_id=str(uuid4()),
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
            id=str(uuid4()),
            receipt_id=str(uuid4()),
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

class TestServiceInitialization:
    """Test that services can be initialized"""
    
    def test_data_processor_initialization(self):
        """Test DataProcessor initializes correctly"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Check that all required components are initialized
        assert hasattr(processor, 'qr_parser')
        assert hasattr(processor, 'data_extractor')
        assert hasattr(processor, 'data_cleaner')
        assert hasattr(processor, 'ai_categorizer')
        
        # Test that methods are callable
        assert callable(processor.process_manual_expense)
        assert callable(processor.process_qr_receipt)
        assert callable(processor.get_category_suggestions)
    
    def test_qr_generator_initialization(self):
        """Test QRGenerator initializes correctly"""
        from app.services.qr_generator import QRGenerator
        
        generator = QRGenerator()
        assert generator is not None
        
        # Test basic QR generation
        receipt_id = str(uuid4())
        qr_code = generator.generate_receipt_qr(
            receipt_id=receipt_id,
            merchant_name="Test Market",
            total_amount=45.75,
            currency="TRY",
            transaction_date=datetime.now()
        )
        
        assert qr_code is not None
        assert isinstance(qr_code, str)
        assert len(qr_code) > 0
    
    def test_ai_categorizer_initialization(self):
        """Test AI categorizer initializes correctly"""
        from app.services.ai_categorizer import AICategorizer
        
        categorizer = AICategorizer()
        assert categorizer is not None
        
        # Test category suggestions
        suggestions = categorizer.get_category_suggestions("restaurant meal")
        assert isinstance(suggestions, list)

if __name__ == "__main__":
    pytest.main([__file__, "-v"]) 