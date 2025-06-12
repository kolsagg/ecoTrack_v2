from fastapi import APIRouter, Depends, HTTPException, status, Query, Header
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, List
from uuid import UUID

from app.db.supabase_client import get_supabase_client, get_supabase_admin_client
from app.schemas.merchant import (
    WebhookTransactionData,
    WebhookProcessingResult,
    WebhookLogResponse,
    WebhookLogListResponse,
    TestTransactionRequest,
    WebhookStatus
)
from app.services.merchant_service import MerchantService
from app.services.webhook_service import WebhookService
from app.auth.dependencies import require_admin

router = APIRouter()
security = HTTPBearer()


async def validate_merchant_api_key(
    merchant_id: UUID,
    x_api_key: str = Header(..., description="Merchant API key"),
    supabase=Depends(get_supabase_admin_client)
) -> UUID:
    """Validate merchant API key and return merchant ID"""
    try:
        merchant_service = MerchantService(supabase)
        
        # Get merchant by ID and validate API key
        merchant = await merchant_service.get_merchant_by_id(merchant_id)
        if not merchant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Merchant not found"
            )
        
        if not merchant.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Merchant account is inactive"
            )
        
        if merchant.api_key != x_api_key:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid API key"
            )
        
        return merchant_id
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"API key validation failed: {str(e)}"
        )


@router.post("/merchant/{merchant_id}/transaction", response_model=WebhookProcessingResult)
async def receive_merchant_transaction(
    merchant_id: UUID,
    transaction_data: WebhookTransactionData,
    validated_merchant_id: UUID = Depends(validate_merchant_api_key),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Receive real-time transaction data from merchant POS systems
    
    This endpoint processes incoming transaction data from merchant partners,
    matches customers, and automatically creates receipts and expenses.
    
    Requires valid merchant API key in X-API-Key header.
    """
    try:
        webhook_service = WebhookService(supabase)
        result = await webhook_service.process_merchant_transaction(
            merchant_id, 
            transaction_data,
            test_mode=False
        )
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process transaction: {str(e)}"
        )


@router.post("/merchant/{merchant_id}/test-transaction", response_model=WebhookProcessingResult)
async def test_merchant_transaction(
    merchant_id: UUID,
    test_request: TestTransactionRequest,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Test endpoint for merchant integration testing (Admin only)
    
    Allows testing of the webhook processing flow without requiring
    a valid merchant API key. Used for integration testing.
    """
    try:
        webhook_service = WebhookService(supabase)
        result = await webhook_service.process_merchant_transaction(
            merchant_id, 
            test_request.transaction_data,
            test_mode=test_request.test_mode
        )
        
        return result
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process test transaction: {str(e)}"
        )


@router.get("/merchant/{merchant_id}/logs", response_model=WebhookLogListResponse)
async def get_webhook_logs(
    merchant_id: UUID,
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(20, ge=1, le=100, description="Page size"),
    status_filter: Optional[WebhookStatus] = Query(None, alias="status", description="Filter by webhook status"),
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Get webhook delivery logs and status tracking (Admin only)
    
    Returns paginated webhook logs for a specific merchant with optional status filtering.
    """
    try:
        webhook_service = WebhookService(supabase)
        logs, total = await webhook_service.get_webhook_logs(
            merchant_id, 
            page, 
            size, 
            status_filter
        )
        
        has_next = (page * size) < total
        
        return WebhookLogListResponse(
            logs=logs,
            total=total,
            page=page,
            size=size,
            has_next=has_next
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch webhook logs: {str(e)}"
        )


@router.post("/logs/{log_id}/retry")
async def retry_webhook(
    log_id: UUID,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Retry a failed webhook processing (Admin only)
    
    Attempts to reprocess a failed webhook. Only works for webhooks
    with 'failed' status and retry count less than maximum.
    """
    try:
        webhook_service = WebhookService(supabase)
        success = await webhook_service.retry_failed_webhook(log_id)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Webhook retry failed - check if webhook exists and is eligible for retry"
            )
        
        return {"message": "Webhook retry initiated successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to retry webhook: {str(e)}"
        )


@router.get("/merchant/{merchant_id}/stats")
async def get_webhook_stats(
    merchant_id: UUID,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Get webhook statistics for a merchant (Admin only)
    
    Returns summary statistics including success rate, total transactions, etc.
    """
    try:
        # Get webhook statistics from database using simple table query
        result = supabase.table("webhook_logs").select("*").eq("merchant_id", str(merchant_id)).execute()
        
        logs = result.data if result.data else []
        total = len(logs)
        
        if total > 0:
            successful = len([log for log in logs if log.get('status') == 'success'])
            failed = len([log for log in logs if log.get('status') == 'failed'])
            retry = len([log for log in logs if log.get('status') == 'retry'])
            
            success_rate = (successful / total * 100) if total > 0 else 0
            
            # Calculate processing time stats
            processing_times = [log.get('processing_time_ms') for log in logs if log.get('processing_time_ms') is not None]
            avg_time = sum(processing_times) / len(processing_times) if processing_times else None
            max_time = max(processing_times) if processing_times else None
            min_time = min(processing_times) if processing_times else None
            
            return {
                "merchant_id": merchant_id,
                "total_webhooks": total,
                "successful_webhooks": successful,
                "failed_webhooks": failed,
                "retry_webhooks": retry,
                "success_rate_percentage": round(success_rate, 2),
                "avg_processing_time_ms": avg_time,
                "max_processing_time_ms": max_time,
                "min_processing_time_ms": min_time
            }
        else:
            return {
                "merchant_id": merchant_id,
                "total_webhooks": 0,
                "successful_webhooks": 0,
                "failed_webhooks": 0,
                "retry_webhooks": 0,
                "success_rate_percentage": 0,
                "avg_processing_time_ms": None,
                "max_processing_time_ms": None,
                "min_processing_time_ms": None
            }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch webhook statistics: {str(e)}"
        )


 