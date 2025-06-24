from pydantic import BaseModel, Field
from typing import Literal
from typing import List, Optional
from datetime import datetime

class WastePreventionAlert(BaseModel):
    """Schema for waste prevention alerts"""
    product_name: str = Field(..., description="Product name")
    estimated_shelf_life_days: int = Field(..., description="Estimated shelf life in days")
    purchase_date: datetime = Field(..., description="Purchase date")
    days_since_purchase: int = Field(..., description="Days since purchase")
    risk_level: str = Field(..., description="Risk level: low, medium, high")
    alert_message: str = Field(..., description="User-friendly alert message")
    
class CategoryAnomalyAlert(BaseModel):
    """Schema for category anomaly alerts"""
    category: str = Field(..., description="Category name")
    current_month_spending: float = Field(..., description="Current month spending")
    average_spending: float = Field(..., description="Average monthly spending")
    anomaly_percentage: float = Field(..., description="Anomaly percentage")
    severity: str = Field(..., description="Anomaly severity: mild, moderate, severe")
    alert_message: str = Field(..., description="User-friendly alert message")
    suggested_action: str = Field(..., description="Recommended action")

class SpendingPatternInsight(BaseModel):
    """Schema for spending pattern insights"""
    pattern_type: str = Field(..., description="Pattern type: seasonal, weekly, monthly, recurring")
    category: str = Field(..., description="Related category")
    insight_message: str = Field(..., description="Insight message")
    recommendation: str = Field(..., description="Actionable recommendation")
    potential_savings: Optional[float] = Field(None, description="Potential savings amount")

class RecommendationResponse(BaseModel):
    """Complete recommendation response"""
    waste_prevention_alerts: List[WastePreventionAlert] = []
    anomaly_alerts: List[CategoryAnomalyAlert] = []
    pattern_insights: List[SpendingPatternInsight] = []
    generated_at: datetime = Field(default_factory=datetime.now)

# LLM Response Schemas (for structured JSON parsing)
class LLMWastePreventionResponse(BaseModel):
    """Schema for LLM waste prevention response"""
    estimated_shelf_life_days: int = Field(..., ge=1, le=365)
    risk_level: Literal["low", "medium", "high"]
    alert_message: str = Field(..., min_length=10, max_length=200)

class LLMAnomalyResponse(BaseModel):
    """Schema for LLM anomaly detection response"""
    anomaly_percentage: float = Field(..., description="Anomaly percentage")
    severity: Literal["mild", "moderate", "severe"]
    alert_message: str = Field(..., min_length=10, max_length=200)
    suggested_action: str = Field(..., min_length=10, max_length=200)

class LLMPatternResponse(BaseModel):
    """Schema for LLM pattern analysis response"""
    pattern_type: Literal["seasonal", "weekly", "monthly", "recurring"]
    insight_message: str = Field(..., min_length=10, max_length=200)
    recommendation: str = Field(..., min_length=10, max_length=200)
    potential_savings: Optional[float] = Field(None, ge=0) 