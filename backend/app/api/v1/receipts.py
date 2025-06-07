from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
from uuid import UUID
from datetime import datetime

from app.core.auth import get_current_user
from app.schemas.data_processing import (
    QRReceiptRequest, 
    QRReceiptResponse,
    ReceiptListResponse,
    ReceiptDetailResponse
)
from app.services.data_processor import DataProcessor
from app.services.qr_generator import QRGenerator
from app.db.supabase_client import get_authenticated_supabase_client
from supabase import Client

router = APIRouter()
data_processor = DataProcessor()
qr_generator = QRGenerator()

@router.post("/scan", response_model=QRReceiptResponse)
async def scan_qr_receipt(
    request: QRReceiptRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Process QR code data and create receipt with expenses
    """
    try:
        # First, check if this QR code contains a receipt ID (our own generated QR)
        receipt_id = qr_generator.parse_receipt_qr(request.qr_data)
        
        if receipt_id:
            # This is our own QR code, redirect to existing receipt
            receipt_response = supabase.table("receipts").select("*").eq("id", receipt_id).execute()
            
            if receipt_response.data:
                receipt = receipt_response.data[0]
                
                # Count expenses for this receipt
                expenses_response = supabase.table("expenses").select("id").eq("receipt_id", receipt_id).execute()
                expenses_count = len(expenses_response.data) if expenses_response.data else 0
                
                return QRReceiptResponse(
                    success=True,
                    message="Existing receipt found from QR code",
                    receipt_id=receipt_id,
                    merchant_name=receipt["merchant_name"],
                    total_amount=receipt["total_amount"],
                    currency=receipt["currency"],
                    expenses_count=expenses_count,
                    processing_confidence=1.0  # Perfect match for our own QR
                )
            else:
                raise HTTPException(status_code=404, detail="Receipt not found for this QR code")
        
        # If not our QR code, process as new receipt
        result = await data_processor.process_qr_receipt(
            qr_data=request.qr_data,
            user_id=current_user["id"]
        )
        
        if not result["success"]:
            raise HTTPException(status_code=400, detail=f"QR processing failed: {', '.join(result['errors'])}")
        
        # Create receipt in database
        receipt_data = result["receipt_data"]
        receipt_response = supabase.table("receipts").insert(receipt_data).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=500, detail="Failed to create receipt")
        
        receipt_id = receipt_response.data[0]["id"]
        
        # Create expense summary
        expense_data = result["expense_data"]
        expense_data["receipt_id"] = receipt_id
        
        expense_response = supabase.table("expenses").insert(expense_data).execute()
        
        if not expense_response.data:
            raise HTTPException(status_code=500, detail="Failed to create expense")
        
        expense_id = expense_response.data[0]["id"]
        
        # Create expense items
        items_created = 0
        for item in result["expense_items"]:
            item["expense_id"] = expense_id
            
            # Use suggested category if available
            if item.get("suggested_category_id"):
                item["category_id"] = item["suggested_category_id"]
            
            item_response = supabase.table("expense_items").insert(item).execute()
            
            if item_response.data:
                items_created += 1
        
        return QRReceiptResponse(
            success=True,
            message=f"Receipt processed successfully with {items_created} items",
            receipt_id=receipt_id,
            merchant_name=receipt_data.get("merchant_name"),
            total_amount=receipt_data.get("total_amount"),
            currency=receipt_data.get("currency", "TRY"),
            expenses_count=items_created,
            processing_confidence=0.8  # Default confidence for QR processing
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"QR processing failed: {str(e)}")

@router.get("", response_model=List[ReceiptListResponse])
async def list_receipts(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    merchant: Optional[str] = Query(None, description="Filter by merchant name"),
    date_from: Optional[datetime] = Query(None, description="Filter from date"),
    date_to: Optional[datetime] = Query(None, description="Filter to date"),
    min_amount: Optional[float] = Query(None, description="Minimum amount filter"),
    max_amount: Optional[float] = Query(None, description="Maximum amount filter"),
    sort_by: str = Query("transaction_date", description="Sort field"),
    sort_order: str = Query("desc", regex="^(asc|desc)$", description="Sort order"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    List user's receipts with filtering, pagination and sorting
    """
    try:
        # Build query (RLS will automatically filter by user_id)
        query = supabase.table("receipts").select("*")
        
        # Apply filters
        if merchant:
            query = query.ilike("merchant_name", f"%{merchant}%")
        
        if date_from:
            query = query.gte("transaction_date", date_from.isoformat())
        
        if date_to:
            query = query.lte("transaction_date", date_to.isoformat())
        
        if min_amount is not None:
            query = query.gte("total_amount", min_amount)
        
        if max_amount is not None:
            query = query.lte("total_amount", max_amount)
        
        # Apply sorting
        if sort_order == "desc":
            query = query.order(sort_by, desc=True)
        else:
            query = query.order(sort_by)
        
        # Apply pagination
        offset = (page - 1) * limit
        query = query.range(offset, offset + limit - 1)
        
        response = query.execute()
        
        receipts = []
        for receipt in response.data:
            receipts.append(ReceiptListResponse(
                id=receipt["id"],
                merchant_name=receipt["merchant_name"],
                transaction_date=receipt["transaction_date"],
                total_amount=receipt["total_amount"],
                currency=receipt["currency"],
                source=receipt["source"],
                created_at=receipt["created_at"]
            ))
        
        return receipts
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch receipts: {str(e)}")

@router.get("/{receipt_id}", response_model=ReceiptDetailResponse)
async def get_receipt_detail(
    receipt_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get detailed receipt information with expenses
    """
    try:
        # Get receipt
        receipt_response = supabase.table("receipts").select("*").eq("id", str(receipt_id)).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=404, detail="Receipt not found")
        
        receipt = receipt_response.data[0]
        
        # Get expense summary for this receipt
        expense_response = supabase.table("expenses").select("*").eq("receipt_id", str(receipt_id)).execute()
        
        expenses = []
        if expense_response.data:
            expense = expense_response.data[0]
            
            # Get expense items
            items_response = supabase.table("expense_items").select("""
                *,
                categories(id, name)
            """).eq("expense_id", expense["id"]).execute()
            
            expense_items = []
            for item in items_response.data:
                category_name = item.get("categories", {}).get("name") if item.get("categories") else None
                expense_items.append({
                    "id": item["id"],
                    "category_id": item["category_id"],
                    "category_name": category_name,
                    "description": item["description"],
                    "amount": item["amount"],
                    "quantity": item["quantity"],
                    "unit_price": item["unit_price"],
                    "notes": item["notes"]
                })
            
            expenses.append({
                "id": expense["id"],
                "total_amount": expense["total_amount"],
                "expense_date": expense["expense_date"],
                "notes": expense["notes"],
                "items": expense_items
            })
        
        return ReceiptDetailResponse(
            id=receipt["id"],
            merchant_name=receipt["merchant_name"],
            transaction_date=receipt["transaction_date"],
            total_amount=receipt["total_amount"],
            currency=receipt["currency"],
            source=receipt["source"],
            raw_qr_data=receipt["raw_qr_data"],
            parsed_receipt_data=receipt["parsed_receipt_data"],
            expenses=expenses,
            created_at=receipt["created_at"],
            updated_at=receipt["updated_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch receipt: {str(e)}") 