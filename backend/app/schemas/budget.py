"""
Budget Management Schemas
Pydantic models for budget management system
"""

from pydantic import BaseModel, Field, validator
from typing import List, Dict, Any, Optional
from datetime import datetime, date
from enum import Enum
from decimal import Decimal


class BudgetPeriod(str, Enum):
    """Budget period options"""
    MONTHLY = "monthly"
    QUARTERLY = "quarterly"
    YEARLY = "yearly"


class BudgetStatus(str, Enum):
    """Budget status options"""
    ACTIVE = "active"
    INACTIVE = "inactive"
    ARCHIVED = "archived"


class CategoryBudgetCreate(BaseModel):
    """Create category budget request"""
    category_id: str = Field(description="Category ID")
    allocated_amount: float = Field(gt=0, description="Allocated budget amount")
    
    @validator('allocated_amount')
    def validate_amount(cls, v):
        if v <= 0:
            raise ValueError('Budget amount must be positive')
        return round(v, 2)


class CategoryBudgetUpdate(BaseModel):
    """Update category budget request"""
    allocated_amount: Optional[float] = Field(None, gt=0, description="New allocated amount")
    
    @validator('allocated_amount')
    def validate_amount(cls, v):
        if v is not None and v <= 0:
            raise ValueError('Budget amount must be positive')
        return round(v, 2) if v is not None else v


class CategoryBudgetResponse(BaseModel):
    """Category budget response"""
    id: str = Field(description="Budget ID")
    category_id: str = Field(description="Category ID")
    category_name: str = Field(description="Category name")
    allocated_amount: float = Field(description="Allocated budget amount")
    spent_amount: float = Field(description="Amount spent so far")
    remaining_amount: float = Field(description="Remaining budget amount")
    utilization_percentage: float = Field(description="Budget utilization percentage")
    status: str = Field(description="Budget status (under/over/on_track)")
    created_at: datetime = Field(description="Creation timestamp")
    updated_at: datetime = Field(description="Last update timestamp")


class BudgetCreate(BaseModel):
    """Create budget request"""
    name: str = Field(min_length=1, max_length=100, description="Budget name")
    total_amount: float = Field(gt=0, description="Total budget amount")
    period: BudgetPeriod = Field(description="Budget period")
    start_date: date = Field(description="Budget start date")
    end_date: date = Field(description="Budget end date")
    auto_allocate: bool = Field(default=True, description="Auto-allocate to categories based on optimal percentages")
    category_budgets: Optional[List[CategoryBudgetCreate]] = Field(None, description="Manual category allocations")
    
    @validator('total_amount')
    def validate_total_amount(cls, v):
        if v <= 0:
            raise ValueError('Total budget amount must be positive')
        return round(v, 2)
    
    @validator('end_date')
    def validate_end_date(cls, v, values):
        if 'start_date' in values and v <= values['start_date']:
            raise ValueError('End date must be after start date')
        return v


class BudgetUpdate(BaseModel):
    """Update budget request"""
    name: Optional[str] = Field(None, min_length=1, max_length=100, description="Budget name")
    total_amount: Optional[float] = Field(None, gt=0, description="Total budget amount")
    status: Optional[BudgetStatus] = Field(None, description="Budget status")
    
    @validator('total_amount')
    def validate_total_amount(cls, v):
        if v is not None and v <= 0:
            raise ValueError('Total budget amount must be positive')
        return round(v, 2) if v is not None else v


class BudgetResponse(BaseModel):
    """Budget response"""
    id: str = Field(description="Budget ID")
    user_id: str = Field(description="User ID")
    name: str = Field(description="Budget name")
    total_amount: float = Field(description="Total budget amount")
    spent_amount: float = Field(description="Total amount spent")
    remaining_amount: float = Field(description="Remaining budget amount")
    period: str = Field(description="Budget period")
    start_date: date = Field(description="Budget start date")
    end_date: date = Field(description="Budget end date")
    status: str = Field(description="Budget status")
    utilization_percentage: float = Field(description="Overall budget utilization percentage")
    category_budgets: List[CategoryBudgetResponse] = Field(description="Category budget breakdown")
    created_at: datetime = Field(description="Creation timestamp")
    updated_at: datetime = Field(description="Last update timestamp")


class BudgetListResponse(BaseModel):
    """Budget list response"""
    budgets: List[BudgetResponse] = Field(description="List of budgets")
    total_count: int = Field(description="Total number of budgets")
    active_budget: Optional[BudgetResponse] = Field(None, description="Currently active budget")


class BudgetSummaryResponse(BaseModel):
    """Budget summary response"""
    current_budget: Optional[BudgetResponse] = Field(None, description="Current active budget")
    monthly_summary: Dict[str, Any] = Field(description="Monthly budget summary")
    category_performance: List[Dict[str, Any]] = Field(description="Category performance metrics")
    alerts: List[Dict[str, Any]] = Field(description="Budget alerts and warnings")
    recommendations: List[Dict[str, Any]] = Field(description="Budget optimization recommendations")


class OptimalBudgetRequest(BaseModel):
    """Request for optimal budget allocation"""
    total_amount: float = Field(gt=0, description="Total budget amount to allocate")
    period: BudgetPeriod = Field(description="Budget period")
    user_preferences: Optional[Dict[str, float]] = Field(None, description="User preference weights for categories")
    
    @validator('total_amount')
    def validate_total_amount(cls, v):
        if v <= 0:
            raise ValueError('Total budget amount must be positive')
        return round(v, 2)


class OptimalBudgetResponse(BaseModel):
    """Optimal budget allocation response"""
    total_amount: float = Field(description="Total budget amount")
    recommended_allocations: List[Dict[str, Any]] = Field(description="Recommended category allocations")
    allocation_rationale: Dict[str, str] = Field(description="Explanation for each allocation")
    alternative_scenarios: List[Dict[str, Any]] = Field(description="Alternative allocation scenarios")
    confidence_score: float = Field(description="Confidence score for recommendations")


class BudgetAnalyticsResponse(BaseModel):
    """Budget analytics response"""
    period_comparison: Dict[str, Any] = Field(description="Period-over-period comparison")
    trend_analysis: Dict[str, Any] = Field(description="Budget trend analysis")
    category_insights: List[Dict[str, Any]] = Field(description="Category-specific insights")
    forecasting: Dict[str, Any] = Field(description="Budget forecasting data")
    efficiency_metrics: Dict[str, Any] = Field(description="Budget efficiency metrics")


class BudgetCategoryCreate(BaseModel):
    """Schema for creating a budget category"""
    category_id: str = Field(description="Category ID")
    monthly_limit: float = Field(gt=0, description="Monthly budget limit for this category")
    is_active: bool = Field(default=True, description="Whether this budget category is active")


class BudgetCategoryUpdate(BaseModel):
    """Schema for updating a budget category"""
    monthly_limit: Optional[float] = Field(None, gt=0, description="Monthly budget limit for this category")
    is_active: Optional[bool] = Field(None, description="Whether this budget category is active")


class BudgetCategoryResponse(BaseModel):
    """Schema for budget category response"""
    id: str = Field(description="Budget category ID")
    user_id: str = Field(description="User ID")
    category_id: str = Field(description="Category ID")
    category_name: str = Field(description="Category name")
    monthly_limit: float = Field(description="Monthly budget limit")
    is_active: bool = Field(description="Whether this budget category is active")
    created_at: datetime = Field(description="Creation timestamp")
    updated_at: datetime = Field(description="Last update timestamp")


class UserBudgetCreate(BaseModel):
    """Schema for creating user's overall budget"""
    total_monthly_budget: float = Field(gt=0, description="Total monthly budget amount")
    currency: str = Field(default="TRY", description="Budget currency")
    auto_allocate: bool = Field(default=True, description="Whether to auto-allocate budget to categories")


class UserBudgetUpdate(BaseModel):
    """Schema for updating user's overall budget"""
    total_monthly_budget: Optional[float] = Field(None, gt=0, description="Total monthly budget amount")
    currency: Optional[str] = Field(None, description="Budget currency")
    auto_allocate: Optional[bool] = Field(None, description="Whether to auto-allocate budget to categories")


class UserBudgetResponse(BaseModel):
    """Schema for user budget response"""
    id: str = Field(description="Budget ID")
    user_id: str = Field(description="User ID")
    total_monthly_budget: float = Field(description="Total monthly budget")
    currency: str = Field(description="Budget currency")
    auto_allocate: bool = Field(description="Auto-allocation setting")
    created_at: datetime = Field(description="Creation timestamp")
    updated_at: datetime = Field(description="Last update timestamp")


class BudgetAllocationRequest(BaseModel):
    """Schema for budget allocation request"""
    total_budget: float = Field(gt=0, description="Total budget to allocate")
    categories: Optional[List[str]] = Field(None, description="Specific categories to allocate to")


class BudgetAllocationResponse(BaseModel):
    """Schema for budget allocation response"""
    total_budget: float = Field(description="Total budget amount")
    allocations: List[Dict[str, Any]] = Field(description="Budget allocations per category")
    allocation_method: str = Field(description="Method used for allocation")
    generated_at: datetime = Field(description="Allocation generation timestamp")


class BudgetSummaryResponse(BaseModel):
    """Schema for budget summary response"""
    user_budget: UserBudgetResponse = Field(description="User's overall budget")
    category_budgets: List[BudgetCategoryResponse] = Field(description="Category-wise budgets")
    total_allocated: float = Field(description="Total allocated amount")
    remaining_budget: float = Field(description="Remaining unallocated budget")
    allocation_percentage: float = Field(description="Percentage of budget allocated") 