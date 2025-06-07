"""
Pydantic schemas for data processing services
"""

from typing import Optional, List, Dict, Any, Union
from datetime import datetime
from pydantic import BaseModel, Field, validator
from uuid import UUID

class QRScanRequest(BaseModel):
    """Request schema for QR code scanning"""
    qr_data: str = Field(..., description="Raw QR code data")
    
    @validator('qr_data')
    def validate_qr_data(cls, v):
        if not v or not v.strip():
            raise ValueError('QR data cannot be empty')
        return v.strip()

class ExpenseItemCreateRequest(BaseModel):
    """Request schema for creating expense item"""
    category_id: Optional[str] = Field(None, description="Category ID")
    description: str = Field(..., min_length=1, max_length=200, description="Item description")
    amount: float = Field(..., gt=0, description="Item amount")
    quantity: int = Field(1, gt=0, description="Item quantity")
    unit_price: Optional[float] = Field(None, gt=0, description="Unit price")
    notes: Optional[str] = Field(None, max_length=500, description="Item notes")

class ManualExpenseRequest(BaseModel):
    """Request schema for manual expense entry"""
    merchant_name: str = Field(..., min_length=1, max_length=100, description="Merchant name")
    expense_date: Optional[datetime] = Field(None, description="Expense date")
    notes: Optional[str] = Field(None, max_length=500, description="General notes")
    currency: Optional[str] = Field("TRY", description="Currency code")
    items: List[ExpenseItemCreateRequest] = Field(..., min_items=1, description="Expense items")

class CategorySuggestionRequest(BaseModel):
    """Request schema for category suggestions"""
    description: str = Field(..., min_length=1, description="Expense description")
    merchant_name: Optional[str] = Field(None, description="Merchant name")

class ProcessingStep(BaseModel):
    """Schema for processing step information"""
    step: str = Field(..., description="Step name")
    status: str = Field(..., description="Step status (success, failed, warning)")
    confidence: Optional[float] = Field(None, description="Confidence score")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional details")
    error: Optional[str] = Field(None, description="Error message if failed")

class ExpenseData(BaseModel):
    """Schema for expense data"""
    description: str = Field(..., description="Expense description")
    amount: float = Field(..., description="Expense amount")
    quantity: int = Field(..., description="Quantity")
    unit_price: Optional[float] = Field(None, description="Unit price")
    expense_date: datetime = Field(..., description="Expense date")
    notes: Optional[str] = Field(None, description="Additional notes")
    category_hint: Optional[str] = Field(None, description="AI-suggested category")
    category_confidence: Optional[float] = Field(None, description="Category confidence")
    categorization_method: Optional[str] = Field(None, description="Categorization method used")
    user_id: str = Field(..., description="User ID")

class ReceiptData(BaseModel):
    """Schema for receipt data"""
    raw_qr_data: Optional[str] = Field(None, description="Raw QR code data")
    merchant_name: Optional[str] = Field(None, description="Merchant name")
    transaction_date: Optional[datetime] = Field(None, description="Transaction date")
    total_amount: Optional[float] = Field(None, description="Total amount")
    currency: str = Field("TRY", description="Currency code")
    source: str = Field(..., description="Data source")
    tax_number: Optional[str] = Field(None, description="Tax number")
    parsed_receipt_data: Optional[Dict[str, Any]] = Field(None, description="Parsed receipt data")
    user_id: str = Field(..., description="User ID")

class CategorySuggestion(BaseModel):
    """Schema for category suggestion"""
    category: str = Field(..., description="Category ID")
    category_name: str = Field(..., description="Category display name")
    confidence: float = Field(..., description="Confidence score")
    method: str = Field(..., description="Method used for categorization")
    reasoning: str = Field(..., description="Reasoning for the suggestion")

class QRProcessingResponse(BaseModel):
    """Response schema for QR processing"""
    success: bool = Field(..., description="Processing success status")
    receipt_data: Optional[ReceiptData] = Field(None, description="Processed receipt data")
    expenses_data: List[ExpenseData] = Field(default_factory=list, description="Extracted expenses")
    processing_steps: List[ProcessingStep] = Field(default_factory=list, description="Processing steps")
    errors: List[str] = Field(default_factory=list, description="Error messages")
    warnings: List[str] = Field(default_factory=list, description="Warning messages")

class ManualExpenseResponse(BaseModel):
    """Response schema for manual expense processing"""
    success: bool = Field(..., description="Processing success status")
    receipt_data: Optional[ReceiptData] = Field(None, description="Generated receipt data")
    expense_data: Optional[ExpenseData] = Field(None, description="Processed expense data")
    processing_steps: List[ProcessingStep] = Field(default_factory=list, description="Processing steps")
    errors: List[str] = Field(default_factory=list, description="Error messages")
    warnings: List[str] = Field(default_factory=list, description="Warning messages")

class CategorySuggestionsResponse(BaseModel):
    """Response schema for category suggestions"""
    suggestions: List[CategorySuggestion] = Field(..., description="Category suggestions")

class ProcessingStatistics(BaseModel):
    """Schema for processing statistics"""
    qr_parser_available: bool = Field(..., description="QR parser availability")
    data_extractor_available: bool = Field(..., description="Data extractor availability")
    data_cleaner_available: bool = Field(..., description="Data cleaner availability")
    ai_categorizer_available: bool = Field(..., description="AI categorizer availability")
    supported_qr_types: List[str] = Field(..., description="Supported QR types")
    supported_currencies: List[str] = Field(..., description="Supported currencies")
    available_categories: List[str] = Field(..., description="Available categories")

class RecategorizationRequest(BaseModel):
    """Request schema for expense recategorization"""
    expense_id: str = Field(..., description="Expense ID")
    description: str = Field(..., description="Expense description")
    merchant_name: Optional[str] = Field(None, description="Merchant name")
    amount: Optional[float] = Field(None, description="Expense amount")

class RecategorizationResponse(BaseModel):
    """Response schema for expense recategorization"""
    category: str = Field(..., description="New category")
    category_name: str = Field(..., description="Category display name")
    confidence: float = Field(..., description="Confidence score")
    method: str = Field(..., description="Method used")
    reasoning: str = Field(..., description="Reasoning")

class ErrorResponse(BaseModel):
    """Schema for error responses"""
    error: str = Field(..., description="Error message")
    error_code: Optional[str] = Field(None, description="Error code")
    details: Optional[Dict[str, Any]] = Field(None, description="Additional error details")

# API Endpoint Schemas

class QRReceiptRequest(BaseModel):
    """Request schema for QR receipt scanning"""
    qr_data: str = Field(..., description="Raw QR code data")

class QRReceiptResponse(BaseModel):
    """Response schema for QR receipt processing"""
    success: bool = Field(..., description="Processing success")
    message: str = Field(..., description="Response message")
    receipt_id: str = Field(..., description="Created receipt ID")
    merchant_name: Optional[str] = Field(None, description="Merchant name")
    total_amount: Optional[float] = Field(None, description="Total amount")
    currency: str = Field("TRY", description="Currency")
    expenses_count: int = Field(..., description="Number of expenses created")
    processing_confidence: float = Field(..., description="Processing confidence")

class ReceiptListResponse(BaseModel):
    """Response schema for receipt list"""
    id: str = Field(..., description="Receipt ID")
    merchant_name: Optional[str] = Field(None, description="Merchant name")
    transaction_date: Optional[datetime] = Field(None, description="Transaction date")
    total_amount: Optional[float] = Field(None, description="Total amount")
    currency: Optional[str] = Field(None, description="Currency")
    source: str = Field(..., description="Source type")
    created_at: datetime = Field(..., description="Creation date")

class ReceiptDetailResponse(BaseModel):
    """Response schema for receipt detail"""
    id: str = Field(..., description="Receipt ID")
    merchant_name: Optional[str] = Field(None, description="Merchant name")
    transaction_date: Optional[datetime] = Field(None, description="Transaction date")
    total_amount: Optional[float] = Field(None, description="Total amount")
    currency: Optional[str] = Field(None, description="Currency")
    source: str = Field(..., description="Source type")
    raw_qr_data: Optional[str] = Field(None, description="Raw QR data")
    parsed_receipt_data: Optional[Dict[str, Any]] = Field(None, description="Parsed data")
    expenses: List[Dict[str, Any]] = Field(default_factory=list, description="Associated expenses")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Update date")

# Expense Items Schemas (New)

class ExpenseItemResponse(BaseModel):
    """Response schema for expense item"""
    id: str = Field(..., description="Expense item ID")
    expense_id: str = Field(..., description="Parent expense ID")
    category_id: Optional[str] = Field(None, description="Category ID")
    category_name: Optional[str] = Field(None, description="Category name")
    description: str = Field(..., description="Item description")
    amount: float = Field(..., description="Item amount")
    quantity: int = Field(..., description="Item quantity")
    unit_price: Optional[float] = Field(None, description="Unit price")
    notes: Optional[str] = Field(None, description="Item notes")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Update date")

class ExpenseItemUpdateRequest(BaseModel):
    """Request schema for updating expense item"""
    category_id: Optional[str] = Field(None, description="Category ID")
    description: Optional[str] = Field(None, min_length=1, max_length=200, description="Item description")
    amount: Optional[float] = Field(None, gt=0, description="Item amount")
    quantity: Optional[int] = Field(None, gt=0, description="Item quantity")
    unit_price: Optional[float] = Field(None, gt=0, description="Unit price")
    notes: Optional[str] = Field(None, max_length=500, description="Item notes")

# Updated Expense Schemas (Summary/Container)

class ExpenseResponse(BaseModel):
    """Response schema for expense (summary/container)"""
    id: str = Field(..., description="Expense ID")
    receipt_id: str = Field(..., description="Receipt ID")
    total_amount: float = Field(..., description="Total amount of all items")
    expense_date: datetime = Field(..., description="Expense date")
    notes: Optional[str] = Field(None, description="General notes")
    items: List[ExpenseItemResponse] = Field(default_factory=list, description="Expense items")
    qr_code: Optional[str] = Field(None, description="Base64 encoded QR code for receipt")
    created_at: datetime = Field(..., description="Creation date")
    updated_at: datetime = Field(..., description="Update date")

class ExpenseListResponse(BaseModel):
    """Response schema for expense list (summary)"""
    id: str = Field(..., description="Expense ID")
    receipt_id: str = Field(..., description="Receipt ID")
    total_amount: float = Field(..., description="Total amount")
    expense_date: datetime = Field(..., description="Expense date")
    notes: Optional[str] = Field(None, description="General notes")
    items_count: int = Field(..., description="Number of items")
    merchant_name: Optional[str] = Field(None, description="Merchant name")
    source: Optional[str] = Field(None, description="Source type")
    created_at: datetime = Field(..., description="Creation date")

class ExpenseUpdateRequest(BaseModel):
    """Request schema for expense update (summary level)"""
    expense_date: Optional[datetime] = Field(None, description="Expense date")
    notes: Optional[str] = Field(None, max_length=500, description="General notes")

class CategoryResponse(BaseModel):
    """Response schema for category"""
    id: Optional[str] = Field(None, description="Category ID (null for system categories)")
    name: str = Field(..., description="Category name")
    user_id: Optional[str] = Field(None, description="User ID (null for system categories)")
    is_system: bool = Field(..., description="Is system category")
    created_at: Optional[datetime] = Field(None, description="Creation date")
    updated_at: Optional[datetime] = Field(None, description="Update date")

class CategoryCreateRequest(BaseModel):
    """Request schema for category creation"""
    name: str = Field(..., min_length=1, max_length=50, description="Category name")

class CategoryUpdateRequest(BaseModel):
    """Request schema for category update"""
    name: Optional[str] = Field(None, min_length=1, max_length=50, description="Category name") 