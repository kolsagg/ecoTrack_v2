"""
Main data processing service that coordinates QR parsing, data extraction, 
cleaning, and AI categorization services.
"""

import logging
from typing import Dict, Any, List, Optional
from datetime import datetime

from .qr_parser import qr_parser, QRParsingError
from .data_extractor import data_extractor, DataExtractionError
from .data_cleaner import data_cleaner, DataCleaningError
from .ai_categorizer import ai_categorizer

logger = logging.getLogger(__name__)

class DataProcessingError(Exception):
    """Custom exception for data processing errors"""
    pass

class DataProcessor:
    """Main service for processing QR code data and manual expenses"""
    
    def __init__(self):
        self.qr_parser = qr_parser
        self.data_extractor = data_extractor
        self.data_cleaner = data_cleaner
        self.ai_categorizer = ai_categorizer

    async def process_qr_receipt(self, qr_data: str, user_id: str) -> Dict[str, Any]:
        """
        Process QR code data into receipt and expense records
        
        Args:
            qr_data: Raw QR code string data
            user_id: User ID for the expense records
            
        Returns:
            Dictionary containing processed receipt and expenses data
            
        Raises:
            DataProcessingError: If processing fails
        """
        try:
            logger.info(f"Starting QR receipt processing for user {user_id}")
            
            processing_result = {
                'success': False,
                'receipt_data': None,
                'expense_data': None,
                'expense_items': [],
                'processing_steps': [],
                'errors': [],
                'warnings': []
            }
            
            # Step 1: Parse QR code data
            try:
                logger.info("Step 1: Parsing QR code data")
                parsed_receipt = await self.qr_parser.parse_qr_data(qr_data)
                processing_result['processing_steps'].append({
                    'step': 'qr_parsing',
                    'status': 'success',
                    'confidence': parsed_receipt.get('parsing_confidence', 0.0),
                    'details': f"QR type: {parsed_receipt.get('qr_type', 'unknown')}"
                })
                
                if parsed_receipt.get('parsing_errors'):
                    processing_result['warnings'].extend(parsed_receipt['parsing_errors'])
                    
            except QRParsingError as e:
                error_msg = f"QR parsing failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'qr_parsing',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Step 2: Extract expense data from parsed receipt
            try:
                logger.info("Step 2: Extracting expense data")
                extracted_expenses = await self.data_extractor.extract_expenses_from_receipt(parsed_receipt)
                processing_result['processing_steps'].append({
                    'step': 'data_extraction',
                    'status': 'success',
                    'details': f"Extracted {len(extracted_expenses)} expenses"
                })
                
                if not extracted_expenses:
                    warning_msg = "No expenses could be extracted from receipt"
                    logger.warning(warning_msg)
                    processing_result['warnings'].append(warning_msg)
                    
            except DataExtractionError as e:
                error_msg = f"Data extraction failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'data_extraction',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Step 3: Clean receipt data
            try:
                logger.info("Step 3: Cleaning receipt data")
                # Prepare receipt data for cleaning
                receipt_data = {
                    'raw_qr_data': qr_data,
                    'merchant_name': parsed_receipt.get('merchant_name'),
                    'transaction_date': parsed_receipt.get('transaction_date'),
                    'total_amount': parsed_receipt.get('total_amount'),
                    'currency': parsed_receipt.get('currency', 'TRY'),
                    'source': 'qr_scan',
                    'parsed_receipt_data': parsed_receipt,
                    'user_id': user_id
                }
                
                cleaned_receipt = await self.data_cleaner.clean_receipt_data(receipt_data)
                processing_result['processing_steps'].append({
                    'step': 'receipt_cleaning',
                    'status': 'success'
                })
                
            except DataCleaningError as e:
                error_msg = f"Receipt data cleaning failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'receipt_cleaning',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Step 4: Create expense summary and process items
            try:
                logger.info("Step 4: Creating expense summary and processing items")
                
                # Calculate total amount from extracted expenses
                total_amount = sum(expense.get('amount', 0) for expense in extracted_expenses)
                
                # Create expense summary
                expense_summary = {
                    'user_id': user_id,
                    'total_amount': total_amount,
                    'expense_date': cleaned_receipt.get('transaction_date'),
                    'notes': f"QR scan from {cleaned_receipt.get('merchant_name', 'Unknown merchant')}"
                }
                
                # Process expense items
                processed_items = []
                for expense in extracted_expenses:
                    # Clean expense data as item
                    try:
                        cleaned_item = await self.data_cleaner.clean_expense_data(expense)
                        
                        # Add user_id
                        cleaned_item['user_id'] = user_id
                        
                        # Categorize item
                        categorization = await self.ai_categorizer.categorize_expense(
                            description=cleaned_item['description'],
                            merchant_name=cleaned_receipt.get('merchant_name'),
                            amount=cleaned_item['amount']
                        )
                        
                        # Add categorization info to item
                        cleaned_item['category_hint'] = categorization['category']
                        cleaned_item['category_confidence'] = categorization['confidence']
                        cleaned_item['categorization_method'] = categorization['method']
                        cleaned_item['suggested_category_id'] = categorization.get('category_id')
                        
                        processed_items.append(cleaned_item)
                        
                    except Exception as e:
                        logger.warning(f"Failed to process expense item: {str(e)}")
                        processing_result['warnings'].append(f"Failed to process expense item: {str(e)}")
                        continue
                
                processing_result['processing_steps'].append({
                    'step': 'expense_processing',
                    'status': 'success',
                    'details': f"Processed {len(processed_items)} expense items"
                })
                
            except Exception as e:
                error_msg = f"Expense processing failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'expense_processing',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Step 5: Validate data integrity
            try:
                logger.info("Step 5: Validating data integrity")
                validation_result = await self.data_cleaner.validate_data_integrity(
                    cleaned_receipt, processed_items
                )
                
                processing_result['processing_steps'].append({
                    'step': 'data_validation',
                    'status': 'success' if validation_result['is_valid'] else 'warning',
                    'details': {
                        'total_match': validation_result['total_amount_match'],
                        'calculated_total': validation_result['calculated_total'],
                        'receipt_total': validation_result['receipt_total']
                    }
                })
                
                if validation_result['warnings']:
                    processing_result['warnings'].extend(validation_result['warnings'])
                
                if validation_result['errors']:
                    processing_result['errors'].extend(validation_result['errors'])
                    if not validation_result['is_valid']:
                        logger.warning("Data validation failed, but continuing with processing")
                        
            except Exception as e:
                logger.warning(f"Data validation failed: {str(e)}")
                processing_result['warnings'].append(f"Data validation failed: {str(e)}")
            
            # Finalize result
            processing_result['success'] = True
            processing_result['receipt_data'] = cleaned_receipt
            processing_result['expense_data'] = expense_summary
            processing_result['expense_items'] = processed_items
            
            logger.info(f"QR receipt processing completed successfully. Receipt: {cleaned_receipt.get('merchant_name')}, Items: {len(processed_items)}")
            return processing_result
            
        except DataProcessingError:
            raise
        except Exception as e:
            error_msg = f"Unexpected error in QR processing: {str(e)}"
            logger.error(error_msg)
            raise DataProcessingError(error_msg)

    async def process_manual_expense(self, expense_data: Dict[str, Any], user_id: str) -> Dict[str, Any]:
        """
        Process manually entered expense data with multiple items
        
        Args:
            expense_data: Manual expense data dictionary with items list
            user_id: User ID for the expense record
            
        Returns:
            Dictionary containing processed receipt and expense items data
            
        Raises:
            DataProcessingError: If processing fails
        """
        try:
            logger.info(f"Starting manual expense processing for user {user_id}")
            
            processing_result = {
                'success': False,
                'receipt_data': None,
                'expense_data': None,
                'expense_items': [],
                'processing_steps': [],
                'errors': [],
                'warnings': []
            }
            
            # Add user_id to expense data
            expense_data['user_id'] = user_id
            
            # Step 1: Process receipt data
            try:
                logger.info("Step 1: Processing receipt data")
                
                # Calculate total amount from items
                total_amount = sum(item['amount'] for item in expense_data.get('items', []))
                
                receipt_data = {
                    'user_id': user_id,
                    'merchant_name': expense_data.get('merchant_name'),
                    'transaction_date': expense_data.get('expense_date'),
                    'total_amount': total_amount,
                    'currency': expense_data.get('currency', 'TRY'),
                    'source': 'manual_entry'
                }
                
                cleaned_receipt = await self.data_cleaner.clean_receipt_data(receipt_data)
                
                processing_result['processing_steps'].append({
                    'step': 'receipt_processing',
                    'status': 'success'
                })
                
            except Exception as e:
                error_msg = f"Receipt processing failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'receipt_processing',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Step 2: Process expense summary
            try:
                logger.info("Step 2: Processing expense summary")
                
                expense_summary = {
                    'user_id': user_id,
                    'total_amount': total_amount,
                    'expense_date': expense_data.get('expense_date'),
                    'notes': expense_data.get('notes')
                }
                
                processing_result['processing_steps'].append({
                    'step': 'expense_summary_processing',
                    'status': 'success'
                })
                
            except Exception as e:
                error_msg = f"Expense summary processing failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'expense_summary_processing',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Step 3: Process expense items
            try:
                logger.info("Step 3: Processing expense items")
                
                processed_items = []
                for item in expense_data.get('items', []):
                    # Clean item data
                    item_data = {
                        'user_id': user_id,
                        'description': item.get('description'),
                        'amount': item.get('amount'),
                        'quantity': item.get('quantity', 1),
                        'unit_price': item.get('unit_price'),
                        'notes': item.get('notes'),
                        'category_id': item.get('category_id')
                    }
                    
                    cleaned_item = await self.data_cleaner.clean_expense_data(item_data)
                    
                    # Categorize item if not already categorized by user
                    if not cleaned_item.get('category_id'):
                        categorization = await self.ai_categorizer.categorize_expense(
                            description=cleaned_item['description'],
                            merchant_name=cleaned_receipt.get('merchant_name'),
                            amount=cleaned_item['amount']
                        )
                        
                        # Add categorization info
                        cleaned_item['category_hint'] = categorization.get('category', 'other')
                        cleaned_item['category_confidence'] = categorization.get('confidence', 0.1)
                        cleaned_item['categorization_method'] = categorization.get('method', 'ai_fallback')
                        cleaned_item['suggested_category_id'] = categorization.get('category_id')
                    
                    processed_items.append(cleaned_item)
                
                processing_result['processing_steps'].append({
                    'step': 'expense_items_processing',
                    'status': 'success',
                    'details': {'items_count': len(processed_items)}
                })
                
            except Exception as e:
                error_msg = f"Expense items processing failed: {str(e)}"
                logger.error(error_msg)
                processing_result['errors'].append(error_msg)
                processing_result['processing_steps'].append({
                    'step': 'expense_items_processing',
                    'status': 'failed',
                    'error': str(e)
                })
                raise DataProcessingError(error_msg)
            
            # Finalize result
            processing_result['success'] = True
            processing_result['receipt_data'] = cleaned_receipt
            processing_result['expense_data'] = expense_summary
            processing_result['expense_items'] = processed_items
            
            logger.info(f"Manual expense processing completed successfully. Total: {total_amount}, Items: {len(processed_items)}")
            return processing_result
            
        except DataProcessingError:
            raise
        except Exception as e:
            error_msg = f"Unexpected error in manual expense processing: {str(e)}"
            logger.error(error_msg)
            raise DataProcessingError(error_msg)

    async def get_category_suggestions(self, description: str, merchant_name: str = None) -> List[Dict[str, Any]]:
        """
        Get category suggestions for an expense
        
        Args:
            description: Expense description
            merchant_name: Merchant name (optional)
            
        Returns:
            List of category suggestions
        """
        try:
            # Get AI categorization
            categorization = await self.ai_categorizer.categorize_expense(description, merchant_name)
            
            # Get additional suggestions based on partial description
            suggestions = self.ai_categorizer.get_category_suggestions(description)
            
            # Combine results
            all_suggestions = [categorization]
            
            # Add other suggestions if they're different from the main categorization
            for suggestion in suggestions:
                if suggestion['category'] != categorization['category']:
                    all_suggestions.append({
                        'category': suggestion['category'],
                        'category_name': suggestion['category_name'],
                        'confidence': suggestion['confidence'],
                        'method': 'keyword_match',
                        'reasoning': f"Matched keywords: {', '.join(suggestion.get('matched_keywords', []))}"
                    })
            
            return all_suggestions[:5]  # Return top 5 suggestions
            
        except Exception as e:
            logger.error(f"Failed to get category suggestions: {str(e)}")
            return [{
                'category': 'other',
                'category_name': 'Other',
                'confidence': 0.1,
                'method': 'fallback',
                'reasoning': f"Error getting suggestions: {str(e)}"
            }]

    async def reprocess_expense_categorization(self, expense_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Reprocess categorization for an existing expense
        
        Args:
            expense_data: Existing expense data
            
        Returns:
            Updated categorization information
        """
        try:
            description = expense_data.get('description', '')
            merchant_name = expense_data.get('merchant_name')
            amount = expense_data.get('amount')
            
            categorization = await self.ai_categorizer.categorize_expense(description, merchant_name, amount)
            
            logger.info(f"Reprocessed categorization for expense: {categorization['category']}")
            return categorization
            
        except Exception as e:
            logger.error(f"Failed to reprocess categorization: {str(e)}")
            return {
                'category': 'other',
                'category_name': 'Other',
                'confidence': 0.1,
                'method': 'fallback',
                'reasoning': f"Reprocessing failed: {str(e)}"
            }

    def get_processing_statistics(self) -> Dict[str, Any]:
        """
        Get statistics about data processing performance
        
        Returns:
            Dictionary containing processing statistics
        """
        return {
            'qr_parser_available': hasattr(self.qr_parser, 'parse_qr_data'),
            'data_extractor_available': hasattr(self.data_extractor, 'extract_expenses_from_receipt'),
            'data_cleaner_available': hasattr(self.data_cleaner, 'clean_receipt_data'),
            'ai_categorizer_available': hasattr(self.ai_categorizer, '_model_available') and self.ai_categorizer._model_available,
            'supported_qr_types': ['url', 'json', 'structured_text', 'plain_text'],
            'supported_currencies': ['TRY', 'USD', 'EUR', 'GBP'],
            'available_categories': list(self.ai_categorizer.categories.keys())
        }

# Create singleton instance
data_processor = DataProcessor() 