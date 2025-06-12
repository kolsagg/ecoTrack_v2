"""
Loyalty Program Service
Handles loyalty points calculation, level management, and rewards
"""

import logging
from datetime import datetime
from typing import Dict, Any, Optional, List
from uuid import uuid4

from app.db.supabase_client import get_supabase_client, get_supabase_admin_client
from app.schemas.loyalty import (
    LoyaltyLevel, LoyaltyStatusResponse, PointsCalculationResult, LoyaltyTransaction
)

logger = logging.getLogger(__name__)

class LoyaltyService:
    """Service for managing loyalty program functionality"""
    
    def __init__(self):
        self.supabase = get_supabase_client()
        self.service_supabase = get_supabase_admin_client()  # For admin operations
        
        # Loyalty level thresholds (points required)
        self.level_thresholds = {
            LoyaltyLevel.BRONZE: 0,
            LoyaltyLevel.SILVER: 1000,
            LoyaltyLevel.GOLD: 5000,
            LoyaltyLevel.PLATINUM: 15000
        }
        
        # Points calculation rules
        self.base_points_per_lira = 1  # 1 point per 1 TRY spent
        self.level_multipliers = {
            LoyaltyLevel.BRONZE: 1.0,
            LoyaltyLevel.SILVER: 1.2,
            LoyaltyLevel.GOLD: 1.5,
            LoyaltyLevel.PLATINUM: 2.0
        }
        
        # Category bonus multipliers
        self.category_bonuses = {
            "food": 1.5,
            "grocery": 1.3,
            "fuel": 1.2,
            "restaurant": 1.4
        }

    async def get_user_loyalty_status(self, user_id: str) -> LoyaltyStatusResponse:
        """
        Get user's current loyalty status
        
        Args:
            user_id: User ID
            
        Returns:
            LoyaltyStatusResponse with current status
        """
        try:
            logger.info(f"Getting loyalty status for user {user_id}")
            
            # Get or create loyalty status
            loyalty_data = await self._get_or_create_loyalty_status(user_id)
            
            # Calculate level and next level info
            current_level = self._calculate_level(loyalty_data["points"])
            next_level = self._get_next_level(current_level)
            points_to_next = self._calculate_points_to_next_level(loyalty_data["points"], next_level)
            
            return LoyaltyStatusResponse(
                user_id=user_id,
                points=loyalty_data["points"],
                level=current_level,
                points_to_next_level=points_to_next,
                next_level=next_level,
                last_updated=datetime.fromisoformat(loyalty_data["last_updated"].replace('Z', '+00:00'))
            )
            
        except Exception as e:
            logger.error(f"Failed to get loyalty status for user {user_id}: {str(e)}")
            raise

    async def calculate_points_for_expense(
        self, 
        user_id: str, 
        amount: float, 
        category: Optional[str] = None,
        merchant_name: Optional[str] = None
    ) -> PointsCalculationResult:
        """
        Calculate loyalty points for an expense
        
        Args:
            user_id: User ID
            amount: Expense amount
            category: Expense category (optional)
            merchant_name: Merchant name (optional)
            
        Returns:
            PointsCalculationResult with calculation details
        """
        try:
            logger.info(f"Calculating points for user {user_id}, amount: {amount}")
            
            # Get user's current level
            loyalty_status = await self.get_user_loyalty_status(user_id)
            current_level = loyalty_status.level or LoyaltyLevel.BRONZE
            
            # Calculate base points
            base_points = int(amount * self.base_points_per_lira)
            
            # Apply level multiplier
            level_multiplier = self.level_multipliers.get(current_level, 1.0)
            level_bonus = int(base_points * (level_multiplier - 1.0))
            
            # Apply category bonus
            category_bonus = 0
            if category and category.lower() in self.category_bonuses:
                category_multiplier = self.category_bonuses[category.lower()]
                category_bonus = int(base_points * (category_multiplier - 1.0))
            
            # Calculate total
            total_points = base_points + level_bonus + category_bonus
            
            calculation_details = {
                "amount": amount,
                "base_points_per_lira": self.base_points_per_lira,
                "base_points": base_points,
                "current_level": current_level.value,
                "level_multiplier": level_multiplier,
                "level_bonus": level_bonus,
                "category": category,
                "category_bonus": category_bonus,
                "merchant_name": merchant_name
            }
            
            return PointsCalculationResult(
                base_points=base_points,
                bonus_points=level_bonus + category_bonus,
                total_points=total_points,
                calculation_details=calculation_details
            )
            
        except Exception as e:
            logger.error(f"Points calculation failed: {str(e)}")
            raise

    async def award_points_for_expense(
        self, 
        user_id: str, 
        expense_id: str,
        amount: float, 
        category: Optional[str] = None,
        merchant_name: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Award loyalty points for an expense and update user's status
        
        Args:
            user_id: User ID
            expense_id: Expense ID for tracking
            amount: Expense amount
            category: Expense category (optional)
            merchant_name: Merchant name (optional)
            
        Returns:
            Dictionary with award results
        """
        try:
            logger.info(f"Awarding points for expense {expense_id}, user {user_id}")
            
            # Calculate points
            points_result = await self.calculate_points_for_expense(
                user_id, amount, category, merchant_name
            )
            
            # Get current loyalty status
            current_status = await self.get_user_loyalty_status(user_id)
            
            # Calculate new totals
            new_total_points = current_status.points + points_result.total_points
            new_level = self._calculate_level(new_total_points)
            level_changed = new_level != current_status.level
            
            # Update loyalty status
            update_data = {
                "points": new_total_points,
                "level": new_level.value if new_level else None,
                "last_updated": datetime.now().isoformat()
            }
            
            result = self.service_supabase.table("loyalty_status").update(update_data).eq("user_id", user_id).execute()
            
            if not result.data:
                logger.error(f"Failed to update loyalty status for user {user_id}")
                raise Exception("Failed to update loyalty status")
            
            # Log the transaction (you might want to create a separate table for this)
            logger.info(f"Points awarded: {points_result.total_points}, New total: {new_total_points}, Level: {new_level}")
            
            return {
                "success": True,
                "points_awarded": points_result.total_points,
                "previous_total": current_status.points,
                "new_total": new_total_points,
                "previous_level": current_status.level,
                "new_level": new_level,
                "level_changed": level_changed,
                "calculation_details": points_result.calculation_details
            }
            
        except Exception as e:
            logger.error(f"Failed to award points: {str(e)}")
            raise

    async def get_user_loyalty_history(self, user_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get user's loyalty points history (from expenses)
        
        Args:
            user_id: User ID
            limit: Maximum number of records to return
            
        Returns:
            List of loyalty transactions
        """
        try:
            logger.info(f"Getting loyalty history for user {user_id}")
            
            # Get recent expenses with loyalty points information
            # This is a simplified version - you might want to create a separate loyalty_transactions table
            result = self.supabase.table("expenses").select(
                "id, total_amount, expense_date, notes, receipts(merchant_name)"
            ).eq("user_id", user_id).order("expense_date", desc=True).limit(limit).execute()
            
            if not result.data:
                return []
            
            history = []
            for expense in result.data:
                # Calculate what points would have been earned (simplified)
                amount = float(expense.get("total_amount", 0))
                base_points = int(amount * self.base_points_per_lira)
                
                merchant_name = None
                if expense.get("receipts"):
                    merchant_name = expense["receipts"].get("merchant_name")
                
                history.append({
                    "expense_id": expense["id"],
                    "amount": amount,
                    "estimated_points": base_points,
                    "merchant_name": merchant_name,
                    "date": expense["expense_date"],
                    "notes": expense.get("notes")
                })
            
            return history
            
        except Exception as e:
            logger.error(f"Failed to get loyalty history: {str(e)}")
            return []

    async def _get_or_create_loyalty_status(self, user_id: str) -> Dict[str, Any]:
        """Get existing loyalty status or create new one using service role"""
        try:
            # Try to get existing status using service client (bypasses RLS)
            result = self.service_supabase.table("loyalty_status").select("*").eq("user_id", user_id).execute()
            
            if result.data:
                return result.data[0]
            
            # Create new loyalty status using service client (bypasses RLS)
            new_status = {
                "user_id": user_id,
                "points": 0,
                "level": LoyaltyLevel.BRONZE.value,
                "last_updated": datetime.now().isoformat()
            }
            
            create_result = self.service_supabase.table("loyalty_status").insert(new_status).execute()
            
            if not create_result.data:
                raise Exception("Failed to create loyalty status")
            
            logger.info(f"Created new loyalty status for user {user_id}")
            return create_result.data[0]
            
        except Exception as e:
            logger.error(f"Failed to get/create loyalty status: {str(e)}")
            raise

    def _calculate_level(self, points: int) -> Optional[LoyaltyLevel]:
        """Calculate loyalty level based on points"""
        if points >= self.level_thresholds[LoyaltyLevel.PLATINUM]:
            return LoyaltyLevel.PLATINUM
        elif points >= self.level_thresholds[LoyaltyLevel.GOLD]:
            return LoyaltyLevel.GOLD
        elif points >= self.level_thresholds[LoyaltyLevel.SILVER]:
            return LoyaltyLevel.SILVER
        else:
            return LoyaltyLevel.BRONZE

    def _get_next_level(self, current_level: Optional[LoyaltyLevel]) -> Optional[LoyaltyLevel]:
        """Get the next achievable level"""
        if not current_level:
            return LoyaltyLevel.BRONZE
        
        level_order = [LoyaltyLevel.BRONZE, LoyaltyLevel.SILVER, LoyaltyLevel.GOLD, LoyaltyLevel.PLATINUM]
        
        try:
            current_index = level_order.index(current_level)
            if current_index < len(level_order) - 1:
                return level_order[current_index + 1]
        except ValueError:
            pass
        
        return None  # Already at highest level

    def _calculate_points_to_next_level(self, current_points: int, next_level: Optional[LoyaltyLevel]) -> Optional[int]:
        """Calculate points needed to reach next level"""
        if not next_level:
            return None
        
        required_points = self.level_thresholds[next_level]
        return max(0, required_points - current_points) 