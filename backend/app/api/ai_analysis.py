"""
AI Analysis API Endpoints
AI-powered spending analysis, savings suggestions, budget planning
"""

import logging
from typing import Dict, Any, Optional
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.security import HTTPBearer

from app.auth.dependencies import get_current_user
from app.services.ai_analysis_service import AIAnalysisService
from app.services.advanced_analysis_service import AdvancedAnalysisService
from app.schemas.ai_analysis import (
    SpendingPatternRequest,
    SpendingPatternResponse,
    SavingsSuggestionsResponse,
    BudgetSuggestionsResponse,
    AnalyticsSummaryResponse,
    AdvancedAnalysisResponse,
    AnalysisPeriod
)

logger = logging.getLogger(__name__)

router = APIRouter(tags=["AI Analysis"])
security = HTTPBearer()

# Initialize services
ai_analysis_service = AIAnalysisService()
advanced_analysis_service = AdvancedAnalysisService()


@router.get("/analytics/summary", response_model=AnalyticsSummaryResponse)
async def get_analytics_summary(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get comprehensive spending analytics summary for charts and visualizations
    
    Provides data structured for frontend charts including:
    - Overview metrics (7 days, 30 days)
    - Category breakdown for pie charts
    - Daily spending trends for line charts
    - Top merchants by spending
    """
    try:
        logger.info(f"Getting analytics summary for user {current_user['id']}")
        
        result = await ai_analysis_service.get_analytics_summary(current_user['id'])
        
        if result['status'] == 'error':
            raise HTTPException(status_code=500, detail=result.get('message', 'Analytics summary generation failed'))
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Analytics summary failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Analytics summary generation failed")


@router.post("/analysis/spending-patterns", response_model=SpendingPatternResponse)
async def analyze_spending_patterns(
    request: SpendingPatternRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Analyze user's spending patterns over specified period
    
    Identifies patterns in:
    - Daily spending habits
    - Category concentration
    - Spending variance and trends
    
    Includes AI-generated insights when available.
    """
    try:
        logger.info(f"Analyzing spending patterns for user {current_user['id']}")
        
        # Convert period to days
        days_map = {
            AnalysisPeriod.WEEK: 7,
            AnalysisPeriod.MONTH: 30,
            AnalysisPeriod.QUARTER: 90
        }
        days = days_map.get(request.analysis_period, 30)
        
        result = await ai_analysis_service.analyze_spending_patterns(current_user['id'], days)
        
        if result['status'] == 'error':
            raise HTTPException(status_code=500, detail=result.get('message', 'Spending pattern analysis failed'))
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Spending pattern analysis failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Spending pattern analysis failed")


@router.get("/suggestions/savings", response_model=SavingsSuggestionsResponse)
async def get_savings_suggestions(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Generate personalized savings suggestions based on spending analysis
    
    Analyzes last 60 days of spending to identify:
    - High-spending categories with savings potential
    - AI-generated actionable savings tips
    - Potential monthly savings amounts
    """
    try:
        logger.info(f"Generating savings suggestions for user {current_user['id']}")
        
        result = await ai_analysis_service.generate_savings_suggestions(current_user['id'])
        
        if result['status'] == 'error':
            raise HTTPException(status_code=500, detail=result.get('message', 'Savings suggestions generation failed'))
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Savings suggestions generation failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Savings suggestions generation failed")


@router.get("/suggestions/budget", response_model=BudgetSuggestionsResponse)
async def get_budget_suggestions(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Generate budget planning suggestions based on spending history
    
    Analyzes last 90 days of spending to provide:
    - Category-wise spending analysis
    - Recommended monthly budgets per category
    - AI-powered budget optimization insights
    """
    try:
        logger.info(f"Generating budget suggestions for user {current_user['id']}")
        
        result = await ai_analysis_service.generate_budget_suggestions(current_user['id'])
        
        if result['status'] == 'error':
            raise HTTPException(status_code=500, detail=result.get('message', 'Budget suggestions generation failed'))
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Budget suggestions generation failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Budget suggestions generation failed")


@router.get("/analysis/recurring-expenses")
async def get_recurring_expenses(
    days: int = Query(default=90, ge=30, le=365, description="Number of days to analyze"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Identify recurring expense patterns
    
    Analyzes expense history to find:
    - Regularly occurring expenses (subscriptions, bills, etc.)
    - Frequency patterns (daily, weekly, monthly)
    - Amount consistency and confidence scores
    """
    try:
        logger.info(f"Identifying recurring expenses for user {current_user['id']}")
        
        result = await advanced_analysis_service.identify_recurring_expenses(current_user['id'], days)
        
        return {
            'status': 'success',
            'analysis_period': f'{days} days',
            'recurring_expenses': result,
            'total_patterns': len(result),
            'generated_at': datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Recurring expenses identification failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Recurring expenses identification failed")


@router.get("/analysis/price-changes")
async def get_price_changes(
    days: int = Query(default=180, ge=60, le=365, description="Number of days to analyze"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Track price changes for products over time
    
    Monitors product prices across purchases to identify:
    - Significant price increases/decreases
    - Price trends for frequently purchased items
    - Best time to buy based on price history
    """
    try:
        logger.info(f"Tracking price changes for user {current_user['id']}")
        
        result = await advanced_analysis_service.track_price_changes(current_user['id'], days)
        
        return {
            'status': 'success',
            'analysis_period': f'{days} days',
            'price_changes': result,
            'total_changes': len(result),
            'generated_at': datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Price change tracking failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Price change tracking failed")


@router.get("/analysis/product-expiration")
async def get_product_expiration(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Track product expiration dates from receipt data
    
    Analyzes recent purchases to identify:
    - Products expiring within 7 days
    - Estimated expiration dates based on product type
    - Waste prevention alerts
    """
    try:
        logger.info(f"Tracking product expiration for user {current_user['id']}")
        
        result = await advanced_analysis_service.track_product_expiration(current_user['id'])
        
        return {
            'status': 'success',
            'expiring_products': result,
            'total_alerts': len(result),
            'generated_at': datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Product expiration tracking failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Product expiration tracking failed")


@router.get("/analysis/spending-patterns")
async def get_spending_patterns(
    days: int = Query(default=60, ge=30, le=180, description="Number of days to analyze"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Analyze daily/weekly spending patterns
    
    Provides insights into:
    - Daily spending habits (which days you spend most/least)
    - Weekly spending variance
    - Pattern-based recommendations
    """
    try:
        logger.info(f"Analyzing spending patterns for user {current_user['id']}")
        
        result = await advanced_analysis_service.analyze_spending_patterns(current_user['id'], days)
        
        if result['status'] == 'error':
            raise HTTPException(status_code=500, detail=result['message'])
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Spending pattern analysis failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Spending pattern analysis failed")


@router.get("/analysis/advanced", response_model=AdvancedAnalysisResponse)
async def get_advanced_analysis(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get comprehensive advanced analysis combining all features
    
    Provides a complete analysis including:
    - Recurring expense patterns
    - Price change alerts
    - Product expiration warnings
    """
    try:
        logger.info(f"Running advanced analysis for user {current_user['id']}")
        
        # Run all advanced analyses in parallel
        import asyncio
        
        recurring_task = advanced_analysis_service.identify_recurring_expenses(current_user['id'], 90)
        price_changes_task = advanced_analysis_service.track_price_changes(current_user['id'], 180)
        expiration_task = advanced_analysis_service.track_product_expiration(current_user['id'])
        
        recurring_expenses, price_changes, expiration_alerts = await asyncio.gather(
            recurring_task, price_changes_task, expiration_task
        )
        
        return {
            'status': 'success',
            'recurring_expenses': recurring_expenses,
            'price_changes': price_changes,
            'expiration_alerts': expiration_alerts,
            'generated_at': datetime.now()
        }
        
    except Exception as e:
        logger.error(f"Advanced analysis failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Advanced analysis failed")


@router.get("/health")
async def ai_service_health():
    """
    Check AI service health and availability
    
    Returns status of:
    - AI analysis service
    - Ollama model availability
    - Service capabilities
    """
    try:
        # Check AI service availability
        ai_available = ai_analysis_service._model_available if hasattr(ai_analysis_service, '_model_available') else False
        
        return {
            'status': 'healthy',
            'ai_model_available': ai_available,
            'model_name': ai_analysis_service.model_name if hasattr(ai_analysis_service, 'model_name') else 'qwen2.5:3b',
            'services': {
                'spending_analysis': True,
                'savings_suggestions': True,
                'budget_planning': True,
                'recurring_expenses': True,
                'price_tracking': True,
                'expiration_tracking': True
            },
            'timestamp': datetime.now()
        }
        
    except Exception as e:
        logger.error(f"AI service health check failed: {str(e)}")
        return {
            'status': 'degraded',
            'error': str(e),
            'timestamp': datetime.now()
        } 