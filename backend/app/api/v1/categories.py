from fastapi import APIRouter, Depends, HTTPException
from typing import List
from uuid import UUID

from app.core.auth import get_current_user
from app.schemas.data_processing import (
    CategoryResponse,
    CategoryCreateRequest,
    CategoryUpdateRequest
)
from app.db.supabase_client import get_authenticated_supabase_client
from supabase import Client

router = APIRouter()

# Predefined system categories
SYSTEM_CATEGORIES = [
    {"name": "Food & Dining", "system": True},
    {"name": "Transportation", "system": True},
    {"name": "Shopping", "system": True},
    {"name": "Health & Medical", "system": True},
    {"name": "Entertainment", "system": True},
    {"name": "Utilities", "system": True},
    {"name": "Education", "system": True},
    {"name": "Personal Care", "system": True},
    {"name": "Home & Garden", "system": True},
    {"name": "Other", "system": True}
]

@router.get("", response_model=List[CategoryResponse])
async def list_categories(
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    List all categories (predefined + user's custom categories)
    """
    try:
        # Get all categories (RLS will automatically filter)
        # This includes system categories (is_system=true, visible to all) and user's custom categories
        response = supabase.table("categories").select("*").execute()
        
        categories = []
        
        # Convert all categories to response format
        for cat in response.data:
            categories.append(CategoryResponse(
                id=cat["id"],
                name=cat["name"],
                user_id=cat.get("user_id"),  # System categories have null user_id
                is_system=cat.get("is_system", False),
                created_at=cat["created_at"],
                updated_at=cat["updated_at"]
            ))
        
        return categories
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to fetch categories: {str(e)}")

@router.post("", response_model=CategoryResponse)
async def create_category(
    request: CategoryCreateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Create a new custom category for the user
    """
    try:
        # Check if category name already exists for this user
        existing_response = supabase.table("categories").select("*").eq("user_id", current_user["id"]).eq("name", request.name).execute()
        
        if existing_response.data:
            raise HTTPException(status_code=400, detail="Category with this name already exists")
        
        # Check if it's a system category name
        system_names = [cat["name"].lower() for cat in SYSTEM_CATEGORIES]
        if request.name.lower() in system_names:
            raise HTTPException(status_code=400, detail="Cannot create category with system category name")
        
        # Create category
        category_data = {
            "user_id": current_user["id"],
            "name": request.name,
            "is_system": False  # Custom categories are never system categories
        }
        
        response = supabase.table("categories").insert(category_data).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to create category")
        
        category = response.data[0]
        
        return CategoryResponse(
            id=category["id"],
            name=category["name"],
            user_id=category["user_id"],
            is_system=False,
            created_at=category["created_at"],
            updated_at=category["updated_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create category: {str(e)}")

@router.put("/{category_id}", response_model=CategoryResponse)
async def update_category(
    category_id: UUID,
    request: CategoryUpdateRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Update a user's custom category
    """
    try:
        # Check if category exists and belongs to user
        existing_response = supabase.table("categories").select("*").eq("id", str(category_id)).eq("user_id", current_user["id"]).execute()
        
        if not existing_response.data:
            raise HTTPException(status_code=404, detail="Category not found")
        
        # Check if new name conflicts with existing categories
        if request.name:
            name_check_response = supabase.table("categories").select("*").eq("user_id", current_user["id"]).eq("name", request.name).neq("id", str(category_id)).execute()
            
            if name_check_response.data:
                raise HTTPException(status_code=400, detail="Category with this name already exists")
            
            # Check if it's a system category name
            system_names = [cat["name"].lower() for cat in SYSTEM_CATEGORIES]
            if request.name.lower() in system_names:
                raise HTTPException(status_code=400, detail="Cannot use system category name")
        
        # Update category
        update_data = {}
        if request.name:
            update_data["name"] = request.name
        
        if not update_data:
            raise HTTPException(status_code=400, detail="No fields to update")
        
        response = supabase.table("categories").update(update_data).eq("id", str(category_id)).eq("user_id", current_user["id"]).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to update category")
        
        category = response.data[0]
        
        return CategoryResponse(
            id=category["id"],
            name=category["name"],
            user_id=category["user_id"],
            is_system=False,
            created_at=category["created_at"],
            updated_at=category["updated_at"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update category: {str(e)}")

@router.delete("/{category_id}")
async def delete_category(
    category_id: UUID,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Delete a user's custom category
    """
    try:
        # Check if category exists and belongs to user
        existing_response = supabase.table("categories").select("*").eq("id", str(category_id)).eq("user_id", current_user["id"]).execute()
        
        if not existing_response.data:
            raise HTTPException(status_code=404, detail="Category not found")
        
        # Check if category is being used by any expenses
        expenses_response = supabase.table("expenses").select("id").eq("category_id", str(category_id)).limit(1).execute()
        
        if expenses_response.data:
            raise HTTPException(status_code=400, detail="Cannot delete category that is being used by expenses")
        
        # Delete category
        response = supabase.table("categories").delete().eq("id", str(category_id)).eq("user_id", current_user["id"]).execute()
        
        if not response.data:
            raise HTTPException(status_code=500, detail="Failed to delete category")
        
        return {"message": "Category deleted successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete category: {str(e)}") 