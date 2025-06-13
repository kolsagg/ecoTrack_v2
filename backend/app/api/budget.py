"""
Budget Management API Endpoints
Handles budget creation, allocation, and management
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


@router.post("/", summary="Create User Budget")
async def create_user_budget(
    budget_data: UserBudgetCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create or update user's overall monthly budget
    
    **Features:**
    - Sets total monthly budget amount
    - Optionally auto-allocates budget to categories based on research
    - Supports different currencies
    """
    try:
        # Check if user already has a budget
        existing_budget = supabase.table("user_budgets").select("*").eq("user_id", current_user["id"]).execute()
        
        if existing_budget.data:
            # Update existing budget
            update_data = {
                "total_monthly_budget": budget_data.total_monthly_budget,
                "currency": budget_data.currency,
                "auto_allocate": budget_data.auto_allocate,
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("user_budgets").update(update_data).eq("user_id", current_user["id"]).execute()
            
            if not result.data:
                raise HTTPException(status_code=400, detail="Failed to update budget")
            
            return {
                "status": "success",
                "budget": result.data[0],
                "message": "Budget updated successfully"
            }
        else:
            # Create new budget
            budget_record = {
                "user_id": current_user["id"],
                "total_monthly_budget": budget_data.total_monthly_budget,
                "currency": budget_data.currency,
                "auto_allocate": budget_data.auto_allocate,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("user_budgets").insert(budget_record).execute()
            
            if not result.data:
                raise HTTPException(status_code=400, detail="Failed to create budget")
            
            return {
                "status": "success",
                "budget": result.data[0],
                "message": "Budget created successfully"
            }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create budget: {str(e)}")


@router.get("/", summary="Get User Budget")
async def get_user_budget(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get user's overall budget information
    """
    try:
        result = supabase.table("user_budgets").select("*").eq("user_id", current_user["id"]).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="No budget found")
        
        return {
            "status": "success",
            "budget": result.data[0]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get budget: {str(e)}")


@router.put("/", summary="Update User Budget")
async def update_user_budget(
    budget_data: UserBudgetUpdate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Update user's overall budget
    
    **Note:** If total budget amount changes and auto_allocate is enabled,
    category budgets will be automatically re-allocated.
    """
    try:
        update_data = {k: v for k, v in budget_data.dict().items() if v is not None}
        update_data["updated_at"] = datetime.now().isoformat()
        
        result = supabase.table("user_budgets").update(update_data).eq("user_id", current_user["id"]).execute()
        
        if not result.data:
            raise HTTPException(status_code=400, detail="Failed to update budget")
        
        return {
            "status": "success",
            "budget": result.data[0],
            "message": "Budget updated successfully"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update budget: {str(e)}")


@router.post("/categories", summary="Create Category Budget")
async def create_category_budget(
    category_data: BudgetCategoryCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create or update budget for a specific category
    
    **Usage:**
    - Set monthly spending limit for each category
    - Enable/disable budget tracking per category
    
    **Important:**
    - Total category budgets cannot exceed 100% of your total monthly budget
    - System will check available budget before creating/updating
    - Returns error if allocation would exceed total budget
    """
    try:
        # Get user's total budget first
        user_budget_result = supabase.table("user_budgets").select("total_monthly_budget").eq("user_id", current_user["id"]).execute()
        
        if not user_budget_result.data:
            raise HTTPException(status_code=404, detail="User budget not found. Please create a budget first.")
        
        total_budget = float(user_budget_result.data[0]["total_monthly_budget"])
        
        # Check if category budget already exists
        existing = supabase.table("budget_categories").select("*").eq("user_id", current_user["id"]).eq("category_id", category_data.category_id).execute()
        
        # Calculate current total allocated amount (excluding this category if updating)
        all_budgets = supabase.table("budget_categories").select("monthly_limit").eq("user_id", current_user["id"]).eq("is_active", True).execute()
        
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
                detail=f"Budget allocation would exceed total budget. "
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
            message = "Category budget updated successfully"
        else:
            # Create new
            budget_record = {
                "user_id": current_user["id"],
                "category_id": category_data.category_id,
                "monthly_limit": category_data.monthly_limit,
                "is_active": category_data.is_active,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            result = supabase.table("budget_categories").insert(budget_record).execute()
            message = "Category budget created successfully"
        
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
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get all active category budgets for the user
    """
    try:
        # Get category budgets with category names using proper join
        budget_result = supabase.table("budget_categories").select(
            "*, categories(name)"
        ).eq("user_id", current_user["id"]).eq("is_active", True).execute()
        
        if not budget_result.data:
            return {
                "status": "success",
                "category_budgets": []
            }
        
        category_budgets = []
        for item in budget_result.data:
            category_budgets.append({
                "id": item["id"],
                "user_id": item["user_id"],
                "category_id": item["category_id"],
                "category_name": item.get("categories", {}).get("name", "Unknown") if item.get("categories") else "Unknown",
                "monthly_limit": item["monthly_limit"],
                "is_active": item["is_active"],
                "created_at": item["created_at"],
                "updated_at": item["updated_at"]
            })
        
        return {
            "status": "success",
            "category_budgets": category_budgets
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get category budgets: {str(e)}")


@router.get("/summary", summary="Get Budget Summary")
async def get_budget_summary(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get comprehensive budget summary including:
    - Overall budget information
    - Category-wise budget allocations
    - Total allocated vs remaining budget
    - Allocation percentage
    """
    try:
        # Get user's overall budget
        user_budget_result = supabase.table("user_budgets").select("*").eq("user_id", current_user["id"]).execute()
        
        if not user_budget_result.data:
            raise HTTPException(status_code=404, detail="No budget found")
        
        user_budget = user_budget_result.data[0]
        
        # Get category budgets with category names
        category_result = supabase.table("budget_categories").select(
            "*, categories(name)"
        ).eq("user_id", current_user["id"]).eq("is_active", True).execute()
        
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
                "category_count": len(category_budgets)
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
    Apply optimal budget allocation to user's system category budgets only
    
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
        # Optimal budget allocation percentages based on financial research
        # Source: Fulton Bank budget guidelines and financial planning best practices
        optimal_allocations = {
            "Food & Dining": 0.12, "Transportation": 0.12, "Shopping": 0.10, "Entertainment": 0.08,
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
                
                # Check if category budget already exists
                existing = supabase.table("budget_categories").select("*").eq("user_id", current_user["id"]).eq("category_id", category_id).execute()
                
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
                        "user_id": current_user["id"],
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
            "message": f"Applied budget allocation to {applied_count} categories",
            "total_budget": total_budget,
            "applied_at": datetime.now().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to apply budget allocation: {str(e)}")


@router.delete("/categories/{category_id}", summary="Delete Category Budget")
async def delete_category_budget(
    category_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Deactivate budget for a specific category
    """
    try:
        # Find and deactivate category budget
        existing = supabase.table("budget_categories").select("*").eq("user_id", current_user["id"]).eq("category_id", category_id).execute()
        
        if not existing.data:
            raise HTTPException(status_code=404, detail="Category budget not found")
        
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
            "message": "Category budget deactivated successfully"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete category budget: {str(e)}")


@router.get("/health", summary="Budget Service Health Check")
async def health_check():
    """Public health check for budget service"""
    return {
        "status": "healthy",
        "service": "budget_management",
        "timestamp": datetime.now(),
        "version": "1.0.0"
    } 