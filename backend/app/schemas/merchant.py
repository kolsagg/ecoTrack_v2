from pydantic import BaseModel, Field, EmailStr, field_validator, ConfigDict
from typing import Optional, Dict, Any, List
from datetime import datetime
from uuid import UUID
from enum import Enum


class BusinessType(str, Enum):
    RESTAURANT = "restaurant"
    RETAIL = "retail"
    GROCERY = "grocery"
    PHARMACY = "pharmacy"
    GAS_STATION = "gas_station"
    CLOTHING = "clothing"
    ELECTRONICS = "electronics"
    OTHER = "other"


class WebhookStatus(str, Enum):
    SUCCESS = "success"
    FAILED = "failed"
    RETRY = "retry"
    PENDING = "pending"


class MerchantCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=255, description="Merchant name")
    business_type: Optional[BusinessType] = Field(None, description="Type of business")
    contact_email: Optional[EmailStr] = Field(None, description="Contact email")
    contact_phone: Optional[str] = Field(None, max_length=20, description="Contact phone")
    address: Optional[str] = Field(None, max_length=500, description="Business address")
    tax_number: Optional[str] = Field(None, max_length=50, description="Tax identification number")
    webhook_url: Optional[str] = Field(None, description="Webhook URL for transaction notifications")
    settings: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Additional merchant settings")

    @field_validator('contact_phone')
    @classmethod
    def validate_phone(cls, v):
        if v and not v.replace('+', '').replace('-', '').replace(' ', '').replace('(', '').replace(')', '').isdigit():
            raise ValueError('Invalid phone number format')
        return v


class MerchantUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    business_type: Optional[BusinessType] = None
    contact_email: Optional[EmailStr] = None
    contact_phone: Optional[str] = Field(None, max_length=20)
    address: Optional[str] = Field(None, max_length=500)
    tax_number: Optional[str] = Field(None, max_length=50)
    webhook_url: Optional[str] = None
    is_active: Optional[bool] = None
    settings: Optional[Dict[str, Any]] = None

    @field_validator('contact_phone')
    @classmethod
    def validate_phone(cls, v):
        if v and not v.replace('+', '').replace('-', '').replace(' ', '').replace('(', '').replace(')', '').isdigit():
            raise ValueError('Invalid phone number format')
        return v


class MerchantResponse(BaseModel):
    id: UUID
    name: str
    business_type: Optional[str]
    api_key: str
    webhook_url: Optional[str]
    is_active: bool
    contact_email: Optional[str]
    contact_phone: Optional[str]
    address: Optional[str]
    tax_number: Optional[str]
    settings: Optional[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MerchantListResponse(BaseModel):
    merchants: List[MerchantResponse]
    total: int
    page: int
    size: int
    has_next: bool


# Webhook related schemas
class TransactionItem(BaseModel):
    description: str = Field(..., min_length=1, description="Item description")
    quantity: int = Field(..., ge=1, description="Item quantity")
    unit_price: float = Field(..., ge=0, description="Unit price")
    total_price: float = Field(..., ge=0, description="Total price for this item")
    category: Optional[str] = Field(None, description="Item category")


class CustomerInfo(BaseModel):
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    card_hash: Optional[str] = Field(None, description="Hashed card number for matching")
    card_last_four: Optional[str] = Field(None, min_length=4, max_length=4, description="Last 4 digits of card")
    card_type: Optional[str] = Field(None, description="Card type (visa, mastercard, etc.)")


class WebhookTransactionData(BaseModel):
    transaction_id: str = Field(..., description="Unique transaction ID from merchant")
    merchant_transaction_id: Optional[str] = Field(None, description="Internal merchant transaction ID")
    total_amount: float = Field(..., ge=0, description="Total transaction amount")
    currency: str = Field(default="TRY", description="Currency code")
    transaction_date: datetime = Field(..., description="Transaction timestamp")
    customer_info: CustomerInfo = Field(..., description="Customer information for matching")
    items: List[TransactionItem] = Field(..., min_length=1, description="Transaction items")
    payment_method: Optional[str] = Field(None, description="Payment method used")
    receipt_number: Optional[str] = Field(None, description="Receipt number")
    cashier_id: Optional[str] = Field(None, description="Cashier identifier")
    store_location: Optional[str] = Field(None, description="Store location/branch")
    additional_data: Optional[Dict[str, Any]] = Field(default_factory=dict, description="Additional transaction data")

    @field_validator('currency')
    @classmethod
    def validate_currency(cls, v):
        valid_currencies = ['TRY', 'USD', 'EUR', 'GBP']
        if v.upper() not in valid_currencies:
            raise ValueError(f'Currency must be one of: {valid_currencies}')
        return v.upper()


class WebhookLogResponse(BaseModel):
    id: UUID
    merchant_id: UUID
    transaction_id: Optional[str]
    status: WebhookStatus
    response_code: Optional[int]
    error_message: Optional[str]
    processing_time_ms: Optional[int]
    retry_count: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class WebhookLogListResponse(BaseModel):
    logs: List[WebhookLogResponse]
    total: int
    page: int
    size: int
    has_next: bool


class TestTransactionRequest(BaseModel):
    transaction_data: WebhookTransactionData
    test_mode: bool = Field(default=True, description="Indicates this is a test transaction")


class WebhookProcessingResult(BaseModel):
    success: bool
    message: str
    transaction_id: Optional[str] = None
    matched_user_id: Optional[UUID] = None
    created_receipt_id: Optional[UUID] = None
    created_expense_id: Optional[UUID] = None
    processing_time_ms: int
    errors: Optional[List[str]] = None
    is_public_receipt: bool = Field(default=False, description="True if receipt was created as public (no user matched)")
    qr_code: Optional[str] = Field(None, description="Base64 encoded QR code for the receipt")
    public_url: Optional[str] = Field(None, description="Public URL for viewing the receipt (for public receipts)")
    # Loyalty information
    loyalty_points_awarded: Optional[int] = Field(None, description="Loyalty points awarded for this transaction")
    loyalty_transaction_id: Optional[UUID] = Field(None, description="ID of the loyalty transaction record")


class CustomerMatchResult(BaseModel):
    matched: bool
    user_id: Optional[UUID] = None
    match_method: Optional[str] = None  # 'email', 'phone', 'card_hash'
    confidence: float = Field(..., ge=0, le=1, description="Match confidence score") 