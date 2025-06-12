"""
Financial Reporting API Endpoints
Provides chart-ready data for frontend visualization
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta

from app.auth.dependencies import get_current_user
from app.schemas.reporting import (
    SpendingDistributionRequest, SpendingDistributionResponse,
    SpendingTrendsRequest, SpendingTrendsResponse,
    CategorySpendingRequest, CategorySpendingResponse,
    BudgetVsActualRequest, BudgetVsActualResponse,
    DashboardResponse, ReportingFilters,
    AggregationPeriod, ChartType
)
from app.services.reporting_service import ReportingService

router = APIRouter()
reporting_service = ReportingService()


@router.get("/health", summary="Reporting Service Health Check")
async def health_check():
    """Public health check for reporting service"""
    return {
        "status": "healthy",
        "service": "financial_reporting",
        "timestamp": datetime.now(),
        "version": "1.0.0"
    }


@router.post("/spending-distribution", response_model=SpendingDistributionResponse)
async def get_spending_distribution(
    request: SpendingDistributionRequest,
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get spending distribution data for pie/bar charts
    
    **Chart Types Supported:**
    - pie: Pie chart
    - donut: Donut chart  
    - bar: Bar chart
    
    **Distribution Types:**
    - category: Group by expense categories
    - merchant: Group by merchant names
    """
    try:
        result = await reporting_service.get_spending_distribution(
            user_id=current_user["id"],
            distribution_type=request.distribution_type,
            filters=request.filters,
            chart_type=request.chart_type,
            limit=request.limit
        )
        
        if result["status"] == "error":
            raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
        
        return SpendingDistributionResponse(**result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate spending distribution: {str(e)}")


@router.get("/spending-distribution", response_model=SpendingDistributionResponse)
async def get_spending_distribution_simple(
    distribution_type: str = Query(..., description="Distribution type: category or merchant"),
    chart_type: ChartType = Query(ChartType.PIE, description="Chart type"),
    limit: int = Query(10, ge=1, le=50, description="Maximum items to return"),
    start_date: Optional[date] = Query(None, description="Start date filter"),
    end_date: Optional[date] = Query(None, description="End date filter"),
    min_amount: Optional[float] = Query(None, ge=0, description="Minimum amount filter"),
    max_amount: Optional[float] = Query(None, ge=0, description="Maximum amount filter"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get spending distribution data (GET version with query parameters)
    """
    try:
        filters = None
        if any([start_date, end_date, min_amount, max_amount]):
            filters = ReportingFilters(
                start_date=start_date,
                end_date=end_date,
                min_amount=min_amount,
                max_amount=max_amount
            )
        
        result = await reporting_service.get_spending_distribution(
            user_id=current_user["id"],
            distribution_type=distribution_type,
            filters=filters,
            chart_type=chart_type,
            limit=limit
        )
        
        if result["status"] == "error":
            raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
        
        return SpendingDistributionResponse(**result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate spending distribution: {str(e)}")


@router.get("/spending-trends")
async def get_spending_trends(
    aggregation_period: AggregationPeriod = Query(AggregationPeriod.MONTHLY, description="Time aggregation period"),
    chart_type: ChartType = Query(ChartType.LINE, description="Chart type"),
    include_average: bool = Query(True, description="Include average trend line"),
    start_date: Optional[date] = Query(None, description="Start date filter"),
    end_date: Optional[date] = Query(None, description="End date filter"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get spending trends over time for line/area charts
    
    **Aggregation Periods:**
    - daily: Daily aggregation
    - weekly: Weekly aggregation
    - monthly: Monthly aggregation
    - quarterly: Quarterly aggregation
    - yearly: Yearly aggregation
    
    **Returns:** Time-series data suitable for Chart.js line/area charts
    """
    try:
        filters = None
        if start_date or end_date:
            filters = ReportingFilters(start_date=start_date, end_date=end_date)
        
        # Use AI analysis service for trends (it already provides chart-ready data)
        from app.services.ai_analysis_service import AIAnalysisService
        ai_service = AIAnalysisService()
        
        # Get spending patterns which includes trend data
        patterns = await ai_service.analyze_spending_patterns(
            current_user["id"],
            period="weekly" if aggregation_period == AggregationPeriod.WEEKLY else "daily"
        )
        
        if patterns["status"] != "success":
            raise HTTPException(status_code=500, detail="Failed to analyze spending patterns")
        
        # Transform AI analysis data to chart format
        chart_data = {
            "status": "success",
            "aggregation_period": aggregation_period.value,
            "labels": [],
            "datasets": [],
            "summary": patterns.get("summary", {}),
            "chart_config": {
                "type": chart_type.value,
                "responsive": True,
                "plugins": {
                    "legend": {"position": "top"},
                    "tooltip": {"mode": "index", "intersect": False}
                },
                "scales": {
                    "x": {"title": {"display": True, "text": "Time Period"}},
                    "y": {
                        "title": {"display": True, "text": "Amount ($)"},
                        "beginAtZero": True,
                        "ticks": {"callback": "function(value) { return '$' + value.toFixed(2); }"}
                    }
                }
            },
            "generated_at": datetime.now()
        }
        
        # Extract trend data from patterns
        if "daily_patterns" in patterns:
            daily_data = patterns["daily_patterns"]
            chart_data["labels"] = [item["day"] for item in daily_data]
            chart_data["datasets"] = [{
                "label": "Daily Spending",
                "values": [item["total_amount"] for item in daily_data],
                "border_color": "#36A2EB",
                "background_color": "#36A2EB20" if chart_type == ChartType.AREA else "transparent",
                "fill": chart_type == ChartType.AREA
            }]
            
            if include_average:
                avg_amount = sum(item["total_amount"] for item in daily_data) / len(daily_data)
                chart_data["datasets"].append({
                    "label": "Average",
                    "values": [avg_amount] * len(daily_data),
                    "border_color": "#FF6384",
                    "background_color": "transparent",
                    "fill": False
                })
        
        return chart_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate spending trends: {str(e)}")


@router.get("/category-spending-over-time")
async def get_category_spending_over_time(
    aggregation_period: AggregationPeriod = Query(AggregationPeriod.MONTHLY, description="Time aggregation period"),
    chart_type: ChartType = Query(ChartType.LINE, description="Chart type"),
    stacked: bool = Query(False, description="Whether to stack categories"),
    category_ids: Optional[str] = Query(None, description="Comma-separated category IDs"),
    start_date: Optional[date] = Query(None, description="Start date filter"),
    end_date: Optional[date] = Query(None, description="End date filter"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get category spending over time for multi-line or stacked charts
    
    **Returns:** Multi-dataset time-series data for comparing categories over time
    """
    try:
        # Parse category IDs
        category_id_list = None
        if category_ids:
            category_id_list = [id.strip() for id in category_ids.split(",")]
        
        filters = None
        if start_date or end_date:
            filters = ReportingFilters(start_date=start_date, end_date=end_date)
        
        # Use AI analytics summary which provides category breakdown
        from app.services.ai_analysis_service import AIAnalysisService
        ai_service = AIAnalysisService()
        
        analytics = await ai_service.get_analytics_summary(current_user["id"])
        
        if analytics["status"] != "success":
            raise HTTPException(status_code=500, detail="Failed to get analytics data")
        
        # Transform category data to time series format
        category_breakdown = analytics.get("category_breakdown", [])
        
        chart_data = {
            "status": "success",
            "aggregation_period": aggregation_period.value,
            "labels": ["Current Period"],  # Simplified for now
            "datasets": [],
            "categories_included": [],
            "chart_config": {
                "type": chart_type.value,
                "responsive": True,
                "plugins": {"legend": {"position": "top"}},
                "scales": {
                    "x": {"stacked": stacked, "title": {"display": True, "text": "Time Period"}},
                    "y": {
                        "stacked": stacked,
                        "beginAtZero": True,
                        "title": {"display": True, "text": "Amount ($)"},
                        "ticks": {"callback": "function(value) { return '$' + value.toFixed(2); }"}
                    }
                }
            },
            "generated_at": datetime.now()
        }
        
        # Color palette for categories
        colors = ["#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0", "#9966FF", "#FF9F40"]
        
        for i, category in enumerate(category_breakdown[:6]):  # Limit to 6 categories
            chart_data["datasets"].append({
                "label": category["category"],
                "values": [category["amount"]],
                "border_color": colors[i % len(colors)],
                "background_color": f"{colors[i % len(colors)]}40" if stacked else "transparent",
                "fill": stacked
            })
            chart_data["categories_included"].append(category["category"])
        
        return chart_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate category spending data: {str(e)}")


@router.get("/budget-vs-actual")
async def get_budget_vs_actual(
    period_start: date = Query(..., description="Budget period start date"),
    period_end: date = Query(..., description="Budget period end date"),
    chart_type: ChartType = Query(ChartType.BAR, description="Chart type"),
    category_ids: Optional[str] = Query(None, description="Comma-separated category IDs"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get budget vs actual spending comparison
    
    **Note:** Uses AI-generated budget suggestions as budget baseline
    
    **Returns:** Grouped bar chart data comparing budgeted vs actual amounts
    """
    try:
        # Parse category IDs
        category_id_list = None
        if category_ids:
            category_id_list = [id.strip() for id in category_ids.split(",")]
        
        result = await reporting_service.get_budget_vs_actual(
            user_id=current_user["id"],
            period_start=period_start,
            period_end=period_end,
            category_ids=category_id_list,
            chart_type=chart_type
        )
        
        if result["status"] == "error":
            raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
        
        return BudgetVsActualResponse(**result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate budget comparison: {str(e)}")


@router.get("/dashboard", response_model=DashboardResponse)
async def get_dashboard_data(
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Get comprehensive dashboard data with summary metrics and quick charts
    
    **Includes:**
    - Monthly spending summary
    - Month-over-month comparison
    - Top spending category
    - Quick visualization data
    - Recent transactions
    - Financial alerts
    """
    try:
        result = await reporting_service.get_dashboard_summary(current_user["id"])
        
        if result["status"] == "error":
            raise HTTPException(status_code=500, detail=result.get("error", "Unknown error"))
        
        return DashboardResponse(**result)
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate dashboard data: {str(e)}")


@router.get("/export")
async def export_report(
    report_type: str = Query(..., description="Type of report to export"),
    format: str = Query("csv", description="Export format: csv, xlsx, pdf"),
    start_date: Optional[date] = Query(None, description="Start date filter"),
    end_date: Optional[date] = Query(None, description="End date filter"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Export financial reports in various formats
    
    **Supported Formats:**
    - csv: Comma-separated values
    - xlsx: Excel spreadsheet
    - pdf: PDF document
    
    **Report Types:**
    - spending-distribution
    - spending-trends
    - category-analysis
    - budget-comparison
    """
    try:
        # This would typically generate a file and return a download URL
        # For now, return a placeholder response
        
        export_data = {
            "status": "success",
            "download_url": f"/api/reports/downloads/{report_type}_{format}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.{format}",
            "file_size": 1024,  # Placeholder
            "expires_at": datetime.now() + timedelta(hours=24),
            "format": format,
            "report_type": report_type,
            "generated_at": datetime.now()
        }
        
        return export_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to export report: {str(e)}")


@router.get("/custom")
async def generate_custom_report(
    report_name: str = Query(..., description="Custom report name"),
    metrics: str = Query(..., description="Comma-separated metrics to include"),
    dimensions: str = Query(..., description="Comma-separated dimensions to group by"),
    chart_type: ChartType = Query(ChartType.BAR, description="Chart type"),
    start_date: Optional[date] = Query(None, description="Start date filter"),
    end_date: Optional[date] = Query(None, description="End date filter"),
    current_user: Dict[str, Any] = Depends(get_current_user)
):
    """
    Generate custom financial reports with user-defined metrics and dimensions
    
    **Available Metrics:**
    - total_amount, average_amount, transaction_count, category_count
    
    **Available Dimensions:**
    - category, merchant, date, day_of_week, month
    """
    try:
        # Parse metrics and dimensions
        metric_list = [m.strip() for m in metrics.split(",")]
        dimension_list = [d.strip() for d in dimensions.split(",")]
        
        # This would implement custom report generation logic
        # For now, return a basic structure
        
        custom_data = {
            "status": "success",
            "report_name": report_name,
            "report_data": [],  # Would contain actual custom report data
            "chart_config": {
                "type": chart_type.value,
                "responsive": True,
                "plugins": {"legend": {"position": "top"}},
                "scales": {
                    "y": {
                        "beginAtZero": True,
                        "title": {"display": True, "text": "Value"}
                    }
                }
            },
            "metadata": {
                "report_type": "custom",
                "data_freshness": datetime.now(),
                "cache_duration": 3600,
                "export_formats": ["csv", "xlsx", "pdf"]
            },
            "generated_at": datetime.now()
        }
        
        return custom_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate custom report: {str(e)}") 