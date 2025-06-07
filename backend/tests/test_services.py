"""
Tests for service layer components
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

class TestDataProcessor:
    """Test DataProcessor service"""
    
    def test_data_processor_initialization(self):
        """Test DataProcessor initializes correctly"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Check that all required components are initialized
        assert hasattr(processor, 'qr_parser')
        assert hasattr(processor, 'data_extractor')
        assert hasattr(processor, 'data_cleaner')
        assert hasattr(processor, 'ai_categorizer')
    
    @pytest.mark.asyncio
    async def test_process_manual_expense_success(self):
        """Test successful manual expense processing"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Mock dependencies
        with patch.object(processor.data_cleaner, 'clean_receipt_data') as mock_clean_receipt, \
             patch.object(processor.data_cleaner, 'clean_expense_data') as mock_clean_expense, \
             patch.object(processor.ai_categorizer, 'categorize_expense') as mock_categorize:
            
            # Setup mocks
            mock_clean_receipt.return_value = {
                'merchant_name': 'Test Market',
                'total_amount': 21.25,
                'currency': 'TRY'
            }
            
            mock_clean_expense.return_value = {
                'description': 'Test Item',
                'amount': 21.25,
                'quantity': 1
            }
            
            mock_categorize.return_value = {
                'category_id': str(uuid4()),
                'category': 'food',
                'confidence': 0.95
            }
            
            # Test data
            expense_data = {
                'merchant_name': 'Test Market',
                'items': [
                    {
                        'description': 'Test Item',
                        'amount': 21.25,
                        'quantity': 1
                    }
                ]
            }
            
            # Execute
            result = await processor.process_manual_expense(expense_data, str(uuid4()))
            
            # Verify
            assert result['success'] is True
            assert 'receipt_data' in result
            assert 'expense_data' in result
            assert 'expense_items' in result
            assert len(result['expense_items']) == 1
    
    @pytest.mark.asyncio
    async def test_process_qr_receipt_success(self):
        """Test successful QR receipt processing"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Mock dependencies
        with patch.object(processor.qr_parser, 'parse_qr_data') as mock_parse, \
             patch.object(processor.data_extractor, 'extract_expenses_from_receipt') as mock_extract, \
             patch.object(processor.data_cleaner, 'clean_receipt_data') as mock_clean_receipt, \
             patch.object(processor.data_cleaner, 'clean_expense_data') as mock_clean_expense, \
             patch.object(processor.data_cleaner, 'validate_data_integrity') as mock_validate, \
             patch.object(processor.ai_categorizer, 'categorize_expense') as mock_categorize:
            
            # Setup mocks
            mock_parse.return_value = {
                'merchant_name': 'Test Market',
                'total_amount': 21.25,
                'qr_type': 'standard'
            }
            
            mock_extract.return_value = [
                {
                    'description': 'Test Item',
                    'amount': 21.25,
                    'quantity': 1
                }
            ]
            
            mock_clean_receipt.return_value = {
                'merchant_name': 'Test Market',
                'total_amount': 21.25
            }
            
            mock_clean_expense.return_value = {
                'description': 'Test Item',
                'amount': 21.25,
                'quantity': 1
            }
            
            mock_validate.return_value = {
                'is_valid': True,
                'warnings': [],
                'errors': []
            }
            
            mock_categorize.return_value = {
                'category_id': str(uuid4()),
                'category': 'food',
                'confidence': 0.95
            }
            
            # Execute
            result = await processor.process_qr_receipt('test_qr_data', str(uuid4()))
            
            # Verify
            assert result['success'] is True
            assert 'receipt_data' in result
            assert 'expense_data' in result
            assert 'expense_items' in result
    
    @pytest.mark.asyncio
    async def test_get_category_suggestions(self):
        """Test category suggestions"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Mock AI categorizer
        with patch.object(processor.ai_categorizer, 'categorize_expense') as mock_categorize, \
             patch.object(processor.ai_categorizer, 'get_category_suggestions') as mock_suggestions:
            
            mock_categorize.return_value = {
                'category': 'food',
                'category_name': 'Food',
                'confidence': 0.95,
                'method': 'ai_classification',
                'reasoning': 'Food-related keywords detected'
            }
            
            mock_suggestions.return_value = [
                {
                    'category': 'grocery',
                    'category_name': 'Grocery',
                    'confidence': 0.85,
                    'matched_keywords': ['market', 'food']
                }
            ]
            
            # Execute
            suggestions = await processor.get_category_suggestions('bread from market')
            
            # Verify
            assert len(suggestions) >= 1
            assert suggestions[0]['category'] == 'food'
            assert suggestions[0]['confidence'] == 0.95

class TestQRGenerator:
    """Test QRGenerator service"""
    
    def test_qr_generator_initialization(self):
        """Test QRGenerator initializes correctly"""
        from app.services.qr_generator import QRGenerator
        
        generator = QRGenerator()
        assert generator is not None
    
    def test_generate_receipt_qr(self):
        """Test receipt QR code generation"""
        from app.services.qr_generator import QRGenerator
        
        generator = QRGenerator()
        
        # Test data
        receipt_id = str(uuid4())
        merchant_name = "Test Market"
        total_amount = 45.75
        currency = "TRY"
        transaction_date = datetime.now()
        
        # Execute
        qr_code = generator.generate_receipt_qr(
            receipt_id=receipt_id,
            merchant_name=merchant_name,
            total_amount=total_amount,
            currency=currency,
            transaction_date=transaction_date
        )
        
        # Verify
        assert qr_code is not None
        assert isinstance(qr_code, str)
        assert len(qr_code) > 0
    
    def test_parse_receipt_qr_valid(self):
        """Test parsing valid receipt QR code"""
        from app.services.qr_generator import QRGenerator
        
        generator = QRGenerator()
        
        # Create QR text data directly (not the base64 image)
        receipt_id = str(uuid4())
        qr_text_data = f"""Test Market
Fiş No: {receipt_id[:8]}
Tarih: 15.01.2024 10:30
Toplam: 45.75 TRY
EcoTrack Dijital Fiş
Receipt ID: {receipt_id}"""
        
        # Parse it
        parsed_id = generator.parse_receipt_qr(qr_text_data)
        
        # Verify
        assert parsed_id == receipt_id
    
    def test_parse_receipt_qr_invalid(self):
        """Test parsing invalid receipt QR code"""
        from app.services.qr_generator import QRGenerator
        
        generator = QRGenerator()
        
        # Test with invalid QR data
        parsed_id = generator.parse_receipt_qr("invalid_qr_data")
        
        # Should return None for invalid data
        assert parsed_id is None

class TestAICategorizer:
    """Test AI Categorizer service"""
    
    def test_ai_categorizer_initialization(self):
        """Test AI categorizer initializes correctly"""
        from app.services.ai_categorizer import AICategorizer
        
        categorizer = AICategorizer()
        assert categorizer is not None
    
    @pytest.mark.asyncio
    async def test_categorize_expense_food(self):
        """Test expense categorization for food items"""
        from app.services.ai_categorizer import AICategorizer
        
        categorizer = AICategorizer()
        
        # Test food-related expense
        result = await categorizer.categorize_expense(
            description="bread and milk",
            merchant_name="Migros",
            amount=15.50
        )
        
        # Verify
        assert 'category' in result
        assert 'confidence' in result
        assert 'method' in result
        assert isinstance(result['confidence'], (int, float))
        assert 0 <= result['confidence'] <= 1
    
    @pytest.mark.asyncio
    async def test_categorize_expense_transport(self):
        """Test expense categorization for transport items"""
        from app.services.ai_categorizer import AICategorizer
        
        categorizer = AICategorizer()
        
        # Test transport-related expense
        result = await categorizer.categorize_expense(
            description="bus ticket",
            merchant_name="IETT",
            amount=5.00
        )
        
        # Verify
        assert 'category' in result
        assert 'confidence' in result
        assert result['confidence'] > 0
    
    def test_get_category_suggestions(self):
        """Test category suggestions"""
        from app.services.ai_categorizer import AICategorizer
        
        categorizer = AICategorizer()
        
        # Test suggestions
        suggestions = categorizer.get_category_suggestions("restaurant meal")
        
        # Verify
        assert isinstance(suggestions, list)
        assert len(suggestions) > 0
        
        for suggestion in suggestions:
            assert 'category' in suggestion
            assert 'category_name' in suggestion
            assert 'confidence' in suggestion

class TestDataCleaner:
    """Test Data Cleaner service"""
    
    def test_data_cleaner_initialization(self):
        """Test data cleaner initializes correctly"""
        from app.services.data_cleaner import DataCleaner
        
        cleaner = DataCleaner()
        assert cleaner is not None
    
    @pytest.mark.asyncio
    async def test_clean_receipt_data(self):
        """Test receipt data cleaning"""
        from app.services.data_cleaner import DataCleaner
        
        cleaner = DataCleaner()
        
        # Test data with some issues
        raw_data = {
            'merchant_name': '  Test Market  ',  # Extra whitespace
            'total_amount': '45.75',  # String instead of float
            'currency': 'try',  # Lowercase
            'transaction_date': '2024-01-15T10:30:00',
            'user_id': str(uuid4())
        }
        
        # Execute
        cleaned = await cleaner.clean_receipt_data(raw_data)
        
        # Verify
        assert cleaned['merchant_name'] == 'Test Market'  # Trimmed
        assert cleaned['total_amount'] == 45.75  # Converted to float
        assert cleaned['currency'] == 'TRY'  # Uppercase
        assert 'transaction_date' in cleaned
    
    @pytest.mark.asyncio
    async def test_clean_expense_data(self):
        """Test expense data cleaning"""
        from app.services.data_cleaner import DataCleaner
        
        cleaner = DataCleaner()
        
        # Test data
        raw_data = {
            'description': '  bread and milk  ',
            'amount': '15.50',
            'quantity': '2',
            'user_id': str(uuid4())
        }
        
        # Execute
        cleaned = await cleaner.clean_expense_data(raw_data)
        
        # Verify (DataCleaner might apply title case)
        assert cleaned['description'].lower() == 'bread and milk'
        assert cleaned['amount'] == 15.50
        assert cleaned['quantity'] == 2
    
    @pytest.mark.asyncio
    async def test_validate_data_integrity(self):
        """Test data integrity validation"""
        from app.services.data_cleaner import DataCleaner
        
        cleaner = DataCleaner()
        
        # Test data
        receipt_data = {
            'total_amount': 21.25
        }
        
        expense_items = [
            {'amount': 10.50},
            {'amount': 10.75}
        ]
        
        # Execute
        result = await cleaner.validate_data_integrity(receipt_data, expense_items)
        
        # Verify
        assert 'is_valid' in result
        assert 'total_amount_match' in result
        assert 'calculated_total' in result
        assert 'receipt_total' in result

class TestDataExtractor:
    """Test Data Extractor service"""
    
    def test_data_extractor_initialization(self):
        """Test data extractor initializes correctly"""
        from app.services.data_extractor import DataExtractor
        
        extractor = DataExtractor()
        assert extractor is not None
    
    @pytest.mark.asyncio
    async def test_extract_expenses_from_receipt(self):
        """Test expense extraction from receipt"""
        from app.services.data_extractor import DataExtractor
        
        extractor = DataExtractor()
        
        # Mock receipt data
        receipt_data = {
            'merchant_name': 'Test Market',
            'total_amount': 21.25,
            'items': [
                {
                    'description': 'Bread',
                    'amount': 5.50,
                    'quantity': 1
                },
                {
                    'description': 'Milk',
                    'amount': 15.75,
                    'quantity': 1
                }
            ]
        }
        
        # Execute
        expenses = await extractor.extract_expenses_from_receipt(receipt_data)
        
        # Verify
        assert isinstance(expenses, list)
        assert len(expenses) >= 1
        
        for expense in expenses:
            assert 'description' in expense
            assert 'amount' in expense

class TestQRParser:
    """Test QR Parser service"""
    
    def test_qr_parser_initialization(self):
        """Test QR parser initializes correctly"""
        from app.services.qr_parser import QRParser
        
        parser = QRParser()
        assert parser is not None
    
    @pytest.mark.asyncio
    async def test_parse_qr_data_valid(self):
        """Test parsing valid QR data"""
        from app.services.qr_parser import QRParser
        
        parser = QRParser()
        
        # Test with sample QR data
        qr_data = "sample_qr_receipt_data_12345"
        
        # Execute
        result = await parser.parse_qr_data(qr_data)
        
        # Verify basic structure
        assert isinstance(result, dict)
        assert 'qr_type' in result or 'parsing_errors' in result
    
    @pytest.mark.asyncio
    async def test_parse_qr_data_invalid(self):
        """Test parsing invalid QR data"""
        from app.services.qr_parser import QRParser
        
        parser = QRParser()
        
        # Test with empty QR data - should return result with low confidence
        result = await parser.parse_qr_data("")
        
        # Verify it handles empty data gracefully
        assert isinstance(result, dict)
        assert result['parsing_confidence'] < 0.5  # Low confidence for empty data

class TestServiceIntegration:
    """Test service integration scenarios"""
    
    @pytest.mark.asyncio
    async def test_full_manual_expense_flow(self):
        """Test complete manual expense processing flow"""
        from app.services.data_processor import DataProcessor
        
        processor = DataProcessor()
        
        # Mock all dependencies to return successful results
        with patch.object(processor.data_cleaner, 'clean_receipt_data') as mock_clean_receipt, \
             patch.object(processor.data_cleaner, 'clean_expense_data') as mock_clean_expense, \
             patch.object(processor.ai_categorizer, 'categorize_expense') as mock_categorize:
            
            # Setup successful mocks
            mock_clean_receipt.return_value = {
                'merchant_name': 'Test Market',
                'total_amount': 21.25,
                'currency': 'TRY',
                'source': 'manual_entry'
            }
            
            mock_clean_expense.return_value = {
                'description': 'Test Item',
                'amount': 21.25,
                'quantity': 1
            }
            
            mock_categorize.return_value = {
                'category_id': str(uuid4()),
                'category': 'food',
                'confidence': 0.95,
                'method': 'ai_classification'
            }
            
            # Test complete flow
            expense_data = {
                'merchant_name': 'Test Market',
                'notes': 'Test expense',
                'items': [
                    {
                        'description': 'Test Item',
                        'amount': 21.25,
                        'quantity': 1
                    }
                ]
            }
            
            result = await processor.process_manual_expense(expense_data, str(uuid4()))
            
            # Verify complete flow worked
            assert result['success'] is True
            assert len(result['expense_items']) == 1
            assert result['expense_data']['total_amount'] == 21.25
            assert result['receipt_data']['merchant_name'] == 'Test Market'

if __name__ == "__main__":
    pytest.main([__file__, "-v"]) 