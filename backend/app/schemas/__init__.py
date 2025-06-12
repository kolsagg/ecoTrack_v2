# Schemas module for Pydantic models

from .data_processing import (
    QRScanRequest,
    ManualExpenseRequest,
    CategorySuggestionRequest,
    ProcessingStep,
    ExpenseData,
    ReceiptData,
    CategorySuggestion,
    QRProcessingResponse,
    ManualExpenseResponse,
    CategorySuggestionsResponse,
    ProcessingStatistics,
    RecategorizationRequest,
    RecategorizationResponse,
    ErrorResponse
)

from .merchant import (
    BusinessType,
    WebhookStatus,
    MerchantCreate,
    MerchantUpdate,
    MerchantResponse,
    MerchantListResponse,
    TransactionItem,
    CustomerInfo,
    WebhookTransactionData,
    WebhookLogResponse,
    WebhookLogListResponse,
    TestTransactionRequest,
    WebhookProcessingResult,
    CustomerMatchResult
)

from .loyalty import (
    LoyaltyLevel,
    LoyaltyStatusResponse,
    PointsCalculationResult,
    LoyaltyTransaction
)

__all__ = [
    'QRScanRequest',
    'ManualExpenseRequest',
    'CategorySuggestionRequest',
    'ProcessingStep',
    'ExpenseData',
    'ReceiptData',
    'CategorySuggestion',
    'QRProcessingResponse',
    'ManualExpenseResponse',
    'CategorySuggestionsResponse',
    'ProcessingStatistics',
    'RecategorizationRequest',
    'RecategorizationResponse',
    'ErrorResponse',
    # Merchant schemas
    'BusinessType',
    'WebhookStatus',
    'MerchantCreate',
    'MerchantUpdate',
    'MerchantResponse',
    'MerchantListResponse',
    'TransactionItem',
    'CustomerInfo',
    'WebhookTransactionData',
    'WebhookLogResponse',
    'WebhookLogListResponse',
    'TestTransactionRequest',
    'WebhookProcessingResult',
    'CustomerMatchResult',
    # Loyalty schemas
    'LoyaltyLevel',
    'LoyaltyStatusResponse',
    'PointsCalculationResult',
    'LoyaltyTransaction'
] 