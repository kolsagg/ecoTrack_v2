from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum

class LoyaltyLevel(str, Enum):
    """Loyalty program levels"""
    BRONZE = "bronze"
    SILVER = "silver"
    GOLD = "gold"
    PLATINUM = "platinum"

class LoyaltyStatusResponse(BaseModel):
    """Response model for loyalty status"""
    user_id: str
    points: int = Field(..., ge=0, description="Current loyalty points")
    level: Optional[LoyaltyLevel] = Field(None, description="Current loyalty level")
    points_to_next_level: Optional[int] = Field(None, description="Points needed for next level")
    next_level: Optional[LoyaltyLevel] = Field(None, description="Next achievable level")
    last_updated: datetime
    
    class Config:
        from_attributes = True

class PointsCalculationResult(BaseModel):
    """Result of points calculation"""
    base_points: int = Field(..., description="Base points from amount")
    bonus_points: int = Field(default=0, description="Bonus points from multipliers")
    total_points: int = Field(..., description="Total points earned")
    calculation_details: dict = Field(default_factory=dict, description="Calculation breakdown")

class LoyaltyTransaction(BaseModel):
    """Loyalty points transaction record"""
    transaction_id: str
    user_id: str
    points_earned: int
    transaction_amount: float
    merchant_name: Optional[str] = None
    calculation_details: dict
    created_at: datetime 