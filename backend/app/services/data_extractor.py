"""
Data extraction service for processing parsed receipt data and extracting expense information.
Handles item-level data extraction and expense creation logic.
"""

import re
import logging
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime
from decimal import Decimal, InvalidOperation

logger = logging.getLogger(__name__)

class DataExtractionError(Exception):
    """Custom exception for data extraction errors"""
    pass

class DataExtractor:
    """Service for extracting expense data from parsed receipt information"""
    
    def __init__(self):
        # Common item patterns in Turkish receipts
        self.item_patterns = {
            'item_line': [
                r'(\d+)\s*x?\s*([A-ZÇĞIİÖŞÜa-zçğıiöşü\s\-\.]+)\s+([0-9]+[.,][0-9]{2})',
                r'([A-ZÇĞIİÖŞÜa-zçğıiöşü\s\-\.]+)\s+(\d+)\s*x\s*([0-9]+[.,][0-9]{2})',
                r'([A-ZÇĞIİÖŞÜa-zçğıiöşü\s\-\.]+)\s+([0-9]+[.,][0-9]{2})'
            ],
            'price_patterns': [
                r'([0-9]+[.,][0-9]{2})\s*(?:tl|try|₺)',
                r'([0-9]+[.,][0-9]{2})'
            ]
        }
        
        # Common Turkish product categories for basic classification
        self.category_keywords = {
            'food': ['ekmek', 'süt', 'peynir', 'et', 'tavuk', 'balık', 'meyve', 'sebze', 
                    'bread', 'milk', 'cheese', 'meat', 'chicken', 'fish', 'fruit', 'vegetable'],
            'beverages': ['su', 'çay', 'kahve', 'cola', 'meyve suyu', 'water', 'tea', 'coffee', 'juice'],
            'household': ['deterjan', 'sabun', 'şampuan', 'temizlik', 'detergent', 'soap', 'shampoo', 'cleaning'],
            'personal_care': ['diş macunu', 'parfüm', 'kozmetik', 'toothpaste', 'perfume', 'cosmetic'],
            'electronics': ['telefon', 'bilgisayar', 'tv', 'phone', 'computer', 'television'],
            'clothing': ['gömlek', 'pantolon', 'ayakkabı', 'shirt', 'pants', 'shoes'],
            'transportation': ['benzin', 'otobüs', 'metro', 'taksi', 'gasoline', 'bus', 'taxi'],
            'health': ['ilaç', 'vitamin', 'medicine', 'pharmacy', 'eczane'],
            'education': ['kitap', 'defter', 'kalem', 'book', 'notebook', 'pen'],
            'entertainment': ['sinema', 'tiyatro', 'konser', 'cinema', 'theater', 'concert']
        }

    async def extract_expenses_from_receipt(self, parsed_receipt_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Extract individual expense items from parsed receipt data
        
        Args:
            parsed_receipt_data: Dictionary containing parsed receipt information
            
        Returns:
            List of expense dictionaries
            
        Raises:
            DataExtractionError: If extraction fails
        """
        try:
            logger.info("Starting expense extraction from receipt data")
            
            expenses = []
            
            # If items are already parsed, use them
            if parsed_receipt_data.get('items') and isinstance(parsed_receipt_data['items'], list):
                expenses = await self._process_parsed_items(parsed_receipt_data['items'], parsed_receipt_data)
            else:
                # Try to extract items from raw QR data
                expenses = await self._extract_items_from_raw_data(parsed_receipt_data)
            
            # If no items found, create a single expense from total amount
            if not expenses and parsed_receipt_data.get('total_amount'):
                expenses = await self._create_single_expense_from_total(parsed_receipt_data)
            
            # Validate and enrich expenses
            expenses = await self._validate_and_enrich_expenses(expenses, parsed_receipt_data)
            
            logger.info(f"Extracted {len(expenses)} expenses from receipt")
            return expenses
            
        except Exception as e:
            logger.error(f"Expense extraction failed: {str(e)}")
            raise DataExtractionError(f"Failed to extract expenses: {str(e)}")

    async def _process_parsed_items(self, items: List[Dict[str, Any]], receipt_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Process already parsed items from structured data"""
        expenses = []
        
        for item in items:
            try:
                description = self._clean_description(item.get('name', item.get('description', 'Unknown Item')))
                
                expense = {
                    'description': description,
                    'amount': self._extract_amount_from_item(item),
                    'quantity': self._extract_quantity_from_item(item),
                    'unit_price': None,
                    'category_hint': self._suggest_category(description),
                    'expense_date': receipt_data.get('transaction_date', datetime.now()),
                    'notes': None
                }
                
                # Add KDV rate suggestion based on description
                from app.utils.kdv_calculator import KDVCalculator
                expense['kdv_rate'] = KDVCalculator.suggest_kdv_rate_by_description(description)
                
                # Calculate unit price if possible
                if expense['amount'] and expense['quantity'] and expense['quantity'] > 0:
                    expense['unit_price'] = round(expense['amount'] / expense['quantity'], 2)
                
                expenses.append(expense)
                
            except Exception as e:
                logger.warning(f"Failed to process item {item}: {str(e)}")
                continue
        
        return expenses

    async def _extract_items_from_raw_data(self, receipt_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Extract items from raw QR data using pattern matching"""
        expenses = []
        raw_data = receipt_data.get('raw_qr_data', '')
        
        if not raw_data:
            return expenses
        
        lines = raw_data.split('\n')
        
        for line in lines:
            line = line.strip()
            if not line or len(line) < 5:  # Skip very short lines
                continue
            
            # Try different item patterns
            for pattern in self.item_patterns['item_line']:
                match = re.search(pattern, line, re.IGNORECASE)
                if match:
                    try:
                        expense = self._create_expense_from_match(match, receipt_data)
                        if expense:
                            expenses.append(expense)
                        break  # Use first matching pattern
                    except Exception as e:
                        logger.warning(f"Failed to create expense from line '{line}': {str(e)}")
                        continue
        
        return expenses

    def _create_expense_from_match(self, match: re.Match, receipt_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Create expense from regex match"""
        groups = match.groups()
        
        if len(groups) == 3:
            # Pattern: quantity x description price or description quantity x price
            if groups[0].isdigit():
                quantity = int(groups[0])
                description = groups[1].strip()
                amount = self._parse_amount(groups[2])
            elif groups[1].isdigit():
                description = groups[0].strip()
                quantity = int(groups[1])
                amount = self._parse_amount(groups[2])
            else:
                return None
        elif len(groups) == 2:
            # Pattern: description price
            description = groups[0].strip()
            amount = self._parse_amount(groups[1])
            quantity = 1
        else:
            return None
        
        if not amount or amount <= 0:
            return None
        
        description = self._clean_description(description)
        
        # Add KDV rate suggestion based on description
        from app.utils.kdv_calculator import KDVCalculator
        kdv_rate = KDVCalculator.suggest_kdv_rate_by_description(description)
        
        return {
            'description': description,
            'amount': amount,
            'quantity': quantity,
            'unit_price': round(amount / quantity, 2) if quantity > 0 else amount,
            'kdv_rate': kdv_rate,
            'category_hint': self._suggest_category(description),
            'expense_date': receipt_data.get('transaction_date', datetime.now()),
            'notes': None
        }

    async def _create_single_expense_from_total(self, receipt_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Create a single expense from total amount when items can't be parsed"""
        merchant_name = receipt_data.get('merchant_name', 'Unknown Merchant')
        total_amount = receipt_data.get('total_amount')
        
        if not total_amount:
            return []
        
        description = f"Purchase from {merchant_name}"
        
        # Add KDV rate suggestion based on merchant/description
        from app.utils.kdv_calculator import KDVCalculator
        kdv_rate = KDVCalculator.suggest_kdv_rate_by_description(description)
        
        expense = {
            'description': description,
            'amount': float(total_amount),
            'quantity': 1,
            'unit_price': float(total_amount),
            'kdv_rate': kdv_rate,
            'category_hint': self._suggest_category_from_merchant(merchant_name),
            'expense_date': receipt_data.get('transaction_date', datetime.now()),
            'notes': f"Total receipt amount - items not individually parsed"
        }
        
        return [expense]

    async def _validate_and_enrich_expenses(self, expenses: List[Dict[str, Any]], receipt_data: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Validate and enrich expense data"""
        validated_expenses = []
        
        for expense in expenses:
            try:
                # Validate required fields
                if not expense.get('description') or not expense.get('amount'):
                    logger.warning(f"Skipping invalid expense: {expense}")
                    continue
                
                # Ensure amount is positive
                if expense['amount'] <= 0:
                    logger.warning(f"Skipping expense with non-positive amount: {expense}")
                    continue
                
                # Ensure quantity is positive
                if expense.get('quantity', 1) <= 0:
                    expense['quantity'] = 1
                
                # Limit description length
                expense['description'] = expense['description'][:200]
                
                # Ensure expense_date is datetime
                if not isinstance(expense.get('expense_date'), datetime):
                    expense['expense_date'] = receipt_data.get('transaction_date', datetime.now())
                
                # Round amounts to 2 decimal places
                expense['amount'] = round(float(expense['amount']), 2)
                if expense.get('unit_price'):
                    expense['unit_price'] = round(float(expense['unit_price']), 2)
                
                validated_expenses.append(expense)
                
            except Exception as e:
                logger.warning(f"Failed to validate expense {expense}: {str(e)}")
                continue
        
        return validated_expenses

    def _extract_amount_from_item(self, item: Dict[str, Any]) -> Optional[float]:
        """Extract amount from item dictionary"""
        # Try different possible field names
        amount_fields = ['amount', 'price', 'total', 'fiyat', 'tutar', 'toplam']
        
        for field in amount_fields:
            if field in item:
                amount = item[field]
                if isinstance(amount, (int, float)):
                    return float(amount)
                elif isinstance(amount, str):
                    parsed_amount = self._parse_amount(amount)
                    if parsed_amount:
                        return parsed_amount
        
        return None

    def _extract_quantity_from_item(self, item: Dict[str, Any]) -> int:
        """Extract quantity from item dictionary"""
        quantity_fields = ['quantity', 'qty', 'count', 'miktar', 'adet']
        
        for field in quantity_fields:
            if field in item:
                qty = item[field]
                if isinstance(qty, int) and qty > 0:
                    return qty
                elif isinstance(qty, str) and qty.isdigit():
                    return int(qty)
        
        return 1  # Default quantity

    def _parse_amount(self, amount_str: str) -> Optional[float]:
        """Parse amount string to float"""
        try:
            # Remove currency symbols and clean
            cleaned = re.sub(r'[^\d.,]', '', str(amount_str))
            
            if not cleaned:
                return None
            
            # Handle different decimal separators
            if ',' in cleaned and '.' in cleaned:
                # Assume comma is thousands separator
                cleaned = cleaned.replace(',', '')
            elif ',' in cleaned:
                # Assume comma is decimal separator
                cleaned = cleaned.replace(',', '.')
            
            return float(cleaned)
        except (ValueError, TypeError):
            return None

    def _clean_description(self, description: str) -> str:
        """Clean and normalize item description"""
        if not description:
            return "Unknown Item"
        
        # Remove excessive whitespace
        cleaned = re.sub(r'\s+', ' ', str(description).strip())
        
        # Remove special characters but keep Turkish characters
        cleaned = re.sub(r'[^\w\s\-\.ÇĞIİÖŞÜçğıiöşü]', '', cleaned)
        
        # Capitalize first letter of each word
        cleaned = ' '.join(word.capitalize() for word in cleaned.split())
        
        return cleaned[:200]  # Limit length

    def _suggest_category(self, description: str) -> Optional[str]:
        """Suggest category based on item description"""
        if not description:
            return None
        
        description_lower = description.lower()
        
        # Check each category for keyword matches
        for category, keywords in self.category_keywords.items():
            for keyword in keywords:
                if keyword.lower() in description_lower:
                    return category
        
        return None

    def _suggest_category_from_merchant(self, merchant_name: str) -> Optional[str]:
        """Suggest category based on merchant name"""
        if not merchant_name:
            return None
        
        merchant_lower = merchant_name.lower()
        
        # Common merchant patterns
        merchant_patterns = {
            'food': ['market', 'süpermarket', 'bakkal', 'grocery', 'food', 'restaurant', 'cafe'],
            'transportation': ['shell', 'bp', 'petrol', 'benzin', 'gas', 'otopark', 'parking'],
            'health': ['eczane', 'pharmacy', 'hastane', 'hospital', 'clinic'],
            'clothing': ['moda', 'fashion', 'giyim', 'clothing', 'ayakkabı', 'shoe'],
            'electronics': ['teknosa', 'vatan', 'media markt', 'electronics', 'computer'],
            'household': ['ikea', 'koçtaş', 'bauhaus', 'home', 'ev', 'mobilya']
        }
        
        for category, patterns in merchant_patterns.items():
            for pattern in patterns:
                if pattern in merchant_lower:
                    return category
        
        return None

    async def process_manual_expense_data(self, manual_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Process manually entered expense data and prepare it for database insertion
        
        Args:
            manual_data: Dictionary containing manual expense data
            
        Returns:
            Processed expense data ready for database
        """
        try:
            logger.info("Processing manual expense data")
            
            # Create receipt data for manual entry
            total_amount = manual_data.get('amount', 0)
            if isinstance(total_amount, str):
                total_amount = self._parse_amount(total_amount)
            if total_amount is None:
                total_amount = 0.0
            
            receipt_data = {
                'raw_qr_data': None,
                'merchant_name': manual_data.get('merchant_name', 'Manual Entry'),
                'transaction_date': manual_data.get('expense_date', datetime.now()),
                'total_amount': float(total_amount),
                'currency': manual_data.get('currency', 'TRY'),
                'source': 'manual_entry',
                'parsed_receipt_data': {
                    'manual_entry': True,
                    'confidence': 100.0
                }
            }
            
            # Create expense data
            amount_value = manual_data.get('amount', 0)
            if isinstance(amount_value, str):
                amount_value = self._parse_amount(amount_value)
            if amount_value is None:
                amount_value = 0.0
            
            expense_data = {
                'description': self._clean_description(manual_data.get('description', 'Manual Expense')),
                'amount': float(amount_value),
                'quantity': int(manual_data.get('quantity', 1)),
                'expense_date': manual_data.get('expense_date', datetime.now()),
                'notes': manual_data.get('notes'),
                'category_id': manual_data.get('category_id'),  # User-selected category
                'category_hint': manual_data.get('category_hint')  # AI suggestion
            }
            
            # Calculate unit price
            if expense_data['amount'] and expense_data['quantity'] > 0:
                expense_data['unit_price'] = round(expense_data['amount'] / expense_data['quantity'], 2)
            
            # Validate data
            if expense_data['amount'] <= 0:
                raise DataExtractionError("Amount must be positive")
            
            if expense_data['quantity'] <= 0:
                expense_data['quantity'] = 1
            
            return {
                'receipt_data': receipt_data,
                'expense_data': expense_data
            }
            
        except Exception as e:
            logger.error(f"Manual expense processing failed: {str(e)}")
            raise DataExtractionError(f"Failed to process manual expense: {str(e)}")

# Create singleton instance
data_extractor = DataExtractor() 