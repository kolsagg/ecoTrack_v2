"""
Budget Management API Endpoints
Handles monthly budget creation, allocation, and management
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional, Dict, Any
from datetime import datetime

from app.core.auth import get_current_user
from app.schemas.budget import (
    UserBudgetCreate, UserBudgetUpdate, UserBudgetResponse,
    BudgetCategoryCreate, BudgetCategoryUpdate, BudgetCategoryResponse,
    BudgetAllocationRequest, BudgetAllocationResponse,
    BudgetSummaryResponse
)
from app.services.budget_service import BudgetService
from app.db.supabase_client import get_authenticated_supabase_client
from supabase import Client

router = APIRouter()


def get_current_year_month(year: Optional[int] = None, month: Optional[int] = None) -> tuple[int, int]:
    """Get current year and month, using provided values or defaults to current date"""
    now = datetime.now()
    return (year or now.year, month or now.month)


async def get_user_budget_for_month(
    supabase: Client, 
    user_id: str, 
    year: int, 
    month: int
) -> Optional[Dict[str, Any]]:
    """Get user's budget for a specific month/year"""
    result = supabase.table("user_budgets").select("*").eq("user_id", user_id).eq("year", year).eq("month", month).execute()
    return result.data[0] if result.data else None


@router.post("/", summary="Create Monthly Budget")
async def create_user_budget(
    budget_data: UserBudgetCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create or update user's monthly budget for a specific month/year
    
    **Features:**
    - Sets total monthly budget amount for specific month/year
    - Optionally auto-allocates budget to categories based on research
    - Supports different currencies
    - If year/month not provided, uses current month
    """
    try:
        year, month = get_current_year_month(budget_data.year, budget_data.month)
        
        # Check if user already has a budget for this month
        existing_budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if existing_budget:
            # Update existing budget
            update_data = {
                "total_monthly_budget": budget_data.total_monthly_budget,
                "currency": budget_data.currency,
                "auto_allocate": budget_data.auto_allocate,
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("user_budgets").update(update_data).eq("id", existing_budget["id"]).execute()
            
            if not result.data:
                raise HTTPException(status_code=400, detail="Failed to update budget")
            
            return {
                "status": "success",
                "budget": result.data[0],
                "message": f"Budget updated successfully for {month:02d}/{year}"
            }
        else:
            # Create new budget
            budget_record = {
                "user_id": current_user["id"],
                "total_monthly_budget": budget_data.total_monthly_budget,
                "currency": budget_data.currency,
                "auto_allocate": budget_data.auto_allocate,
                "year": year,
                "month": month,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("user_budgets").insert(budget_record).execute()
            
            if not result.data:
                raise HTTPException(status_code=400, detail="Failed to create budget")
            
            return {
                "status": "success",
                "budget": result.data[0],
                "message": f"Budget created successfully for {month:02d}/{year}"
            }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create budget: {str(e)}")


@router.get("/", summary="Get Monthly Budget")
async def get_user_budget(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    year: Optional[int] = Query(None, description="Budget year (defaults to current year)"),
    month: Optional[int] = Query(None, description="Budget month (defaults to current month)")
):
    """
    Get user's budget for a specific month/year
    """
    try:
        year, month = get_current_year_month(year, month)
        
        budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not budget:
            raise HTTPException(
                status_code=404, 
                detail=f"No budget found for {month:02d}/{year}"
            )
        
        return {
            "status": "success",
            "budget": budget
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get budget: {str(e)}")


@router.put("/", summary="Update Monthly Budget")
async def update_user_budget(
    budget_data: UserBudgetUpdate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    year: Optional[int] = Query(None, description="Budget year (defaults to current year)"),
    month: Optional[int] = Query(None, description="Budget month (defaults to current month)")
):
    """
    Update user's budget for a specific month/year
    
    **Note:** If total budget amount changes and auto_allocate is enabled,
    category budgets will be automatically re-allocated.
    """
    try:
        year, month = get_current_year_month(year, month)
        
        budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not budget:
            raise HTTPException(
                status_code=404, 
                detail=f"No budget found for {month:02d}/{year}. Please create a budget first."
            )
        
        update_data = {k: v for k, v in budget_data.dict().items() if v is not None}
        update_data["updated_at"] = datetime.now().isoformat()
        
        result = supabase.table("user_budgets").update(update_data).eq("id", budget["id"]).execute()
        
        if not result.data:
            raise HTTPException(status_code=400, detail="Failed to update budget")
        
        return {
            "status": "success",
            "budget": result.data[0],
            "message": f"Budget updated successfully for {month:02d}/{year}"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update budget: {str(e)}")


@router.post("/categories", summary="Create Category Budget")
async def create_category_budget(
    category_data: BudgetCategoryCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    year: Optional[int] = Query(None, description="Budget year (defaults to current year)"),
    month: Optional[int] = Query(None, description="Budget month (defaults to current month)")
):
    """
    Create or update budget for a specific category in a specific month/year
    
    **Usage:**
    - Set monthly spending limit for each category
    - Enable/disable budget tracking per category
    
    **Important:**
    - Total category budgets cannot exceed 100% of your total monthly budget
    - System will check available budget before creating/updating
    - Returns error if allocation would exceed total budget
    """
    try:
        year, month = get_current_year_month(year, month)
        
        # Get user's budget for this month first
        user_budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not user_budget:
            raise HTTPException(
                status_code=404, 
                detail=f"User budget not found for {month:02d}/{year}. Please create a budget first."
            )
        
        user_budget_id = user_budget["id"]
        total_budget = float(user_budget["total_monthly_budget"])
        
        # Check if category budget already exists for this month
        existing = supabase.table("budget_categories").select("*").eq("user_budget_id", user_budget_id).eq("category_id", category_data.category_id).execute()
        
        # Calculate current total allocated amount (excluding this category if updating)
        all_budgets = supabase.table("budget_categories").select("monthly_limit").eq("user_budget_id", user_budget_id).eq("is_active", True).execute()
        
        current_total = 0
        if all_budgets.data:
            for budget in all_budgets.data:
                # If updating existing, exclude the old amount
                if existing.data and budget.get("id") != existing.data[0]["id"]:
                    current_total += float(budget["monthly_limit"])
                elif not existing.data:  # If creating new
                    current_total += float(budget["monthly_limit"])
        
        # Check if new allocation would exceed 100%
        new_total = current_total + category_data.monthly_limit
        if new_total > total_budget:
            remaining_budget = total_budget - current_total
            percentage_used = (current_total / total_budget * 100) if total_budget > 0 else 0
            raise HTTPException(
                status_code=400, 
                detail=f"Budget allocation would exceed total budget for {month:02d}/{year}. "
                       f"Current allocation: {percentage_used:.1f}% ({current_total:.2f} TL), "
                       f"Available: {remaining_budget:.2f} TL, "
                       f"Requested: {category_data.monthly_limit:.2f} TL"
            )
        
        if existing.data:
            # Update existing
            update_data = {
                "monthly_limit": category_data.monthly_limit,
                "is_active": category_data.is_active,
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("budget_categories").update(update_data).eq("id", existing.data[0]["id"]).execute()
            message = f"Category budget updated successfully for {month:02d}/{year}"
        else:
            # Create new
            budget_record = {
                "user_budget_id": user_budget_id,
                "category_id": category_data.category_id,
                "monthly_limit": category_data.monthly_limit,
                "is_active": category_data.is_active,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("budget_categories").insert(budget_record).execute()
            message = f"Category budget created successfully for {month:02d}/{year}"
        
        if not result.data:
            raise HTTPException(status_code=400, detail="Failed to save category budget")
        
        return {
            "status": "success",
            "category_budget": result.data[0],
            "message": message
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create category budget: {str(e)}")


@router.get("/categories", summary="Get Category Budgets")
async def get_category_budgets(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    year: Optional[int] = Query(None, description="Budget year (defaults to current year)"),
    month: Optional[int] = Query(None, description="Budget month (defaults to current month)")
):
    """
    Get all active category budgets for the user for a specific month/year
    """
    try:
        year, month = get_current_year_month(year, month)
        
        # Get user's budget for this month first
        user_budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not user_budget:
            return {
                "status": "success",
                "category_budgets": [],
                "message": f"No budget found for {month:02d}/{year}"
            }
        
        # Get category budgets with category names using proper join
        budget_result = supabase.table("budget_categories").select(
            "*, categories(name)"
        ).eq("user_budget_id", user_budget["id"]).eq("is_active", True).execute()
        
        if not budget_result.data:
            return {
                "status": "success",
                "category_budgets": []
            }
        
        category_budgets = []
        for item in budget_result.data:
            category_budgets.append({
                "id": item["id"],
                "user_budget_id": item["user_budget_id"],
                "category_id": item["category_id"],
                "category_name": item.get("categories", {}).get("name", "Unknown") if item.get("categories") else "Unknown",
                "monthly_limit": item["monthly_limit"],
                "is_active": item["is_active"],
                "created_at": item["created_at"],
                "updated_at": item["updated_at"]
            })
        
        return {
            "status": "success",
            "category_budgets": category_budgets,
            "year": year,
            "month": month
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get category budgets: {str(e)}")


@router.get("/summary", summary="Get Monthly Budget Summary")
async def get_budget_summary(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    year: Optional[int] = Query(None, description="Budget year (defaults to current year)"),
    month: Optional[int] = Query(None, description="Budget month (defaults to current month)")
):
    """
    Get comprehensive budget summary for a specific month/year including:
    - Monthly budget information
    - Category-wise budget allocations
    - Total allocated vs remaining budget
    - Allocation percentage
    """
    try:
        year, month = get_current_year_month(year, month)
        
        # Get user's budget for this month
        user_budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not user_budget:
            raise HTTPException(
                status_code=404, 
                detail=f"No budget found for {month:02d}/{year}"
            )
        
        # Get category budgets with category names
        category_result = supabase.table("budget_categories").select(
            "*, categories(name)"
        ).eq("user_budget_id", user_budget["id"]).eq("is_active", True).execute()
        
        # Calculate totals
        total_allocated = sum(float(cb["monthly_limit"]) for cb in category_result.data or [])
        total_budget = float(user_budget["total_monthly_budget"])
        remaining_budget = total_budget - total_allocated
        allocation_percentage = (total_allocated / total_budget * 100) if total_budget > 0 else 0
        
        # Format category budgets
        category_budgets = []
        for cb in category_result.data or []:
            category_budgets.append({
                "id": cb["id"],
                "category_id": cb["category_id"],
                "category_name": cb.get("categories", {}).get("name", "Unknown") if cb.get("categories") else "Unknown",
                "monthly_limit": cb["monthly_limit"],
                "percentage": (float(cb["monthly_limit"]) / total_budget * 100) if total_budget > 0 else 0
            })
        
        return {
            "status": "success",
            "summary": {
                "total_budget": total_budget,
                "total_allocated": total_allocated,
                "remaining_budget": remaining_budget,
                "allocation_percentage": round(allocation_percentage, 2),
                "is_over_allocated": allocation_percentage > 100,
                "currency": user_budget["currency"],
                "auto_allocate": user_budget["auto_allocate"],
                "category_count": len(category_budgets),
                "year": year,
                "month": month
            },
            "category_budgets": category_budgets,
            "warning": "Budget allocation exceeds 100%" if allocation_percentage > 100 else None
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get budget summary: {str(e)}")


@router.post("/apply-allocation", summary="Apply Budget Allocation")
async def apply_budget_allocation(
    allocation_request: BudgetAllocationRequest,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Apply optimal budget allocation to user's system category budgets for a specific month/year
    
    **This will:**
    1. Generate optimal allocation for system categories (total 100%)
    2. Create/update category budgets with suggested amounts (system categories only)
    3. Return the applied allocation
    
    **Note:** 
    - Only applies to predefined system categories, custom categories are not affected
    - Total allocation will be exactly 100% of the specified budget
    - Existing system category budgets will be updated, custom category budgets remain unchanged
    """
    try:
        year, month = get_current_year_month(allocation_request.year, allocation_request.month)
        
        # Get or create user's budget for this month
        user_budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not user_budget:
            # Create a budget for this month with the requested amount
            budget_record = {
                "user_id": current_user["id"],
                "total_monthly_budget": allocation_request.total_budget,
                "currency": "TRY",
                "auto_allocate": True,
                "year": year,
                "month": month,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("user_budgets").insert(budget_record).execute()
            if not result.data:
                raise HTTPException(status_code=400, detail="Failed to create budget")
            
            user_budget = result.data[0]
        
        user_budget_id = user_budget["id"]
        
        # Optimal budget allocation percentages based on financial research
        optimal_allocations = {
            "Groceries": 0.06, "Dining Out": 0.06, "Transportation": 0.12, "Shopping": 0.10, "Entertainment": 0.08,
            "Healthcare": 0.08, "Education": 0.06, "Utilities": 0.08, "Travel": 0.05,
            "Personal Care": 0.06, "Other": 0.25
        }
        
        # Get only system categories for allocation
        categories_result = supabase.table("categories").select("id, name").eq("is_system", True).execute()
        available_categories = {cat["name"]: cat["id"] for cat in categories_result.data or []}
        
        # Apply allocation to category budgets
        applied_count = 0
        total_budget = allocation_request.total_budget
        
        for category_name, percentage in optimal_allocations.items():
            if category_name in available_categories:
                category_id = available_categories[category_name]
                amount = round(total_budget * percentage, 2)
                
                # Check if category budget already exists for this month
                existing = supabase.table("budget_categories").select("*").eq("user_budget_id", user_budget_id).eq("category_id", category_id).execute()
                
                if existing.data:
                    # Update existing
                    update_data = {
                        "monthly_limit": amount,
                        "is_active": True,
                        "updated_at": datetime.now().isoformat()
                    }
                    result = supabase.table("budget_categories").update(update_data).eq("id", existing.data[0]["id"]).execute()
                else:
                    # Create new
                    budget_record = {
                        "user_budget_id": user_budget_id,
                        "category_id": category_id,
                        "monthly_limit": amount,
                        "is_active": True,
                        "created_at": datetime.now().isoformat(),
                        "updated_at": datetime.now().isoformat()
                    }
                    result = supabase.table("budget_categories").insert(budget_record).execute()
                
                if result.data:
                    applied_count += 1
        
        return {
            "status": "success",
            "message": f"Applied budget allocation to {applied_count} categories for {month:02d}/{year}",
            "total_budget": total_budget,
            "year": year,
            "month": month,
            "applied_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to apply budget allocation: {str(e)}")


@router.delete("/categories/{category_id}", summary="Delete Category Budget")
async def delete_category_budget(
    category_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    year: Optional[int] = Query(None, description="Budget year (defaults to current year)"),
    month: Optional[int] = Query(None, description="Budget month (defaults to current month)")
):
    """
    Deactivate budget for a specific category in a specific month/year
    """
    try:
        year, month = get_current_year_month(year, month)
        
        # Get user's budget for this month first
        user_budget = await get_user_budget_for_month(supabase, current_user["id"], year, month)
        
        if not user_budget:
            raise HTTPException(
                status_code=404, 
                detail=f"No budget found for {month:02d}/{year}"
            )
        
        # Find and deactivate category budget
        existing = supabase.table("budget_categories").select("*").eq("user_budget_id", user_budget["id"]).eq("category_id", category_id).execute()
        
        if not existing.data:
            raise HTTPException(status_code=404, detail=f"Category budget not found for {month:02d}/{year}")
        
        # Update to inactive
        update_data = {
            "is_active": False,
            "updated_at": datetime.now().isoformat()
        }
        
        result = supabase.table("budget_categories").update(update_data).eq("id", existing.data[0]["id"]).execute()
        
        if not result.data:
            raise HTTPException(status_code=400, detail="Failed to deactivate category budget")
        
        return {
            "status": "success",
            "message": f"Category budget deactivated successfully for {month:02d}/{year}"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete category budget: {str(e)}")


@router.get("/list", summary="List User Budgets")
async def list_user_budgets(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client),
    limit: int = Query(12, description="Number of budgets to return"),
    offset: int = Query(0, description="Number of budgets to skip")
):
    """
    List all budgets for the user, ordered by year and month (most recent first)
    """
    try:
        result = supabase.table("user_budgets").select("*").eq("user_id", current_user["id"]).order("year", desc=True).order("month", desc=True).limit(limit).offset(offset).execute()
        
        return {
            "status": "success",
            "budgets": result.data or [],
            "count": len(result.data or [])
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to list budgets: {str(e)}")


@router.get("/health", summary="Budget Service Health Check")
async def health_check():
    """Public health check for budget service"""
    return {
        "status": "healthy",
        "service": "monthly_budget_management",
        "timestamp": datetime.now(),
        "version": "2.0.0"
    } 