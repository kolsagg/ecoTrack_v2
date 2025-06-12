"""
Loyalty Program API Endpoints
Handles loyalty points, levels, and rewards
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional

from app.auth.dependencies import get_current_user
from app.schemas.loyalty import LoyaltyStatusResponse, PointsCalculationResult
from app.services.loyalty_service import LoyaltyService

router = APIRouter()
loyalty_service = LoyaltyService()

@router.get("/status", response_model=LoyaltyStatusResponse)
async def get_loyalty_status(
    current_user: dict = Depends(get_current_user)
):
    """
    Get user's current loyalty status including points, level, and progress
    """
    try:
        status = await loyalty_service.get_user_loyalty_status(current_user["id"])
        return status
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get loyalty status: {str(e)}")

@router.get("/calculate-points", response_model=PointsCalculationResult)
async def calculate_points(
    amount: float = Query(..., gt=0, description="Expense amount"),
    category: Optional[str] = Query(None, description="Expense category"),
    merchant_name: Optional[str] = Query(None, description="Merchant name"),
    current_user: dict = Depends(get_current_user)
):
    """
    Calculate loyalty points for a given expense amount
    Useful for showing users how many points they would earn
    """
    try:
        result = await loyalty_service.calculate_points_for_expense(
            user_id=current_user["id"],
            amount=amount,
            category=category,
            merchant_name=merchant_name
        )
        return result
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to calculate points: {str(e)}")

@router.get("/history")
async def get_loyalty_history(
    limit: int = Query(50, ge=1, le=100, description="Maximum number of records"),
    current_user: dict = Depends(get_current_user)
):
    """
    Get user's loyalty points history from recent expenses
    """
    try:
        history = await loyalty_service.get_user_loyalty_history(
            user_id=current_user["id"],
            limit=limit
        )
        
        return {
            "success": True,
            "count": len(history),
            "history": history
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get loyalty history: {str(e)}")

@router.get("/levels")
async def get_loyalty_levels():
    """
    Get information about all loyalty levels and their requirements
    """
    try:
        levels_info = {
            "bronze": {
                "name": "Bronze",
                "points_required": 0,
                "multiplier": 1.0,
                "benefits": ["Base points earning", "Standard support"]
            },
            "silver": {
                "name": "Silver", 
                "points_required": 1000,
                "multiplier": 1.2,
                "benefits": ["20% bonus points", "Priority support", "Monthly reports"]
            },
            "gold": {
                "name": "Gold",
                "points_required": 5000, 
                "multiplier": 1.5,
                "benefits": ["50% bonus points", "Premium support", "Advanced analytics", "Category bonuses"]
            },
            "platinum": {
                "name": "Platinum",
                "points_required": 15000,
                "multiplier": 2.0,
                "benefits": ["100% bonus points", "VIP support", "Custom reports", "Maximum category bonuses", "Early feature access"]
            }
        }
        
        return {
            "success": True,
            "levels": levels_info,
            "category_bonuses": {
                "food": "50% bonus",
                "grocery": "30% bonus", 
                "fuel": "20% bonus",
                "restaurant": "40% bonus"
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get levels info: {str(e)}") 