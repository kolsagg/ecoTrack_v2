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
        self.base_points_per_lira = 0.1  # 1 point per 10 TRY spent
        self.level_multipliers = {
            LoyaltyLevel.BRONZE: 1.0,
            LoyaltyLevel.SILVER: 1.2,
            LoyaltyLevel.GOLD: 1.5,
            LoyaltyLevel.PLATINUM: 2.0
        }
        
        # Category bonus multipliers
        self.category_bonuses = {
            "dining_out": 1.5,
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
            
            # Handle last_updated datetime parsing safely
            last_updated = self._safe_parse_datetime(loyalty_data["last_updated"])
            
            return LoyaltyStatusResponse(
                user_id=user_id,
                points=loyalty_data["points"],
                level=current_level,
                points_to_next_level=points_to_next,
                next_level=next_level,
                last_updated=last_updated
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
                "last_updated": self._format_datetime_for_db()
            }
            
            result = self.service_supabase.table("loyalty_status").update(update_data).eq("user_id", user_id).execute()
            
            if not result.data:
                logger.error(f"Failed to update loyalty status for user {user_id}")
                raise Exception("Failed to update loyalty status")
            
            # Create loyalty transaction record
            transaction_data = {
                "user_id": user_id,
                "expense_id": expense_id,
                "points_earned": points_result.total_points,
                "transaction_amount": amount,
                "merchant_name": merchant_name,
                "category": category,
                "calculation_details": points_result.calculation_details,
                "transaction_type": "expense",
                "created_at": self._format_datetime_for_db()
            }
            
            transaction_result = self.service_supabase.table("loyalty_transactions").insert(transaction_data).execute()
            
            if not transaction_result.data:
                logger.warning(f"Failed to create loyalty transaction record for user {user_id}")
                # Don't fail the entire operation, just log warning
            else:
                logger.info(f"Created loyalty transaction record: {transaction_result.data[0]['id']}")
            
            logger.info(f"Points awarded: {points_result.total_points}, New total: {new_total_points}, Level: {new_level}")
            
            return {
                "success": True,
                "points_awarded": points_result.total_points,
                "previous_total": current_status.points,
                "new_total": new_total_points,
                "previous_level": current_status.level,
                "new_level": new_level,
                "level_changed": level_changed,
                "calculation_details": points_result.calculation_details,
                "transaction_id": transaction_result.data[0]["id"] if transaction_result.data else None
            }
            
        except Exception as e:
            logger.error(f"Failed to award points: {str(e)}")
            raise

    async def get_user_loyalty_history(self, user_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """
        Get user's loyalty points history from loyalty_transactions table
        
        Args:
            user_id: User ID
            limit: Maximum number of records to return
            
        Returns:
            List of loyalty transactions
        """
        try:
            logger.info(f"Getting loyalty history for user {user_id}, limit: {limit}")
            
            # Try with service client first to bypass RLS for debugging
            result = self.service_supabase.table("loyalty_transactions").select(
                "*"
            ).eq("user_id", user_id).order("created_at", desc=True).limit(limit).execute()
            
            logger.info(f"Raw Supabase result: {result}")
            logger.info(f"Result data: {result.data}")
            logger.info(f"Result count: {result.count}")
            
            if not result.data:
                logger.warning(f"No loyalty transactions found for user {user_id}")
                return []
            
            logger.info(f"Found {len(result.data)} transactions for user {user_id}")
            
            history = []
            for transaction in result.data:
                logger.debug(f"Processing transaction: {transaction}")
                
                # Parse created_at safely
                created_at = self._safe_parse_datetime(transaction["created_at"])
                
                history.append({
                    "id": transaction["id"],
                    "expense_id": transaction["expense_id"],
                    "points_earned": transaction["points_earned"],
                    "transaction_amount": float(transaction["transaction_amount"]),
                    "merchant_name": transaction.get("merchant_name"),
                    "category": transaction.get("category"),
                    "transaction_type": transaction["transaction_type"],
                    "calculation_details": transaction.get("calculation_details", {}),
                    "created_at": created_at.isoformat(),
                    "date": created_at.strftime("%Y-%m-%d")  # For backward compatibility
                })
            
            logger.info(f"Returning {len(history)} transactions in history")
            return history
            
        except Exception as e:
            logger.error(f"Failed to get loyalty history: {str(e)}")
            logger.exception("Full exception details:")
            return []

    def _safe_parse_datetime(self, datetime_str: Any) -> datetime:
        """
        Safely parse datetime from various formats
        
        Args:
            datetime_str: Datetime string or object from database
            
        Returns:
            datetime object
        """
        if isinstance(datetime_str, datetime):
            return datetime_str
        
        if not isinstance(datetime_str, str):
            logger.warning(f"Unexpected datetime type: {type(datetime_str)}, using current time")
            return datetime.now()
        
        try:
            # Handle Supabase datetime formats
            working_str = datetime_str
            
            # Convert Z to timezone offset
            if working_str.endswith('Z'):
                working_str = working_str.replace('Z', '+00:00')
            elif '+' not in working_str and 'T' in working_str:
                working_str = working_str + '+00:00'
            
            # Fix microsecond precision issues
            # Python fromisoformat expects max 6 digits for microseconds
            if '.' in working_str and ('+' in working_str or '-' in working_str):
                # Split by timezone part (+ or -)
                if '+' in working_str:
                    date_part, tz_part = working_str.rsplit('+', 1)
                    tz_prefix = '+'
                else:
                    date_part, tz_part = working_str.rsplit('-', 1)
                    tz_prefix = '-'
                
                if '.' in date_part:
                    main_part, micro_part = date_part.rsplit('.', 1)
                    # Ensure microseconds are exactly 6 digits
                    if len(micro_part) > 6:
                        micro_part = micro_part[:6]
                    elif len(micro_part) < 6:
                        micro_part = micro_part.ljust(6, '0')
                    working_str = f"{main_part}.{micro_part}{tz_prefix}{tz_part}"
            
            return datetime.fromisoformat(working_str)
            
        except (ValueError, AttributeError) as e:
            logger.warning(f"✗ Failed to parse datetime '{datetime_str}': {e}, using current time")
            return datetime.now()
    
    def _format_datetime_for_db(self) -> str:
        """
        Format current datetime for database storage
        
        Returns:
            ISO formatted datetime string with Z suffix
        """
        return datetime.now().replace(microsecond=0).isoformat() + 'Z'

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
                "last_updated": self._format_datetime_for_db()
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