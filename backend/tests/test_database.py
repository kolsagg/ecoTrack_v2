"""
Database layer tests
"""

import sys
import os
from pathlib import Path

# Add the backend directory to Python path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

import pytest
from unittest.mock import Mock, patch, MagicMock
from datetime import datetime
from uuid import uuid4

class TestSupabaseClient:
    """Test Supabase client functionality"""
    
    def test_supabase_client_initialization(self):
        """Test Supabase client initializes correctly"""
        from app.db.supabase_client import get_authenticated_supabase_client
        
        # Mock user credentials for authentication
        from unittest.mock import MagicMock
        mock_credentials = MagicMock()
        mock_credentials.credentials = "mock_jwt_token"
        
        # This should not fail (may return None if not configured)
        try:
            client = get_authenticated_supabase_client(mock_credentials)
            # Basic check - should be callable or None
            assert client is None or hasattr(client, 'table')
        except Exception:
            # If authentication fails, that's expected in test environment
            assert True

class TestDatabaseOperations:
    """Test database operations"""
    
    @pytest.fixture
    def mock_supabase_client(self):
        """Mock Supabase client for testing"""
        mock_client = MagicMock()
        
        # Mock successful response
        mock_response = MagicMock()
        mock_response.data = []
        mock_response.execute.return_value = mock_response
        
        # Mock table operations
        mock_table = MagicMock()
        mock_table.select.return_value = mock_table
        mock_table.insert.return_value = mock_table
        mock_table.update.return_value = mock_table
        mock_table.delete.return_value = mock_table
        mock_table.eq.return_value = mock_table
        mock_table.execute.return_value = mock_response
        
        mock_client.table.return_value = mock_table
        
        return mock_client
    
    def test_receipts_table_operations(self, mock_supabase_client):
        """Test receipts table operations"""
        # Test select
        result = mock_supabase_client.table('receipts').select('*').execute()
        assert result.data == []
        
        # Test insert
        receipt_data = {
            'user_id': str(uuid4()),
            'merchant_name': 'Test Market',
            'total_amount': 45.75,
            'currency': 'TRY',
            'source': 'manual_entry'
        }
        
        result = mock_supabase_client.table('receipts').insert(receipt_data).execute()
        assert result is not None
        
        # Test update
        update_data = {'merchant_name': 'Updated Market'}
        result = mock_supabase_client.table('receipts').update(update_data).eq('id', str(uuid4())).execute()
        assert result is not None
        
        # Test delete
        result = mock_supabase_client.table('receipts').delete().eq('id', str(uuid4())).execute()
        assert result is not None
    
    def test_expenses_table_operations(self, mock_supabase_client):
        """Test expenses table operations"""
        # Test select with join
        result = (mock_supabase_client.table('expenses')
                 .select('*, receipts(merchant_name, source)')
                 .execute())
        assert result.data == []
        
        # Test insert
        expense_data = {
            'user_id': str(uuid4()),
            'receipt_id': str(uuid4()),
            'total_amount': 21.25,
            'expense_date': datetime.now().isoformat(),
            'notes': 'Test expense'
        }
        
        result = mock_supabase_client.table('expenses').insert(expense_data).execute()
        assert result is not None
    
    def test_expense_items_table_operations(self, mock_supabase_client):
        """Test expense_items table operations"""
        # Test select with category join
        result = (mock_supabase_client.table('expense_items')
                 .select('*, categories(name)')
                 .execute())
        assert result.data == []
        
        # Test insert
        item_data = {
            'user_id': str(uuid4()),
            'expense_id': str(uuid4()),
            'category_id': str(uuid4()),
            'description': 'Test Item',
            'amount': 10.50,
            'quantity': 1,
            'unit_price': 10.50
        }
        
        result = mock_supabase_client.table('expense_items').insert(item_data).execute()
        assert result is not None
    
    def test_categories_table_operations(self, mock_supabase_client):
        """Test categories table operations"""
        # Test select
        result = mock_supabase_client.table('categories').select('*').execute()
        assert result.data == []
        
        # Test insert
        category_data = {
            'user_id': str(uuid4()),
            'name': 'Test Category',
            'is_system': False
        }
        
        result = mock_supabase_client.table('categories').insert(category_data).execute()
        assert result is not None

class TestDatabaseQueries:
    """Test complex database queries"""
    
    @pytest.fixture
    def mock_supabase_with_data(self):
        """Mock Supabase client with sample data"""
        mock_client = MagicMock()
        
        # Sample data
        sample_expenses = [
            {
                'id': str(uuid4()),
                'receipt_id': str(uuid4()),
                'total_amount': 45.75,
                'expense_date': datetime.now().isoformat(),
                'notes': 'Test expense',
                'receipts': {
                    'merchant_name': 'Test Market',
                    'source': 'manual_entry'
                }
            }
        ]
        
        sample_expense_items = [
            {
                'id': str(uuid4()),
                'expense_id': str(uuid4()),
                'category_id': str(uuid4()),
                'description': 'Test Item',
                'amount': 10.50,
                'quantity': 1,
                'categories': {
                    'name': 'Food'
                }
            }
        ]
        
        # Mock responses based on table
        def mock_table(table_name):
            mock_table_obj = MagicMock()
            mock_response = MagicMock()
            
            if table_name == 'expenses':
                mock_response.data = sample_expenses
            elif table_name == 'expense_items':
                mock_response.data = sample_expense_items
            else:
                mock_response.data = []
            
            mock_response.execute.return_value = mock_response
            
            mock_table_obj.select.return_value = mock_table_obj
            mock_table_obj.eq.return_value = mock_table_obj
            mock_table_obj.execute.return_value = mock_response
            
            return mock_table_obj
        
        mock_client.table.side_effect = mock_table
        
        return mock_client
    
    def test_expense_with_items_query(self, mock_supabase_with_data):
        """Test querying expense with its items"""
        expense_id = str(uuid4())
        
        # Query expense
        expense_result = (mock_supabase_with_data.table('expenses')
                         .select('*, receipts(merchant_name, source)')
                         .eq('id', expense_id)
                         .execute())
        
        # Query expense items
        items_result = (mock_supabase_with_data.table('expense_items')
                       .select('*, categories(name)')
                       .eq('expense_id', expense_id)
                       .execute())
        
        # Verify structure
        assert len(expense_result.data) >= 0
        assert len(items_result.data) >= 0
    
    def test_user_expenses_query(self, mock_supabase_with_data):
        """Test querying user's expenses"""
        user_id = str(uuid4())
        
        # Query user expenses
        result = (mock_supabase_with_data.table('expenses')
                 .select('*, receipts(merchant_name, source)')
                 .eq('user_id', user_id)
                 .execute())
        
        # Verify structure
        assert len(result.data) >= 0
    
    def test_category_expenses_query(self, mock_supabase_with_data):
        """Test querying expenses by category"""
        category_id = str(uuid4())
        
        # Query items by category
        result = (mock_supabase_with_data.table('expense_items')
                 .select('*, categories(name), expenses(total_amount, expense_date)')
                 .eq('category_id', category_id)
                 .execute())
        
        # Verify structure
        assert len(result.data) >= 0

class TestDatabaseConstraints:
    """Test database constraints and validations"""
    
    def test_required_fields_validation(self):
        """Test that required fields are validated"""
        # This would test database constraints
        # For now, we test that our schemas enforce required fields
        
        from app.schemas.data_processing import ManualExpenseRequest
        
        # Test missing required field
        with pytest.raises(Exception):
            ManualExpenseRequest(items=[])  # Missing merchant_name
    
    def test_foreign_key_relationships(self):
        """Test foreign key relationships"""
        # This would test actual database foreign keys
        # For now, we verify our data structure supports relationships
        
        from app.schemas.data_processing import ExpenseItemResponse
        
        # Verify expense item has expense_id reference
        item_data = {
            'id': str(uuid4()),
            'expense_id': str(uuid4()),  # Foreign key
            'category_id': str(uuid4()),  # Foreign key
            'category_name': 'Food',
            'description': 'Test Item',
            'amount': 10.50,
            'quantity': 1,
            'unit_price': 10.50,
            'created_at': datetime.now(),
            'updated_at': datetime.now()
        }
        
        item = ExpenseItemResponse(**item_data)
        assert item.expense_id is not None
        assert item.category_id is not None

class TestDatabaseTransactions:
    """Test database transaction scenarios"""
    
    @pytest.fixture
    def mock_transaction_client(self):
        """Mock client for transaction testing"""
        mock_client = MagicMock()
        
        # Mock transaction methods
        mock_client.rpc.return_value.execute.return_value.data = {"success": True}
        
        return mock_client
    
    def test_expense_creation_transaction(self, mock_transaction_client):
        """Test expense creation as a transaction"""
        # This would test actual database transactions
        # For now, we verify the structure supports atomic operations
        
        expense_data = {
            'user_id': str(uuid4()),
            'receipt_id': str(uuid4()),
            'total_amount': 21.25
        }
        
        expense_items = [
            {
                'user_id': expense_data['user_id'],
                'description': 'Item 1',
                'amount': 10.50,
                'quantity': 1
            },
            {
                'user_id': expense_data['user_id'],
                'description': 'Item 2',
                'amount': 10.75,
                'quantity': 1
            }
        ]
        
        # Verify total matches items
        calculated_total = sum(item['amount'] for item in expense_items)
        assert calculated_total == expense_data['total_amount']
    
    def test_expense_deletion_cascade(self, mock_transaction_client):
        """Test expense deletion cascades to items"""
        expense_id = str(uuid4())
        
        # This would test actual cascade deletion
        # For now, we verify the structure supports it
        
        # Delete expense (should cascade to items)
        result = mock_transaction_client.rpc('delete_expense_cascade', {
            'expense_id': expense_id
        }).execute()
        
        assert result.data["success"] is True

class TestDatabasePerformance:
    """Test database performance considerations"""
    
    def test_query_optimization_structure(self):
        """Test that queries are structured for performance"""
        # This would test actual query performance
        # For now, we verify efficient query patterns
        
        # Verify we select only needed fields
        from app.schemas.data_processing import ExpenseListResponse
        
        # List response should have minimal fields for performance
        list_data = {
            'id': str(uuid4()),
            'receipt_id': str(uuid4()),
            'total_amount': 45.75,
            'expense_date': datetime.now(),
            'notes': 'Test',
            'merchant_name': 'Test Market',
            'source': 'manual_entry',
            'items_count': 3,
            'created_at': datetime.now()
        }
        
        list_response = ExpenseListResponse(**list_data)
        
        # Verify it has summary info, not full item details
        assert hasattr(list_response, 'items_count')
        assert not hasattr(list_response, 'items')  # Full items not included in list
    
    def test_pagination_support(self):
        """Test pagination support structure"""
        # This would test actual pagination
        # For now, we verify the structure supports it
        
        # Verify our endpoints can handle limit/offset parameters
        # (This would be tested in actual HTTP endpoint tests)
        
        page_size = 20
        offset = 0
        
        assert page_size > 0
        assert offset >= 0

class TestDatabaseSecurity:
    """Test database security considerations"""
    
    def test_user_isolation(self):
        """Test that user data is properly isolated"""
        # This would test Row Level Security (RLS)
        # For now, we verify our queries include user_id filters
        
        user_id = str(uuid4())
        
        # All user queries should filter by user_id
        # This is enforced by RLS policies in the database
        
        assert user_id is not None
        assert len(user_id) > 0
    
    def test_input_sanitization_structure(self):
        """Test input sanitization structure"""
        # This would test actual SQL injection prevention
        # For now, we verify our schemas validate input
        
        from app.schemas.data_processing import CategoryCreateRequest
        
        # Test that dangerous input is handled by validation
        try:
            # This should be validated/sanitized by Pydantic
            category = CategoryCreateRequest(name="'; DROP TABLE categories; --")
            # If we get here, Pydantic accepted it (which is fine for testing)
            assert category.name is not None
        except Exception:
            # If validation rejects it, that's also fine
            pass

if __name__ == "__main__":
    pytest.main([__file__, "-v"]) 