from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional, List
from uuid import UUID

from app.db.supabase_client import get_supabase_admin_client
from app.schemas.merchant import (
    MerchantCreate,
    MerchantUpdate,
    MerchantResponse,
    MerchantListResponse
)
from app.services.merchant_service import MerchantService
from app.auth.dependencies import get_current_user, require_admin

router = APIRouter()
security = HTTPBearer()


@router.post("/", response_model=MerchantResponse, status_code=status.HTTP_201_CREATED)
async def create_merchant(
    merchant_data: MerchantCreate,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Create a new merchant partner (Admin only)
    
    Creates a new merchant with auto-generated API key for webhook integration.
    """
    try:
        merchant_service = MerchantService(supabase)
        merchant = await merchant_service.create_merchant(merchant_data)
        return merchant
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to create merchant: {str(e)}"
        )


@router.get("/", response_model=MerchantListResponse)
async def list_merchants(
    page: int = Query(1, ge=1, description="Page number"),
    size: int = Query(20, ge=1, le=100, description="Page size"),
    is_active: Optional[bool] = Query(None, description="Filter by active status"),
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    List all merchant partners (Admin only)
    
    Returns paginated list of merchants with optional filtering by active status.
    """
    try:
        merchant_service = MerchantService(supabase)
        merchants, total = await merchant_service.list_merchants(page, size, is_active)
        
        has_next = (page * size) < total
        
        return MerchantListResponse(
            merchants=merchants,
            total=total,
            page=page,
            size=size,
            has_next=has_next
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch merchants: {str(e)}"
        )


@router.get("/{merchant_id}", response_model=MerchantResponse)
async def get_merchant(
    merchant_id: UUID,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Get merchant by ID (Admin only)
    """
    try:
        merchant_service = MerchantService(supabase)
        merchant = await merchant_service.get_merchant_by_id(merchant_id)
        
        if not merchant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Merchant not found"
            )
        
        return merchant
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch merchant: {str(e)}"
        )


@router.put("/{merchant_id}", response_model=MerchantResponse)
async def update_merchant(
    merchant_id: UUID,
    merchant_data: MerchantUpdate,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Update merchant information (Admin only)
    """
    try:
        merchant_service = MerchantService(supabase)
        merchant = await merchant_service.update_merchant(merchant_id, merchant_data)
        
        if not merchant:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Merchant not found"
            )
        
        return merchant
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update merchant: {str(e)}"
        )


@router.delete("/{merchant_id}", status_code=status.HTTP_204_NO_CONTENT)
async def deactivate_merchant(
    merchant_id: UUID,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Deactivate merchant partnership (Admin only)
    
    This doesn't delete the merchant but sets is_active to False.
    """
    try:
        merchant_service = MerchantService(supabase)
        success = await merchant_service.deactivate_merchant(merchant_id)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Merchant not found"
            )
        
        return None
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to deactivate merchant: {str(e)}"
        )


@router.post("/{merchant_id}/regenerate-api-key")
async def regenerate_api_key(
    merchant_id: UUID,
    current_user=Depends(require_admin),
    supabase=Depends(get_supabase_admin_client)
):
    """
    Regenerate API key for merchant (Admin only)
    
    Returns the new API key. The old key will be immediately invalidated.
    """
    try:
        merchant_service = MerchantService(supabase)
        new_api_key = await merchant_service.regenerate_api_key(merchant_id)
        
        if not new_api_key:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Merchant not found"
            )
        
        return {"api_key": new_api_key, "message": "API key regenerated successfully"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to regenerate API key: {str(e)}"
        ) 