"""
API router for AI-powered financial recommendations and insights.
Provides endpoints for waste prevention alerts, anomaly detection, and spending pattern analysis.
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, Any
import logging

from app.schemas.recommendation_schemas import RecommendationResponse
from app.services.recommendation_service import recommendation_service
from app.auth.dependencies import get_current_user
from app.db.supabase_client import get_authenticated_supabase_client
from supabase import Client

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/recommendations", tags=["AI Recommendations"])

@router.get("/", response_model=RecommendationResponse)
async def get_recommendations(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
) -> RecommendationResponse:
    """
    Get comprehensive AI-powered financial recommendations for the current user.
    
    This endpoint provides:
    - Waste prevention alerts for grocery items
    - Category-based spending anomaly alerts
    - Spending pattern insights and optimization suggestions
    
    Returns:
        RecommendationResponse: Complete set of personalized recommendations
    """
    try:
        user_id = current_user["id"]
        logger.info(f"Getting recommendations for user: {user_id}")
        
        recommendations = await recommendation_service.generate_recommendations(user_id, supabase)
        
        logger.info(f"Generated {len(recommendations.waste_prevention_alerts)} waste alerts, "
                   f"{len(recommendations.anomaly_alerts)} anomaly alerts, "
                   f"{len(recommendations.pattern_insights)} pattern insights for user {user_id}")
        
        return recommendations
        
    except Exception as e:
        logger.error(f"Failed to get recommendations for user {current_user.get('id', 'unknown')}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to generate recommendations. Please try again later."
        )

@router.get("/waste-prevention")
async def get_waste_prevention_alerts(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get waste prevention alerts for grocery items.
    
    Analyzes recent grocery purchases and provides alerts for items
    that might expire soon to help prevent food waste.
    """
    try:
        user_id = current_user["id"]
        alerts = await recommendation_service.generate_waste_prevention_alerts(user_id, supabase)
        
        return {
            "waste_prevention_alerts": alerts,
            "count": len(alerts)
        }
        
    except Exception as e:
        logger.error(f"Failed to get waste prevention alerts for user {current_user.get('id', 'unknown')}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to generate waste prevention alerts. Please try again later."
        )

@router.get("/anomaly-alerts")
async def get_anomaly_alerts(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get category-based spending anomaly alerts.
    
    Identifies unusual spending patterns in different categories
    and provides insights about potential budget overruns.
    """
    try:
        user_id = current_user["id"]
        alerts = await recommendation_service.generate_anomaly_alerts(user_id, supabase)
        
        return {
            "anomaly_alerts": alerts,
            "count": len(alerts)
        }
        
    except Exception as e:
        logger.error(f"Failed to get anomaly alerts for user {current_user.get('id', 'unknown')}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to generate anomaly alerts. Please try again later."
        )

@router.get("/pattern-insights")
async def get_pattern_insights(
    current_user: Dict[str, Any] = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Get spending pattern insights and optimization suggestions.
    
    Analyzes historical spending data to identify patterns
    and provides actionable recommendations for optimization.
    """
    try:
        user_id = current_user["id"]
        insights = await recommendation_service.generate_pattern_insights(user_id, supabase)
        
        return {
            "pattern_insights": insights,
            "count": len(insights)
        }
        
    except Exception as e:
        logger.error(f"Failed to get pattern insights for user {current_user.get('id', 'unknown')}: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to generate pattern insights. Please try again later."
        )

@router.get("/health")
async def get_recommendation_health():
    """
    Get health status of the recommendation service.
    
    Returns information about AI model availability and service status.
    """
    try:
        return {
            "service_status": "healthy",
            "ai_model_available": recommendation_service._model_available,
            "model_name": recommendation_service.model_name if recommendation_service._model_available else None,
            "features": {
                "waste_prevention": recommendation_service._model_available,
                "anomaly_detection": recommendation_service._model_available,
                "pattern_analysis": recommendation_service._model_available
            }
        }
        
    except Exception as e:
        logger.error(f"Failed to get recommendation service health: {str(e)}")
        return {
            "service_status": "unhealthy",
            "error": str(e),
            "ai_model_available": False
        }
 