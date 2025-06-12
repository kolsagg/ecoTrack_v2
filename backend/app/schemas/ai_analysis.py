"""
AI Analysis Schemas
Pydantic models for AI analysis requests and responses
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime
from enum import Enum


class AnalysisPeriod(str, Enum):
    """Analysis period options"""
    WEEK = "7_days"
    MONTH = "30_days"
    QUARTER = "90_days"


class SuggestionType(str, Enum):
    """Types of AI suggestions"""
    SAVINGS = "savings"
    BUDGET = "budget"
    CATEGORY_OPTIMIZATION = "category_optimization"
    SPENDING_PATTERN = "spending_pattern"


class SpendingPatternRequest(BaseModel):
    """Request for spending pattern analysis"""
    analysis_period: AnalysisPeriod = Field(default=AnalysisPeriod.MONTH, description="Period to analyze")
    include_ai_insights: bool = Field(default=True, description="Include AI-generated insights")


class SpendingPatternMetrics(BaseModel):
    """Spending pattern metrics"""
    average_daily: float = Field(description="Average daily spending")
    highest_daily: float = Field(description="Highest daily spending")
    lowest_daily: float = Field(description="Lowest daily spending")
    variance: float = Field(description="Spending variance")


class SpendingPattern(BaseModel):
    """Individual spending pattern"""
    type: str = Field(description="Pattern type")
    description: str = Field(description="Pattern description")
    metrics: SpendingPatternMetrics = Field(description="Pattern metrics")


class AIInsight(BaseModel):
    """AI-generated insight"""
    ai_analysis: str = Field(description="AI analysis text")
    confidence: float = Field(ge=0, le=1, description="Confidence score")
    generated_by: str = Field(description="AI model used")


class SpendingPatternResponse(BaseModel):
    """Response for spending pattern analysis"""
    status: str = Field(description="Analysis status")
    analysis_period: str = Field(description="Period analyzed")
    total_expenses: int = Field(description="Total number of expenses")
    total_amount: float = Field(description="Total amount spent")
    patterns: List[SpendingPattern] = Field(description="Identified patterns")
    ai_insights: Optional[AIInsight] = Field(description="AI-generated insights")
    generated_at: datetime = Field(description="Analysis generation time")


class SavingsOpportunity(BaseModel):
    """Savings opportunity details"""
    amount: float = Field(description="Current spending amount")
    percentage: float = Field(description="Percentage of total spending")
    potential_savings: float = Field(description="Potential savings amount")
    priority: str = Field(description="Priority level (high/medium/low)")


class SavingsSuggestion(BaseModel):
    """Individual savings suggestion"""
    type: str = Field(description="Suggestion type")
    category: Optional[str] = Field(description="Related category")
    current_spending: Optional[float] = Field(description="Current spending amount")
    potential_savings: Optional[float] = Field(description="Potential savings")
    suggestion: str = Field(description="Suggestion text")
    priority: Optional[str] = Field(description="Priority level")
    confidence: float = Field(ge=0, le=1, description="Confidence score")


class SavingsSuggestionsResponse(BaseModel):
    """Response for savings suggestions"""
    status: str = Field(description="Generation status")
    analysis_period: str = Field(description="Period analyzed")
    total_analyzed_amount: float = Field(description="Total amount analyzed")
    potential_monthly_savings: float = Field(description="Total potential monthly savings")
    suggestions: List[SavingsSuggestion] = Field(description="Savings suggestions")
    generated_at: datetime = Field(description="Generation time")


class CategoryAnalysis(BaseModel):
    """Category spending analysis"""
    total_amount: float = Field(description="Total amount spent in category")
    transaction_count: int = Field(description="Number of transactions")
    avg_transaction: float = Field(description="Average transaction amount")


class BudgetRecommendation(BaseModel):
    """Budget recommendation for a category"""
    current_spending: float = Field(description="Current spending amount")
    suggested_monthly_budget: float = Field(description="Suggested monthly budget")
    current_percentage: float = Field(description="Current percentage of total spending")
    recommendation: str = Field(description="Recommendation text")


class BudgetSuggestionsResponse(BaseModel):
    """Response for budget suggestions"""
    status: str = Field(description="Generation status")
    analysis_period: str = Field(description="Period analyzed")
    category_analysis: Dict[str, CategoryAnalysis] = Field(description="Analysis by category")
    budget_recommendations: Dict[str, BudgetRecommendation] = Field(description="Budget recommendations")
    ai_insights: Optional[AIInsight] = Field(description="AI-generated budget insights")
    generated_at: datetime = Field(description="Generation time")


class OverviewMetrics(BaseModel):
    """Overview metrics for a period"""
    total_amount: float = Field(description="Total amount spent")
    transaction_count: int = Field(description="Number of transactions")
    avg_transaction: float = Field(description="Average transaction amount")


class CategoryBreakdown(BaseModel):
    """Category breakdown for charts"""
    category: str = Field(description="Category name")
    amount: float = Field(description="Amount spent")
    percentage: float = Field(description="Percentage of total")


class DailySpending(BaseModel):
    """Daily spending data point"""
    date: str = Field(description="Date (YYYY-MM-DD)")
    amount: float = Field(description="Amount spent")


class TopMerchant(BaseModel):
    """Top merchant data"""
    merchant: str = Field(description="Merchant name")
    total_amount: float = Field(description="Total amount spent")


class AnalyticsSummaryResponse(BaseModel):
    """Response for analytics summary"""
    status: str = Field(description="Generation status")
    overview: Dict[str, OverviewMetrics] = Field(description="Overview metrics by period")
    category_breakdown: List[CategoryBreakdown] = Field(description="Spending by category")
    daily_spending: List[DailySpending] = Field(description="Daily spending trend")
    top_merchants: List[TopMerchant] = Field(description="Top merchants by spending")
    generated_at: datetime = Field(description="Generation time")


class RecurringExpensePattern(BaseModel):
    """Recurring expense pattern"""
    description: str = Field(description="Expense description pattern")
    merchant: Optional[str] = Field(description="Merchant name")
    amount_range: Dict[str, float] = Field(description="Amount range (min, max, avg)")
    frequency: str = Field(description="Frequency (daily, weekly, monthly)")
    last_occurrence: datetime = Field(description="Last occurrence date")
    confidence: float = Field(ge=0, le=1, description="Pattern confidence")


class PriceChangeAlert(BaseModel):
    """Price change alert for products"""
    product_name: str = Field(description="Product name")
    merchant: str = Field(description="Merchant name")
    previous_price: float = Field(description="Previous price")
    current_price: float = Field(description="Current price")
    price_change: float = Field(description="Price change amount")
    price_change_percentage: float = Field(description="Price change percentage")
    first_seen: datetime = Field(description="First price recorded")
    last_updated: datetime = Field(description="Last price update")


class ProductExpirationAlert(BaseModel):
    """Product expiration alert"""
    product_name: str = Field(description="Product name")
    expiration_date: datetime = Field(description="Expiration date")
    days_until_expiration: int = Field(description="Days until expiration")
    purchase_date: datetime = Field(description="Purchase date")
    merchant: str = Field(description="Merchant where purchased")
    amount_paid: float = Field(description="Amount paid for product")


class AdvancedAnalysisResponse(BaseModel):
    """Response for advanced analysis features"""
    status: str = Field(description="Analysis status")
    recurring_expenses: List[RecurringExpensePattern] = Field(description="Recurring expense patterns")
    price_changes: List[PriceChangeAlert] = Field(description="Price change alerts")
    expiration_alerts: List[ProductExpirationAlert] = Field(description="Product expiration alerts")
    generated_at: datetime = Field(description="Generation time")


class AIAnalysisRequest(BaseModel):
    """Generic AI analysis request"""
    analysis_type: str = Field(description="Type of analysis requested")
    parameters: Dict[str, Any] = Field(default={}, description="Analysis parameters")
    include_ai_insights: bool = Field(default=True, description="Include AI-generated insights")


class AIAnalysisResponse(BaseModel):
    """Generic AI analysis response"""
    status: str = Field(description="Analysis status")
    analysis_type: str = Field(description="Type of analysis performed")
    results: Dict[str, Any] = Field(description="Analysis results")
    ai_insights: Optional[AIInsight] = Field(description="AI-generated insights")
    generated_at: datetime = Field(description="Generation time")
    processing_time_ms: Optional[int] = Field(description="Processing time in milliseconds") 