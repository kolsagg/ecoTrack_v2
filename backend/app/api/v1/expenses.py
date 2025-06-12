from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional
from uuid import UUID
from datetime import datetime

from app.core.auth import get_current_user
from app.schemas.data_processing import (
    ManualExpenseRequest,
    ExpenseResponse,
    ExpenseListResponse,
    ExpenseUpdateRequest,
    ExpenseItemResponse,
    ExpenseItemCreateRequest,
    ExpenseItemUpdateRequest
)
from app.services.data_processor import DataProcessor
from app.services.qr_generator import QRGenerator
from app.services.loyalty_service import LoyaltyService
from app.db.supabase_client import get_authenticated_supabase_client, get_authenticated_supabase_client
from app.utils.kdv_calculator import KDVCalculator
from supabase import Client

router = APIRouter()
data_processor = DataProcessor()
qr_generator = QRGenerator()
loyalty_service = LoyaltyService()

@router.post("", response_model=ExpenseResponse)
async def create_manual_expense(
    request: ManualExpenseRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create a manual expense entry with multiple items (auto-creates receipt)
    """
    try:
        # Calculate total amount from items
        total_amount = sum(item.amount for item in request.items)
        
        # Create receipt first
        receipt_data = {
            "user_id": current_user["id"],
            "merchant_name": request.merchant_name,
            "transaction_date": (request.expense_date or datetime.now()).isoformat(),
            "total_amount": total_amount,
            "currency": request.currency or "TRY",
            "source": "manual_entry"
        }
        
        receipt_response = supabase.table("receipts").insert(receipt_data).execute()
        
        if not receipt_response.data:
            raise HTTPException(status_code=500, detail="Failed to create receipt")
        
        receipt_id = receipt_response.data[0]["id"]
        
        # Create expense (summary/container)
        expense_data = {
            "receipt_id": receipt_id,
            "user_id": current_user["id"],
            "total_amount": total_amount,
            "expense_date": (request.expense_date or datetime.now()).isoformat(),
            "notes": request.notes
        }
        
        expense_response = supabase.table("expenses").insert(expense_data).execute()
        
        if not expense_response.data:
            raise HTTPException(status_code=500, detail="Failed to create expense")
        
        expense = expense_response.data[0]
        expense_id = expense["id"]
        
        # Create expense items
        expense_items = []
        for item_request in request.items:
            # Use AI categorizer for each item
            suggested_category = await data_processor.ai_categorizer.categorize_expense(
                description=item_request.item_name,
                merchant_name=request.merchant_name,
                amount=item_request.amount
            )
            
            # Debug: Print AI categorization result
            print(f"AI categorization for '{item_request.item_name}': {suggested_category}")
            
            # Use AI category if no category provided by user
            final_category_id = item_request.category_id
            if not final_category_id and suggested_category:
                # Convert AI category name to category_id by looking up in database
                ai_category_name = suggested_category.get("category_name")
                if ai_category_name:
                    category_lookup = supabase.table("categories").select("id").eq("name", ai_category_name).execute()
                    if category_lookup.data:
                        final_category_id = category_lookup.data[0]["id"]
                        print(f"Using AI suggested category: {ai_category_name} (ID: {final_category_id})")
                    else:
                        print(f"AI suggested category '{ai_category_name}' not found in database")
                else:
                    print("AI categorization did not return category_name")
            else:
                print(f"Using user provided category: {final_category_id}")
            
            # Calculate unit_price if not provided
            unit_price = item_request.unit_price
            if unit_price is None and item_request.quantity and item_request.quantity > 0:
                unit_price = item_request.amount / item_request.quantity
            
            item_data = {
                "expense_id": expense_id,
                "user_id": current_user["id"],
                "category_id": final_category_id,
                "description": item_request.item_name,
                "amount": item_request.amount,
                "quantity": item_request.quantity,
                "unit_price": unit_price,
                "kdv_rate": item_request.kdv_rate,
                "notes": item_request.notes
            }
            
            item_response = supabase.table("expense_items").insert(item_data).execute()
            
            if not item_response.data:
                raise HTTPException(status_code=500, detail=f"Failed to create expense item: {item_request.item_name}")
            
            item = item_response.data[0]
            
            # Get category name
            category_name = None
            if item["category_id"]:
                category_response = supabase.table("categories").select("name").eq("id", item["category_id"]).execute()
                if category_response.data:
                    category_name = category_response.data[0]["name"]
            
            # Calculate KDV breakdown
            kdv_rate = item.get("kdv_rate", 20.0)
            kdv_breakdown = KDVCalculator.get_kdv_breakdown(item["amount"], kdv_rate)
            
            expense_items.append(ExpenseItemResponse(
                id=item["id"],
                expense_id=item["expense_id"],
                category_id=item["category_id"],
                category_name=category_name,
                item_name=item["description"],
                amount=item["amount"],
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                kdv_rate=kdv_rate,
                kdv_amount=kdv_breakdown["kdv_amount"],
                amount_without_kdv=kdv_breakdown["amount_without_kdv"],
                notes=item["notes"],
                created_at=item["created_at"],
                updated_at=item["updated_at"]
            ))
        
        # Generate QR code for the receipt
        receipt = receipt_response.data[0]
        qr_code = qr_generator.generate_receipt_qr(
            receipt_id=str(receipt_id),
            merchant_name=receipt["merchant_name"],
            total_amount=receipt["total_amount"],
            currency=receipt["currency"],
            transaction_date=datetime.fromisoformat(receipt["transaction_date"].replace('Z', '+00:00'))
        )
        
        # Award loyalty points for the expense
        try:
            # Get the primary category from the first item (or most expensive item)
            primary_category = None
            if expense_items:
                # Find the item with highest amount for primary category
                max_amount_item = max(expense_items, key=lambda x: x.amount)
                if max_amount_item.category_id:
                    category_response = supabase.table("categories").select("name").eq("id", max_amount_item.category_id).execute()
                    if category_response.data:
                        primary_category = category_response.data[0]["name"]
            
            loyalty_result = await loyalty_service.award_points_for_expense(
                user_id=current_user["id"],
                expense_id=expense["id"],
                amount=total_amount,
                category=primary_category,
                merchant_name=request.merchant_name
            )
            
            if loyalty_result["success"]:
                print(f"Loyalty points awarded: {loyalty_result['points_awarded']} points")
                
        except Exception as loyalty_error:
            # Don't fail the expense creation if loyalty points fail
            print(f"Failed to award loyalty points: {str(loyalty_error)}")
        
        return ExpenseResponse(
            id=expense["id"],
            receipt_id=receipt_id,
            total_amount=expense["total_amount"],
            expense_date=expense["expense_date"],
            notes=expense["notes"],
            merchant_name=request.merchant_name,
            items=expense_items,
            qr_code=qr_code,
            created_at=expense["created_at"],
            updated_at=expense["updated_at"]
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create expense: {str(e)}")

@router.get("", response_model=List[ExpenseListResponse])
async def list_expenses(
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    merchant: Optional[str] = Query(None, description="Filter by merchant name"),
    date_from: Optional[datetime] = Query(None, description="Filter from date"),
    date_to: Optional[datetime] = Query(None, description="Filter to date"),
    min_amount: Optional[float] = Query(None, description="Minimum amount filter"),
    max_amount: Optional[float] = Query(None, description="Maximum amount filter"),
    sort_by: str = Query("expense_date", description="Sort field"),
    sort_order: str = Query("desc", pattern="^(asc|desc)$", description="Sort order"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    List user's expenses (summary) with filtering, pagination and sorting
    """
    try:
        # Build query with joins
        query = supabase.table("expenses").select("""
            *,
            receipts(merchant_name, source)
        """)
        
        # Apply filters
        if date_from:
            query = query.gte("expense_date", date_from.isoformat())
        
        if date_to:
            query = query.lte("expense_date", date_to.isoformat())
        
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
        
        expenses = []
        for expense in response.data:
            # Filter by merchant if specified (since we can't filter joins directly)
            if merchant:
                receipt_merchant = expense.get("receipts", {}).get("merchant_name", "")
                if merchant.lower() not in receipt_merchant.lower():
                    continue
            
            merchant_name = expense.get("receipts", {}).get("merchant_name")
            source = expense.get("receipts", {}).get("source")
            
            # Count expense items
            items_response = supabase.table("expense_items").select("id").eq("expense_id", expense["id"]).execute()
            items_count = len(items_response.data) if items_response.data else 0
            
            expenses.append(ExpenseListResponse(
                id=expense["id"],
                receipt_id=expense["receipt_id"],
                total_amount=expense["total_amount"],
                expense_date=expense["expense_date"],
                notes=expense["notes"],
                items_count=items_count,
                merchant_name=merchant_name,
                source=source,
                created_at=expense["created_at"]
            ))
        
        return expenses
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch expenses: {str(e)}")

@router.get("/{expense_id}", response_model=ExpenseResponse)
async def get_expense(
    expense_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get a specific expense by ID with all items
    """
    try:
        # Get expense summary with receipt info
        expense_response = supabase.table("expenses").select("""
            *,
            receipts(merchant_name, source)
        """).eq("id", str(expense_id)).execute()
        
        if not expense_response.data:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        expense = expense_response.data[0]
        merchant_name = expense.get("receipts", {}).get("merchant_name")
        
        # Get expense items with categories
        items_response = supabase.table("expense_items").select("""
            *,
            categories(id, name)
        """).eq("expense_id", str(expense_id)).execute()
        
        expense_items = []
        for item in items_response.data:
            category_name = item.get("categories", {}).get("name") if item.get("categories") else None
            
            # Calculate KDV breakdown
            kdv_rate = item.get("kdv_rate", 20.0)
            kdv_breakdown = KDVCalculator.get_kdv_breakdown(item["amount"], kdv_rate)
            
            expense_items.append(ExpenseItemResponse(
                id=item["id"],
                expense_id=item["expense_id"],
                category_id=item["category_id"],
                category_name=category_name,
                item_name=item["description"],
                amount=item["amount"],
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                kdv_rate=kdv_rate,
                kdv_amount=kdv_breakdown["kdv_amount"],
                amount_without_kdv=kdv_breakdown["amount_without_kdv"],
                notes=item["notes"],
                created_at=item["created_at"],
                updated_at=item["updated_at"]
            ))
        
        return ExpenseResponse(
            id=expense["id"],
            receipt_id=expense["receipt_id"],
            total_amount=expense["total_amount"],
            expense_date=expense["expense_date"],
            notes=expense["notes"],
            merchant_name=merchant_name,
            items=expense_items,
            qr_code=None,  # QR code can be generated on demand
            created_at=expense["created_at"],
            updated_at=expense["updated_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch expense: {str(e)}")

@router.put("/{expense_id}", response_model=ExpenseResponse)
async def update_expense(
    expense_id: UUID,
    request: ExpenseUpdateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Update an existing expense (summary level only)
    """
    try:
        # Check if expense exists and belongs to user
        existing_response = supabase.table("expenses").select("""
            *,
            receipts(source)
        """).eq("id", str(expense_id)).execute()
        
        if not existing_response.data:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        # Check if expense is manually created (only manual expenses can be updated)
        expense = existing_response.data[0]
        receipt_source = expense.get("receipts", {}).get("source")
        if receipt_source != "manual_entry":
            raise HTTPException(status_code=403, detail="Only manually created expenses can be updated")
        
        # Prepare update data (only include non-None values)
        update_data = {}
        if request.expense_date is not None:
            update_data["expense_date"] = request.expense_date.isoformat() if hasattr(request.expense_date, 'isoformat') else request.expense_date
        if request.notes is not None:
            update_data["notes"] = request.notes
        
        # Update merchant name in receipt if provided
        receipt_update_data = {}
        if request.merchant_name is not None:
            receipt_update_data["merchant_name"] = request.merchant_name
        
        if not update_data and not receipt_update_data:
            raise HTTPException(status_code=400, detail="No fields to update")
        
        # Update expense if there's expense data to update
        if update_data:
            update_data["updated_at"] = datetime.now().isoformat()
            response = supabase.table("expenses").update(update_data).eq("id", str(expense_id)).execute()
            
            if not response.data:
                raise HTTPException(status_code=500, detail="Failed to update expense")
            
            expense = response.data[0]
        else:
            expense = existing_response.data[0]
        
        # Update receipt if merchant name is provided
        if receipt_update_data:
            receipt_update_data["updated_at"] = datetime.now().isoformat()
            receipt_response = supabase.table("receipts").update(receipt_update_data).eq("id", expense["receipt_id"]).execute()
            
            if not receipt_response.data:
                raise HTTPException(status_code=500, detail="Failed to update merchant name")
        
        # Get current merchant name from receipt
        receipt_response = supabase.table("receipts").select("merchant_name").eq("id", expense["receipt_id"]).execute()
        merchant_name = receipt_response.data[0]["merchant_name"] if receipt_response.data else None
        
        # Get expense items with categories
        items_response = supabase.table("expense_items").select("""
            *,
            categories(id, name)
        """).eq("expense_id", str(expense_id)).execute()
        
        expense_items = []
        for item in items_response.data:
            category_name = item.get("categories", {}).get("name") if item.get("categories") else None
            
            # Calculate KDV breakdown
            kdv_rate = item.get("kdv_rate", 20.0)
            kdv_breakdown = KDVCalculator.get_kdv_breakdown(item["amount"], kdv_rate)
            
            expense_items.append(ExpenseItemResponse(
                id=item["id"],
                expense_id=item["expense_id"],
                category_id=item["category_id"],
                category_name=category_name,
                item_name=item["description"],
                amount=item["amount"],
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                kdv_rate=kdv_rate,
                kdv_amount=kdv_breakdown["kdv_amount"],
                amount_without_kdv=kdv_breakdown["amount_without_kdv"],
                notes=item["notes"],
                created_at=item["created_at"],
                updated_at=item["updated_at"]
            ))
        
        return ExpenseResponse(
            id=expense["id"],
            receipt_id=expense["receipt_id"],
            total_amount=expense["total_amount"],
            expense_date=expense["expense_date"],
            notes=expense["notes"],
            merchant_name=merchant_name,
            items=expense_items,
            qr_code=None,
            created_at=expense["created_at"],
            updated_at=expense["updated_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update expense: {str(e)}")

@router.delete("/{expense_id}")
async def delete_expense(
    expense_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Delete an expense and all its items
    """
    try:
        # Check if expense exists and belongs to user
        existing_response = supabase.table("expenses").select("""
            *,
            receipts(source)
        """).eq("id", str(expense_id)).execute()
        
        if not existing_response.data:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        # Check if expense is manually created (only manual expenses can be deleted)
        expense = existing_response.data[0]
        receipt_source = expense.get("receipts", {}).get("source")
        if receipt_source != "manual_entry":
            raise HTTPException(status_code=403, detail="Only manually created expenses can be deleted")
        
        # Delete expense items first (due to foreign key constraint)
        items_response = supabase.table("expense_items").delete().eq("expense_id", str(expense_id)).execute()
        
        # Delete expense
        response = supabase.table("expenses").delete().eq("id", str(expense_id)).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to delete expense")
        
        return {"message": "Expense and all items deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete expense: {str(e)}")

# Expense Items Endpoints

@router.post("/{expense_id}/items", response_model=ExpenseItemResponse)
async def create_expense_item(
    expense_id: UUID,
    request: ExpenseItemCreateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Add a new item to an existing expense
    """
    try:
        # Check if expense exists and belongs to user
        expense_response = supabase.table("expenses").select("""
            *,
            receipts(source)
        """).eq("id", str(expense_id)).execute()
        
        if not expense_response.data:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        # Check if expense is manually created (only manual expenses can have items added)
        expense = expense_response.data[0]
        receipt_source = expense.get("receipts", {}).get("source")
        if receipt_source != "manual_entry":
            raise HTTPException(status_code=403, detail="Items can only be added to manually created expenses")
        
        # Use AI categorizer if no category provided
        category_id = request.category_id
        if not category_id:
            # Get merchant name from receipt
            receipt_response = supabase.table("receipts").select("merchant_name").eq("id", expense_response.data[0]["receipt_id"]).execute()
            merchant_name = receipt_response.data[0]["merchant_name"] if receipt_response.data else None
            
            suggested_category = await data_processor.ai_categorizer.categorize_expense(
                description=request.item_name,
                merchant_name=merchant_name,
                amount=request.amount
            )
            
            # Convert AI category name to category_id
            category_id = None
            if suggested_category:
                ai_category_name = suggested_category.get("category_name")
                if ai_category_name:
                    category_lookup = supabase.table("categories").select("id").eq("name", ai_category_name).execute()
                    if category_lookup.data:
                        category_id = category_lookup.data[0]["id"]
        
        # Calculate unit_price if not provided
        unit_price = request.unit_price
        if unit_price is None and request.quantity and request.quantity > 0:
            unit_price = request.amount / request.quantity
        
        # Create expense item
        item_data = {
            "expense_id": str(expense_id),
            "user_id": current_user["id"],
            "category_id": category_id,
            "description": request.item_name,
            "amount": request.amount,
            "quantity": request.quantity,
            "unit_price": unit_price,
            "kdv_rate": request.kdv_rate,
            "notes": request.notes
        }
        
        item_response = supabase.table("expense_items").insert(item_data).execute()
        
        if not item_response.data:
            raise HTTPException(status_code=500, detail="Failed to create expense item")
        
        item = item_response.data[0]
        
        # Update expense total_amount
        items_total_response = supabase.table("expense_items").select("amount").eq("expense_id", str(expense_id)).execute()
        total_amount = sum(item["amount"] for item in items_total_response.data)
        
        supabase.table("expenses").update({"total_amount": total_amount}).eq("id", str(expense_id)).execute()
        
        # Get category name
        category_name = None
        if item["category_id"]:
            category_response = supabase.table("categories").select("name").eq("id", item["category_id"]).execute()
            if category_response.data:
                category_name = category_response.data[0]["name"]
        
        # Calculate KDV breakdown
        kdv_rate = item.get("kdv_rate", 20.0)
        kdv_breakdown = KDVCalculator.get_kdv_breakdown(item["amount"], kdv_rate)
        
        return ExpenseItemResponse(
            id=item["id"],
            expense_id=item["expense_id"],
            category_id=item["category_id"],
            category_name=category_name,
            item_name=item["description"],
            amount=item["amount"],
            quantity=item["quantity"],
            unit_price=item["unit_price"],
            kdv_rate=kdv_rate,
            kdv_amount=kdv_breakdown["kdv_amount"],
            amount_without_kdv=kdv_breakdown["amount_without_kdv"],
            notes=item["notes"],
            created_at=item["created_at"],
            updated_at=item["updated_at"]
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create expense item: {str(e)}")

@router.put("/{expense_id}/items/{item_id}", response_model=ExpenseItemResponse)
async def update_expense_item(
    expense_id: UUID,
    item_id: UUID,
    request: ExpenseItemUpdateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Update an expense item
    """
    try:
        # Check if item exists and belongs to the expense
        existing_response = supabase.table("expense_items").select("*").eq("id", str(item_id)).eq("expense_id", str(expense_id)).execute()
        
        if not existing_response.data:
            raise HTTPException(status_code=404, detail="Expense item not found")
        
        # Check if expense is manually created (only manual expenses can have items updated)
        expense_response = supabase.table("expenses").select("""
            *,
            receipts(source)
        """).eq("id", str(expense_id)).execute()
        
        if expense_response.data:
            expense = expense_response.data[0]
            receipt_source = expense.get("receipts", {}).get("source")
            if receipt_source != "manual_entry":
                raise HTTPException(status_code=403, detail="Items can only be updated in manually created expenses")
        
        # Prepare update data
        update_data = {}
        if request.category_id is not None:
            update_data["category_id"] = request.category_id
        if request.item_name is not None:
            update_data["description"] = request.item_name
        if request.amount is not None:
            update_data["amount"] = request.amount
        if request.quantity is not None:
            update_data["quantity"] = request.quantity
        if request.unit_price is not None:
            update_data["unit_price"] = request.unit_price
        if request.kdv_rate is not None:
            update_data["kdv_rate"] = request.kdv_rate
        if request.notes is not None:
            update_data["notes"] = request.notes
        
        # Calculate unit_price if not provided but amount and quantity are being updated
        if request.unit_price is None and request.amount is not None and request.quantity is not None and request.quantity > 0:
            update_data["unit_price"] = request.amount / request.quantity
        elif request.unit_price is None and request.amount is not None and request.quantity is None:
            # If only amount is updated, get current quantity to calculate unit_price
            current_item = existing_response.data[0]
            current_quantity = current_item.get("quantity")
            if current_quantity and current_quantity > 0:
                update_data["unit_price"] = request.amount / current_quantity
        elif request.unit_price is None and request.amount is None and request.quantity is not None and request.quantity > 0:
            # If only quantity is updated, get current amount to calculate unit_price
            current_item = existing_response.data[0]
            current_amount = current_item.get("amount")
            if current_amount:
                update_data["unit_price"] = current_amount / request.quantity
        
        if not update_data:
            raise HTTPException(status_code=400, detail="No fields to update")
        
        update_data["updated_at"] = datetime.now().isoformat()
        
        # Update item
        response = supabase.table("expense_items").update(update_data).eq("id", str(item_id)).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to update expense item")
        
        item = response.data[0]
        
        # Update expense total_amount
        items_total_response = supabase.table("expense_items").select("amount").eq("expense_id", str(expense_id)).execute()
        total_amount = sum(item["amount"] for item in items_total_response.data)
        
        supabase.table("expenses").update({"total_amount": total_amount}).eq("id", str(expense_id)).execute()
        
        # Get category name
        category_name = None
        if item["category_id"]:
            category_response = supabase.table("categories").select("name").eq("id", item["category_id"]).execute()
            if category_response.data:
                category_name = category_response.data[0]["name"]
        
        # Calculate KDV breakdown
        kdv_rate = item.get("kdv_rate", 20.0)
        kdv_breakdown = KDVCalculator.get_kdv_breakdown(item["amount"], kdv_rate)
        
        return ExpenseItemResponse(
            id=item["id"],
            expense_id=item["expense_id"],
            category_id=item["category_id"],
            category_name=category_name,
            item_name=item["description"],
            amount=item["amount"],
            quantity=item["quantity"],
            unit_price=item["unit_price"],
            kdv_rate=kdv_rate,
            kdv_amount=kdv_breakdown["kdv_amount"],
            amount_without_kdv=kdv_breakdown["amount_without_kdv"],
            notes=item["notes"],
            created_at=item["created_at"],
            updated_at=item["updated_at"]
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update expense item: {str(e)}")

@router.delete("/{expense_id}/items/{item_id}")
async def delete_expense_item(
    expense_id: UUID,
    item_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Delete an expense item
    """
    try:
        # Check if item exists and belongs to the expense
        existing_response = supabase.table("expense_items").select("*").eq("id", str(item_id)).eq("expense_id", str(expense_id)).execute()
        
        if not existing_response.data:
            raise HTTPException(status_code=404, detail="Expense item not found")
        
        # Check if expense is manually created (only manual expenses can have items deleted)
        expense_response = supabase.table("expenses").select("""
            *,
            receipts(source)
        """).eq("id", str(expense_id)).execute()
        
        if expense_response.data:
            expense = expense_response.data[0]
            receipt_source = expense.get("receipts", {}).get("source")
            if receipt_source != "manual_entry":
                raise HTTPException(status_code=403, detail="Items can only be deleted from manually created expenses")
        
        # Delete item
        response = supabase.table("expense_items").delete().eq("id", str(item_id)).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to delete expense item")
        
        # Update expense total_amount
        items_total_response = supabase.table("expense_items").select("amount").eq("expense_id", str(expense_id)).execute()
        total_amount = sum(item["amount"] for item in items_total_response.data) if items_total_response.data else 0
        
        supabase.table("expenses").update({"total_amount": total_amount}).eq("id", str(expense_id)).execute()
        
        return {"message": "Expense item deleted successfully"}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete expense item: {str(e)}")

@router.get("/{expense_id}/items", response_model=List[ExpenseItemResponse])
async def list_expense_items(
    expense_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    List all items for a specific expense
    """
    try:
        # Check if expense exists
        expense_response = supabase.table("expenses").select("*").eq("id", str(expense_id)).execute()
        
        if not expense_response.data:
            raise HTTPException(status_code=404, detail="Expense not found")
        
        # Get expense items with categories
        items_response = supabase.table("expense_items").select("""
            *,
            categories(id, name)
        """).eq("expense_id", str(expense_id)).execute()
        
        expense_items = []
        for item in items_response.data:
            category_name = item.get("categories", {}).get("name") if item.get("categories") else None
            
            # Calculate KDV breakdown
            kdv_rate = item.get("kdv_rate", 20.0)
            kdv_breakdown = KDVCalculator.get_kdv_breakdown(item["amount"], kdv_rate)
            
            expense_items.append(ExpenseItemResponse(
                id=item["id"],
                expense_id=item["expense_id"],
                category_id=item["category_id"],
                category_name=category_name,
                item_name=item["description"],
                amount=item["amount"],
                quantity=item["quantity"],
                unit_price=item["unit_price"],
                kdv_rate=kdv_rate,
                kdv_amount=kdv_breakdown["kdv_amount"],
                amount_without_kdv=kdv_breakdown["amount_without_kdv"],
                notes=item["notes"],
                created_at=item["created_at"],
                updated_at=item["updated_at"]
            ))
        
        return expense_items
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch expense items: {str(e)}") 