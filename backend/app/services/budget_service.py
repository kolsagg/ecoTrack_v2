"""
Budget Management Service
Handles budget creation, allocation, and management
"""

import logging
from datetime import datetime, date
from typing import Dict, Any, List, Optional
from collections import defaultdict

from app.db.supabase_client import get_supabase_client
from app.schemas.budget import (
    UserBudgetCreate, UserBudgetUpdate, UserBudgetResponse,
    BudgetCategoryCreate, BudgetCategoryUpdate, BudgetCategoryResponse,
    BudgetAllocationResponse, BudgetSummaryResponse
)

logger = logging.getLogger(__name__)


class BudgetService:
    """Service for budget management operations"""
    
    def __init__(self):
        self.supabase = get_supabase_client()
        
        # Optimal budget allocation percentages based on research
        self.optimal_allocations = {
            "Food": 0.15,           # 15% - Gıda
            "Housing": 0.30,        # 30% - Konut
            "Transportation": 0.15, # 15% - Ulaşım
            "Utilities": 0.08,      # 8% - Faturalar
            "Healthcare": 0.05,     # 5% - Sağlık
            "Entertainment": 0.05,  # 5% - Eğlence
            "Shopping": 0.10,       # 10% - Alışveriş
            "Education": 0.05,      # 5% - Eğitim
            "Savings": 0.07         # 7% - Tasarruf/Diğer
        }
    
    async def create_user_budget(self, user_id: str, budget_data: UserBudgetCreate) -> Dict[str, Any]:
        """Create or update user's overall budget"""
        try:
            # Check if user already has a budget
            existing_budget = await self.get_user_budget(user_id)
            
            if existing_budget and existing_budget.get("status") == "success":
                # Update existing budget
                return await self.update_user_budget(user_id, UserBudgetUpdate(**budget_data.dict()))
            
            # Create new budget
            budget_record = {
                "user_id": user_id,
                "total_monthly_budget": budget_data.total_monthly_budget,
                "currency": budget_data.currency,
                "auto_allocate": budget_data.auto_allocate,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            result = self.supabase.table("user_budgets").insert(budget_record).execute()
            
            if not result.data:
                return {"status": "error", "message": "Failed to create budget"}
            
            budget_id = result.data[0]["id"]
            
            # Auto-allocate budget to categories if requested
            if budget_data.auto_allocate:
                await self._auto_allocate_budget(user_id, budget_data.total_monthly_budget)
            
            return {
                "status": "success",
                "budget": result.data[0],
                "message": "Budget created successfully"
            }
            
        except Exception as e:
            logger.error(f"Failed to create user budget: {str(e)}")
            return {"status": "error", "message": f"Failed to create budget: {str(e)}"}
    
    async def get_user_budget(self, user_id: str) -> Dict[str, Any]:
        """Get user's overall budget"""
        try:
            result = self.supabase.table("user_budgets").select("*").eq("user_id", user_id).execute()
            
            if not result.data:
                return {"status": "not_found", "message": "No budget found for user"}
            
            return {
                "status": "success",
                "budget": result.data[0]
            }
            
        except Exception as e:
            logger.error(f"Failed to get user budget: {str(e)}")
            return {"status": "error", "message": f"Failed to get budget: {str(e)}"}
    
    async def update_user_budget(self, user_id: str, budget_data: UserBudgetUpdate) -> Dict[str, Any]:
        """Update user's overall budget"""
        try:
            update_data = {k: v for k, v in budget_data.dict().items() if v is not None}
            update_data["updated_at"] = datetime.now().isoformat()
            
            result = self.supabase.table("user_budgets").update(update_data).eq("user_id", user_id).execute()
            
            if not result.data:
                return {"status": "error", "message": "Failed to update budget"}
            
            # Re-allocate budget if total amount changed and auto_allocate is enabled
            if "total_monthly_budget" in update_data:
                budget_info = await self.get_user_budget(user_id)
                if budget_info.get("budget", {}).get("auto_allocate", False):
                    await self._auto_allocate_budget(user_id, update_data["total_monthly_budget"])
            
            return {
                "status": "success",
                "budget": result.data[0],
                "message": "Budget updated successfully"
            }
            
        except Exception as e:
            logger.error(f"Failed to update user budget: {str(e)}")
            return {"status": "error", "message": f"Failed to update budget: {str(e)}"}
    
    async def create_category_budget(self, user_id: str, category_data: BudgetCategoryCreate) -> Dict[str, Any]:
        """Create or update budget for a specific category"""
        try:
            # Check if category budget already exists
            existing = self.supabase.table("budget_categories").select("*").eq("user_id", user_id).eq("category_id", category_data.category_id).execute()
            
            if existing.data:
                # Update existing
                update_data = {
                    "monthly_limit": category_data.monthly_limit,
                    "is_active": category_data.is_active,
                    "updated_at": datetime.now().isoformat()
                }
                
                result = self.supabase.table("budget_categories").update(update_data).eq("id", existing.data[0]["id"]).execute()
                message = "Category budget updated successfully"
            else:
                # Create new
                budget_record = {
                    "user_id": user_id,
                    "category_id": category_data.category_id,
                    "monthly_limit": category_data.monthly_limit,
                    "is_active": category_data.is_active,
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat()
                }
                
                result = self.supabase.table("budget_categories").insert(budget_record).execute()
                message = "Category budget created successfully"
            
            if not result.data:
                return {"status": "error", "message": "Failed to save category budget"}
            
            return {
                "status": "success",
                "category_budget": result.data[0],
                "message": message
            }
            
        except Exception as e:
            logger.error(f"Failed to create category budget: {str(e)}")
            return {"status": "error", "message": f"Failed to save category budget: {str(e)}"}
    
    async def get_category_budgets(self, user_id: str) -> Dict[str, Any]:
        """Get all category budgets for a user"""
        try:
            result = self.supabase.table("budget_categories").select(
                "*, categories(name)"
            ).eq("user_id", user_id).eq("is_active", True).execute()
            
            category_budgets = []
            for item in result.data or []:
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
            logger.error(f"Failed to get category budgets: {str(e)}")
            return {"status": "error", "message": f"Failed to get category budgets: {str(e)}"}
    
    async def get_budget_summary(self, user_id: str) -> Dict[str, Any]:
        """Get comprehensive budget summary"""
        try:
            # Get user's overall budget
            user_budget_result = await self.get_user_budget(user_id)
            if user_budget_result["status"] != "success":
                return user_budget_result
            
            # Get category budgets
            category_budgets_result = await self.get_category_budgets(user_id)
            if category_budgets_result["status"] != "success":
                return category_budgets_result
            
            user_budget = user_budget_result["budget"]
            category_budgets = category_budgets_result["category_budgets"]
            
            # Calculate totals
            total_allocated = sum(cb["monthly_limit"] for cb in category_budgets)
            remaining_budget = user_budget["total_monthly_budget"] - total_allocated
            allocation_percentage = (total_allocated / user_budget["total_monthly_budget"]) * 100 if user_budget["total_monthly_budget"] > 0 else 0
            
            return {
                "status": "success",
                "user_budget": user_budget,
                "category_budgets": category_budgets,
                "total_allocated": round(total_allocated, 2),
                "remaining_budget": round(remaining_budget, 2),
                "allocation_percentage": round(allocation_percentage, 2)
            }
            
        except Exception as e:
            logger.error(f"Failed to get budget summary: {str(e)}")
            return {"status": "error", "message": f"Failed to get budget summary: {str(e)}"}
    
    async def allocate_budget_optimally(self, user_id: str, total_budget: float, categories: Optional[List[str]] = None) -> Dict[str, Any]:
        """Allocate budget optimally across categories"""
        try:
            # Get available categories
            available_categories = await self._get_available_categories(user_id)
            
            if not available_categories:
                return {"status": "error", "message": "No categories found"}
            
            # Filter categories if specific ones requested
            if categories:
                available_categories = [cat for cat in available_categories if cat["id"] in categories]
            
            # Create allocation based on optimal percentages
            allocations = []
            total_allocated = 0
            
            for category in available_categories:
                category_name = category["name"]
                
                # Find matching allocation percentage
                allocation_percentage = 0
                for key, percentage in self.optimal_allocations.items():
                    if key.lower() in category_name.lower() or category_name.lower() in key.lower():
                        allocation_percentage = percentage
                        break
                
                # Default allocation if no match found
                if allocation_percentage == 0:
                    allocation_percentage = 0.05  # 5% default
                
                allocated_amount = total_budget * allocation_percentage
                total_allocated += allocated_amount
                
                allocations.append({
                    "category_id": category["id"],
                    "category_name": category_name,
                    "allocated_amount": round(allocated_amount, 2),
                    "percentage": round(allocation_percentage * 100, 1),
                    "recommendation": self._get_allocation_recommendation(category_name, allocation_percentage)
                })
            
            # Adjust if total doesn't match exactly
            if total_allocated != total_budget:
                difference = total_budget - total_allocated
                if allocations:
                    allocations[0]["allocated_amount"] += difference
                    allocations[0]["allocated_amount"] = round(allocations[0]["allocated_amount"], 2)
            
            return {
                "status": "success",
                "total_budget": total_budget,
                "allocations": allocations,
                "allocation_method": "optimal_research_based",
                "generated_at": datetime.now()
            }
            
        except Exception as e:
            logger.error(f"Failed to allocate budget: {str(e)}")
            return {"status": "error", "message": f"Failed to allocate budget: {str(e)}"}
    
    async def _auto_allocate_budget(self, user_id: str, total_budget: float):
        """Automatically allocate budget to categories"""
        try:
            allocation_result = await self.allocate_budget_optimally(user_id, total_budget)
            
            if allocation_result["status"] != "success":
                return
            
            # Create/update category budgets based on allocation
            for allocation in allocation_result["allocations"]:
                category_data = BudgetCategoryCreate(
                    category_id=allocation["category_id"],
                    monthly_limit=allocation["allocated_amount"],
                    is_active=True
                )
                
                await self.create_category_budget(user_id, category_data)
                
        except Exception as e:
            logger.error(f"Auto allocation failed: {str(e)}")
    
    async def _get_available_categories(self, user_id: str) -> List[Dict[str, Any]]:
        """Get available categories for the user"""
        try:
            result = self.supabase.table("categories").select("id, name").execute()
            return result.data or []
            
        except Exception as e:
            logger.error(f"Failed to get categories: {str(e)}")
            return []
    
    def _get_allocation_recommendation(self, category_name: str, percentage: float) -> str:
        """Get recommendation text for category allocation"""
        percentage_display = percentage * 100
        
        if percentage_display >= 25:
            return f"{category_name} için {percentage_display:.1f}% önemli bir bütçe kalemi. Dikkatli takip edin."
        elif percentage_display >= 10:
            return f"{category_name} için {percentage_display:.1f}% orta düzey bütçe. Dengeli harcama yapın."
        else:
            return f"{category_name} için {percentage_display:.1f}% düşük bütçe. Gerektiğinde artırabilirsiniz." 