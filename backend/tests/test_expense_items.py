import pytest

def test_expense_items_schema():
    """Test that the expense items schema is properly structured"""
    from app.schemas.data_processing import ExpenseItemCreateRequest, ManualExpenseRequest
    
    # Test ExpenseItemCreateRequest
    item_data = {
        "description": "Test item",
        "amount": 10.50,
        "quantity": 1,
        "unit_price": 10.50,
        "notes": "Test notes"
    }
    
    item = ExpenseItemCreateRequest(**item_data)
    assert item.description == "Test item"
    assert item.amount == 10.50
    assert item.quantity == 1
    
    # Test ManualExpenseRequest with items
    expense_data = {
        "merchant_name": "Test Market",
        "items": [item_data]
    }
    
    expense = ManualExpenseRequest(**expense_data)
    assert expense.merchant_name == "Test Market"
    assert len(expense.items) == 1
    assert expense.items[0].description == "Test item"

def test_data_processor_structure():
    """Test that data processor returns the expected structure"""
    from app.services.data_processor import DataProcessor
    
    processor = DataProcessor()
    
    # Test that the processor has the expected methods
    assert hasattr(processor, 'process_manual_expense')
    assert hasattr(processor, 'process_qr_receipt')
    assert hasattr(processor, 'get_category_suggestions')

if __name__ == "__main__":
    pytest.main([__file__]) 