"""
Data cleaning service for normalizing and validating expense and receipt data.
Handles data formatting, validation, and standardization.
"""

import re
import logging
from typing import Dict, Any, List, Optional, Union
from datetime import datetime, date
from decimal import Decimal, InvalidOperation

logger = logging.getLogger(__name__)

class DataCleaningError(Exception):
    """Custom exception for data cleaning errors"""
    pass

class DataCleaner:
    """Service for cleaning and validating expense and receipt data"""
    
    def __init__(self):
        # Currency mappings and symbols
        self.currency_mappings = {
            '₺': 'TRY',
            'tl': 'TRY',
            'try': 'TRY',
            'turkish lira': 'TRY',
            'türk lirası': 'TRY',
            '$': 'USD',
            'usd': 'USD',
            'dollar': 'USD',
            '€': 'EUR',
            'eur': 'EUR',
            'euro': 'EUR',
            '£': 'GBP',
            'gbp': 'GBP',
            'pound': 'GBP'
        }
        
        # Common merchant name variations to standardize
        self.merchant_standardizations = {
            'migros': ['migros', 'mıgros', 'migross'],
            'carrefour': ['carrefour', 'carrefoursa', 'carrefour sa'],
            'bim': ['bim', 'b.i.m', 'bim market'],
            'a101': ['a101', 'a 101', 'a-101'],
            'şok': ['şok', 'sok', 'şok market'],
            'shell': ['shell', 'shell petrol', 'shell türkiye'],
            'bp': ['bp', 'bp petrol', 'british petroleum'],
            'opet': ['opet', 'opet petrol'],
            'starbucks': ['starbucks', 'starbucks coffee'],
            'mcdonalds': ['mcdonalds', "mcdonald's", 'mc donalds']
        }
        
        # Patterns for cleaning text data
        self.text_cleaning_patterns = {
            'excessive_whitespace': r'\s+',
            'special_chars': r'[^\w\s\-\.ÇĞIİÖŞÜçğıiöşü]',
            'multiple_dots': r'\.{2,}',
            'multiple_dashes': r'\-{2,}',
            'leading_trailing_special': r'^[\-\.\s]+|[\-\.\s]+$'
        }

    async def clean_receipt_data(self, receipt_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Clean and validate receipt data
        
        Args:
            receipt_data: Raw receipt data dictionary
            
        Returns:
            Cleaned receipt data
            
        Raises:
            DataCleaningError: If cleaning fails
        """
        try:
            logger.info("Starting receipt data cleaning")
            
            cleaned_data = receipt_data.copy()
            
            # Clean merchant name
            if cleaned_data.get('merchant_name'):
                cleaned_data['merchant_name'] = self._clean_merchant_name(cleaned_data['merchant_name'])
            
            # Clean and validate amount
            if cleaned_data.get('total_amount'):
                cleaned_data['total_amount'] = self._clean_amount(cleaned_data['total_amount'])
            
            # Clean and validate currency
            if cleaned_data.get('currency'):
                cleaned_data['currency'] = self._clean_currency(cleaned_data['currency'])
            else:
                cleaned_data['currency'] = 'TRY'  # Default currency
            
            # Clean and validate date
            if cleaned_data.get('transaction_date'):
                cleaned_data['transaction_date'] = self._clean_date(cleaned_data['transaction_date'])
            
            # Clean tax number
            if cleaned_data.get('tax_number'):
                cleaned_data['tax_number'] = self._clean_tax_number(cleaned_data['tax_number'])
            
            # Clean raw QR data
            if cleaned_data.get('raw_qr_data'):
                cleaned_data['raw_qr_data'] = self._clean_text(cleaned_data['raw_qr_data'], preserve_structure=True)
            
            # Validate source
            if cleaned_data.get('source'):
                cleaned_data['source'] = self._validate_source(cleaned_data['source'])
            
            # Clean parsed receipt data if it exists
            if cleaned_data.get('parsed_receipt_data') and isinstance(cleaned_data['parsed_receipt_data'], dict):
                cleaned_data['parsed_receipt_data'] = await self._clean_parsed_data(cleaned_data['parsed_receipt_data'])
            
            logger.info("Receipt data cleaning completed")
            return cleaned_data
            
        except Exception as e:
            logger.error(f"Receipt data cleaning failed: {str(e)}")
            raise DataCleaningError(f"Failed to clean receipt data: {str(e)}")

    async def clean_expense_data(self, expense_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Clean and validate expense data
        
        Args:
            expense_data: Raw expense data dictionary
            
        Returns:
            Cleaned expense data
            
        Raises:
            DataCleaningError: If cleaning fails
        """
        try:
            logger.info("Starting expense data cleaning")
            
            cleaned_data = expense_data.copy()
            
            # Clean description
            if cleaned_data.get('description'):
                cleaned_data['description'] = self._clean_text(cleaned_data['description'])
            else:
                cleaned_data['description'] = 'Unknown Expense'
            
            # Clean and validate amount
            if cleaned_data.get('amount'):
                cleaned_data['amount'] = self._clean_amount(cleaned_data['amount'])
                if cleaned_data['amount'] <= 0:
                    raise DataCleaningError("Amount must be positive")
            else:
                raise DataCleaningError("Amount is required")
            
            # Clean and validate quantity
            if cleaned_data.get('quantity'):
                cleaned_data['quantity'] = self._clean_quantity(cleaned_data['quantity'])
            else:
                cleaned_data['quantity'] = 1
            
            # Clean unit price
            if cleaned_data.get('unit_price'):
                cleaned_data['unit_price'] = self._clean_amount(cleaned_data['unit_price'])
            elif cleaned_data['amount'] and cleaned_data['quantity'] > 0:
                cleaned_data['unit_price'] = round(cleaned_data['amount'] / cleaned_data['quantity'], 2)
            
            # Clean date
            if cleaned_data.get('expense_date'):
                cleaned_data['expense_date'] = self._clean_date(cleaned_data['expense_date'])
            else:
                cleaned_data['expense_date'] = datetime.now()
            
            # Clean notes
            if cleaned_data.get('notes'):
                cleaned_data['notes'] = self._clean_text(cleaned_data['notes'], max_length=500)
            
            # Clean category hint
            if cleaned_data.get('category_hint'):
                cleaned_data['category_hint'] = self._clean_category_hint(cleaned_data['category_hint'])
            
            logger.info("Expense data cleaning completed")
            return cleaned_data
            
        except Exception as e:
            logger.error(f"Expense data cleaning failed: {str(e)}")
            raise DataCleaningError(f"Failed to clean expense data: {str(e)}")

    async def clean_bulk_expenses(self, expenses_list: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Clean multiple expense records
        
        Args:
            expenses_list: List of expense data dictionaries
            
        Returns:
            List of cleaned expense data
        """
        cleaned_expenses = []
        
        for i, expense in enumerate(expenses_list):
            try:
                cleaned_expense = await self.clean_expense_data(expense)
                cleaned_expenses.append(cleaned_expense)
            except DataCleaningError as e:
                logger.warning(f"Failed to clean expense {i}: {str(e)}")
                continue
            except Exception as e:
                logger.error(f"Unexpected error cleaning expense {i}: {str(e)}")
                continue
        
        return cleaned_expenses

    def _clean_merchant_name(self, merchant_name: str) -> str:
        """Clean and standardize merchant name"""
        if not merchant_name:
            return "Unknown Merchant"
        
        # Basic text cleaning
        cleaned = self._clean_text(merchant_name, max_length=100)
        cleaned_lower = cleaned.lower()
        
        # Check for standardizations
        for standard_name, variations in self.merchant_standardizations.items():
            for variation in variations:
                if variation in cleaned_lower:
                    return standard_name.title()
        
        return cleaned

    def _clean_amount(self, amount: Union[str, int, float, Decimal]) -> float:
        """Clean and validate monetary amount"""
        if amount is None:
            return 0.0
        
        if isinstance(amount, (int, float)):
            return round(float(amount), 2)
        
        if isinstance(amount, Decimal):
            return round(float(amount), 2)
        
        if isinstance(amount, str):
            # Remove currency symbols and clean
            cleaned = re.sub(r'[^\d.,\-]', '', str(amount))
            
            if not cleaned or cleaned in ['-', '.', ',']:
                return 0.0
            
            # Handle negative amounts
            is_negative = cleaned.startswith('-')
            if is_negative:
                cleaned = cleaned[1:]
            
            # Handle different decimal separators
            if ',' in cleaned and '.' in cleaned:
                # Assume comma is thousands separator if both present
                cleaned = cleaned.replace(',', '')
            elif ',' in cleaned:
                # Assume comma is decimal separator for Turkish format
                cleaned = cleaned.replace(',', '.')
            
            try:
                result = float(cleaned)
                if is_negative:
                    result = -result
                return round(result, 2)
            except ValueError:
                return 0.0
        
        return 0.0

    def _clean_quantity(self, quantity: Union[str, int, float]) -> int:
        """Clean and validate quantity"""
        if quantity is None:
            return 1
        
        if isinstance(quantity, int) and quantity > 0:
            return quantity
        
        if isinstance(quantity, float) and quantity > 0:
            return int(round(quantity))
        
        if isinstance(quantity, str):
            # Extract numeric part
            numeric_part = re.sub(r'[^\d]', '', str(quantity))
            if numeric_part:
                try:
                    qty = int(numeric_part)
                    return max(1, qty)  # Ensure at least 1
                except ValueError:
                    pass
        
        return 1

    def _clean_currency(self, currency: str) -> str:
        """Clean and standardize currency code"""
        if not currency:
            return 'TRY'
        
        currency_clean = currency.lower().strip()
        
        # Check mappings
        for symbol, code in self.currency_mappings.items():
            if symbol in currency_clean:
                return code
        
        # If it's already a valid currency code
        if len(currency_clean) == 3 and currency_clean.isalpha():
            return currency_clean.upper()
        
        return 'TRY'  # Default to Turkish Lira

    def _clean_date(self, date_input: Union[str, datetime, date]) -> datetime:
        """Clean and validate date"""
        if isinstance(date_input, datetime):
            return date_input
        
        if isinstance(date_input, date):
            return datetime.combine(date_input, datetime.min.time())
        
        if isinstance(date_input, str):
            # Try to parse various date formats
            date_formats = [
                '%Y-%m-%d %H:%M:%S',
                '%Y-%m-%d %H:%M',
                '%Y-%m-%d',
                '%d/%m/%Y %H:%M:%S',
                '%d/%m/%Y %H:%M',
                '%d/%m/%Y',
                '%d.%m.%Y %H:%M:%S',
                '%d.%m.%Y %H:%M',
                '%d.%m.%Y',
                '%d-%m-%Y %H:%M:%S',
                '%d-%m-%Y %H:%M',
                '%d-%m-%Y'
            ]
            
            for fmt in date_formats:
                try:
                    return datetime.strptime(date_input.strip(), fmt)
                except ValueError:
                    continue
            
            # Try dateutil parser as fallback
            try:
                from dateutil import parser as date_parser
                return date_parser.parse(date_input, dayfirst=True)
            except Exception:
                pass
        
        # Return current datetime if parsing fails
        return datetime.now()

    def _clean_tax_number(self, tax_number: str) -> Optional[str]:
        """Clean and validate tax number"""
        if not tax_number:
            return None
        
        # Extract only digits
        digits_only = re.sub(r'\D', '', str(tax_number))
        
        # Turkish tax numbers are 10 or 11 digits
        if len(digits_only) in [10, 11]:
            return digits_only
        
        return None

    def _clean_text(self, text: str, max_length: int = 200, preserve_structure: bool = False) -> str:
        """Clean and normalize text data"""
        if not text:
            return ""
        
        text = str(text)
        
        if not preserve_structure:
            # Remove excessive whitespace
            text = re.sub(self.text_cleaning_patterns['excessive_whitespace'], ' ', text)
            
            # Remove unwanted special characters but preserve Turkish characters
            text = re.sub(self.text_cleaning_patterns['special_chars'], '', text)
            
            # Clean up multiple dots and dashes
            text = re.sub(self.text_cleaning_patterns['multiple_dots'], '.', text)
            text = re.sub(self.text_cleaning_patterns['multiple_dashes'], '-', text)
            
            # Remove leading/trailing special characters
            text = re.sub(self.text_cleaning_patterns['leading_trailing_special'], '', text)
            
            # Capitalize properly
            text = ' '.join(word.capitalize() for word in text.split())
        else:
            # Minimal cleaning for structured data
            text = re.sub(r'\s+', ' ', text)
        
        # Limit length
        if len(text) > max_length:
            text = text[:max_length].strip()
        
        return text.strip()

    def _clean_category_hint(self, category_hint: str) -> str:
        """Clean category hint"""
        if not category_hint:
            return ""
        
        # Convert to lowercase and clean
        cleaned = category_hint.lower().strip()
        
        # Remove special characters
        cleaned = re.sub(r'[^\w\s]', '', cleaned)
        
        # Replace spaces with underscores
        cleaned = re.sub(r'\s+', '_', cleaned)
        
        return cleaned

    def _validate_source(self, source: str) -> str:
        """Validate and clean source field"""
        valid_sources = ['qr_scan', 'manual_entry', 'api_import', 'bulk_upload']
        
        if not source:
            return 'manual_entry'
        
        source_clean = source.lower().strip()
        
        if source_clean in valid_sources:
            return source_clean
        
        # Try to map common variations
        if 'qr' in source_clean or 'scan' in source_clean:
            return 'qr_scan'
        elif 'manual' in source_clean or 'hand' in source_clean:
            return 'manual_entry'
        elif 'api' in source_clean or 'import' in source_clean:
            return 'api_import'
        elif 'bulk' in source_clean or 'batch' in source_clean:
            return 'bulk_upload'
        
        return 'manual_entry'  # Default

    async def _clean_parsed_data(self, parsed_data: Dict[str, Any]) -> Dict[str, Any]:
        """Clean parsed receipt data structure"""
        cleaned = {}
        
        for key, value in parsed_data.items():
            if isinstance(value, str):
                cleaned[key] = self._clean_text(value, preserve_structure=True)
            elif isinstance(value, (int, float)):
                cleaned[key] = value
            elif isinstance(value, list):
                cleaned[key] = [self._clean_text(str(item)) if isinstance(item, str) else item for item in value]
            elif isinstance(value, dict):
                cleaned[key] = await self._clean_parsed_data(value)
            else:
                cleaned[key] = value
        
        return cleaned

    async def validate_data_integrity(self, receipt_data: Dict[str, Any], expenses_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Validate data integrity between receipt and expenses
        
        Args:
            receipt_data: Cleaned receipt data
            expenses_data: List of cleaned expense data
            
        Returns:
            Validation results with warnings and errors
        """
        validation_result = {
            'is_valid': True,
            'warnings': [],
            'errors': [],
            'total_amount_match': False,
            'calculated_total': 0.0,
            'receipt_total': receipt_data.get('total_amount', 0.0)
        }
        
        try:
            # Calculate total from expenses
            calculated_total = sum(expense.get('amount', 0) for expense in expenses_data)
            validation_result['calculated_total'] = round(calculated_total, 2)
            
            receipt_total = receipt_data.get('total_amount', 0.0)
            
            # Check if totals match (with small tolerance for rounding)
            if abs(calculated_total - receipt_total) <= 0.02:
                validation_result['total_amount_match'] = True
            else:
                difference = abs(calculated_total - receipt_total)
                if difference > receipt_total * 0.1:  # More than 10% difference
                    validation_result['errors'].append(
                        f"Large discrepancy between receipt total ({receipt_total}) and calculated total ({calculated_total})"
                    )
                    validation_result['is_valid'] = False
                else:
                    validation_result['warnings'].append(
                        f"Small discrepancy between receipt total ({receipt_total}) and calculated total ({calculated_total})"
                    )
            
            # Check for missing required fields
            if not receipt_data.get('merchant_name'):
                validation_result['warnings'].append("Missing merchant name")
            
            if not receipt_data.get('transaction_date'):
                validation_result['warnings'].append("Missing transaction date")
            
            # Check expenses
            if not expenses_data:
                validation_result['errors'].append("No expenses found")
                validation_result['is_valid'] = False
            
            for i, expense in enumerate(expenses_data):
                if not expense.get('description'):
                    validation_result['warnings'].append(f"Expense {i+1} missing description")
                
                if not expense.get('amount') or expense.get('amount', 0) <= 0:
                    validation_result['errors'].append(f"Expense {i+1} has invalid amount")
                    validation_result['is_valid'] = False
            
        except Exception as e:
            validation_result['errors'].append(f"Validation error: {str(e)}")
            validation_result['is_valid'] = False
        
        return validation_result

# Create singleton instance
data_cleaner = DataCleaner() 