"""
Financial Reporting API Endpoints
Provides chart-ready data according to specified response formats
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional, Dict, Any
from datetime import date, datetime, timedelta
from collections import defaultdict

from app.core.auth import get_current_user
from app.schemas.reporting import (
    MonthlyReportRequest, TrendReportRequest,
    ChartType, PeriodType
)
from app.services.reporting_service import ReportingService
from app.db.supabase_client import get_authenticated_supabase_client, get_supabase_client
from supabase import Client

router = APIRouter()

# Initialize reporting service to get constants
_reporting_service = ReportingService()
MONTH_NAMES = ['', 'January', 'February', 'March', 'April', 'May', 'June', 
               'July', 'August', 'September', 'October', 'November', 'December']
CHART_COLORS = _reporting_service.category_colors


def parse_date_safely(date_str: str) -> date:
    """Safely parse date string from Supabase"""
    try:
        # Handle different date formats from Supabase
        if date_str.endswith('Z'):
            date_str = date_str.replace('Z', '+00:00')
        elif '+' not in date_str and 'T' in date_str:
            date_str = date_str + '+00:00'
        elif 'T' not in date_str:
            # Simple date format like "2024-12-25"
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        
        return datetime.fromisoformat(date_str).date()
    except Exception as e:
        # Fallback: try to parse as simple date
        try:
            return datetime.strptime(date_str[:10], '%Y-%m-%d').date()
        except:
            raise ValueError(f"Cannot parse date: {date_str}")


@router.get("/health", summary="Reporting Service Health Check")
async def health_check():
    """Public health check for reporting service"""
    return {
        "status": "healthy",
        "service": "financial_reporting",
        "timestamp": datetime.now(),
        "version": "2.0.0"
    }


@router.get("/category-distribution", summary="Monthly Category Distribution (Pie/Donut Chart)")
async def get_category_distribution(
    year: int = Query(..., description="Year (e.g., 2025)"),
    month: int = Query(..., ge=1, le=12, description="Month (1-12)"),
    chart_type: ChartType = Query(ChartType.PIE, description="Chart type (pie/donut)"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    **A. Pie/Donut Chart Response**
    
    Returns monthly category distribution in the exact format specified:
    ```json
    {
      "reportTitle": "January 2025 Category Distribution",
      "totalAmount": 2450.75,
      "chartType": "pie",
      "data": [
        { "label": "Food", "value": 1250.75, "percentage": 51.0, "color": "#FF5722" },
        { "label": "Transportation", "value": 890.50, "percentage": 36.3, "color": "#2196F3" }
      ]
    }
    ```
    
    **Usage:** Perfect for showing spending breakdown by category for a specific month
    """
    try:
        # Calculate date range for the month
        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(year, month + 1, 1) - timedelta(days=1)
        
        # Get expense data for the month through expenses table
        query = supabase.table("expenses").select(
            "expense_items(amount, categories(name))"
        ).eq("user_id", current_user["id"]).gte("expense_date", start_date.isoformat()).lte("expense_date", end_date.isoformat())
        
        result = query.execute()
        
        if not result.data:
            return {
                "reportTitle": f"{MONTH_NAMES[month]} {year} Category Distribution",
                "totalAmount": 0.0,
                "chartType": chart_type.value,
                "data": []
            }
        
        # Process data by category
        category_totals = defaultdict(float)
        total_amount = 0.0
        
        for expense in result.data:
            expense_items = expense.get("expense_items", [])
            for item in expense_items:
                category_name = "Other"
                if item.get("categories"):
                    category_name = item["categories"].get("name", "Other")
                
                amount = float(item.get("amount", 0))
                category_totals[category_name] += amount
                total_amount += amount
        
        # Create chart data
        chart_data = []
        for i, (category, amount) in enumerate(sorted(category_totals.items(), key=lambda x: x[1], reverse=True)):
            percentage = (amount / total_amount * 100) if total_amount > 0 else 0
            chart_data.append({
                "label": category,
                "value": round(amount, 2),
                "percentage": round(percentage, 1),
                "color": CHART_COLORS[i % len(CHART_COLORS)]
            })
        
        return {
            "reportTitle": f"{MONTH_NAMES[month]} {year} Category Distribution",
            "totalAmount": round(total_amount, 2),
            "chartType": chart_type.value,
            "data": chart_data
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate category distribution: {str(e)}")


@router.get("/budget-vs-actual", summary="Budget vs Actual Spending (Bar Chart)")
async def get_budget_vs_actual(
    year: int = Query(..., description="Year (e.g., 2024)"),
    month: int = Query(..., ge=1, le=12, description="Month (1-12)"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    **B. Bar Chart Response**
    
    Returns budget vs actual spending comparison in the exact format specified:
    ```json
    {
      "reportTitle": "January 2025 Budget vs. Actual",
      "chartType": "bar",
      "labels": ["Food", "Transportation", "Bills"],
      "datasets": [
        { "label": "Budget", "color": "#4CAF50", "data": [1000, 400, 600] },
        { "label": "Actual", "color": "#F44336", "data": [1250, 350, 580] }
      ]
    }
    ```
    
    **Usage:** Compare budgeted amounts vs actual spending by category
    **Note:** Requires user to have budget set up first
    """
    try:
        # Calculate date range for the month
        start_date = date(year, month, 1)
        if month == 12:
            end_date = date(year + 1, 1, 1) - timedelta(days=1)
        else:
            end_date = date(year, month + 1, 1) - timedelta(days=1)
        
        # Get user's budget for this month first
        user_budget_result = supabase.table("user_budgets").select("id").eq("user_id", current_user["id"]).eq("year", year).eq("month", month).execute()
        
        if not user_budget_result.data:
            raise HTTPException(status_code=404, detail=f"No budget found for {month:02d}/{year}. Please create a budget first.")
        
        user_budget_id = user_budget_result.data[0]["id"]
        
        # Get user's category budgets with category names using user_budget_id
        budget_result = supabase.table("budget_categories").select(
            "*, categories(name)"
        ).eq("user_budget_id", user_budget_id).eq("is_active", True).execute()
        
        if not budget_result.data:
            raise HTTPException(status_code=404, detail=f"No category budgets found for {month:02d}/{year}")
        
        category_budgets = {}
        for cb in budget_result.data:
            category_budgets[cb["category_id"]] = {
                "category_id": cb["category_id"],
                "monthly_limit": cb["monthly_limit"],
                "category_name": cb.get("categories", {}).get("name", "Unknown") if cb.get("categories") else "Unknown"
            }
        
        # Get actual spending for the month through expenses table
        query = supabase.table("expenses").select(
            "expense_items(amount, category_id)"
        ).eq("user_id", current_user["id"]).gte("expense_date", start_date.isoformat()).lte("expense_date", end_date.isoformat())
        
        result = query.execute()
        
        # Calculate actual spending by category
        actual_spending = defaultdict(float)
        for expense in result.data or []:
            expense_items = expense.get("expense_items", [])
            for item in expense_items:
                category_id = item.get("category_id")
                amount = float(item.get("amount", 0))
                if category_id:
                    actual_spending[category_id] += amount
        
        # Prepare chart data
        labels = []
        budget_data = []
        actual_data = []
        
        for category_id, budget_info in category_budgets.items():
            category_name = budget_info["category_name"]
            labels.append(category_name)
            budget_data.append(float(budget_info["monthly_limit"]))
            actual_data.append(actual_spending.get(category_id, 0.0))
        
        return {
            "reportTitle": f"{MONTH_NAMES[month]} {year} Budget vs. Actual",
            "chartType": "bar",
            "labels": labels,
            "datasets": [
                {
                    "label": "Budget",
                    "color": "#4CAF50",
                    "data": budget_data
                },
                {
                    "label": "Actual",
                    "color": "#F44336",
                    "data": actual_data
                }
            ]
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate budget comparison: {str(e)}")


@router.get(
    "/monthly-inflation",
    response_model=List[Dict[str, Any]],
    summary="Get Monthly Product Inflation Data",
    description="Retrieves pre-calculated monthly inflation data for products across the entire platform. Shows month-over-month price changes. Requires authentication.",
    tags=["Financial Reporting"]
)
async def get_monthly_inflation_report(
    year: Optional[int] = Query(None, description="Filter by specific year"),
    month: Optional[int] = Query(None, ge=1, le=12, description="Filter by specific month (1-12)"),
    product_name: Optional[str] = Query(None, description="Filter by product name (partial match)"),
    sort_by: Optional[str] = Query("inflation_percentage", description="Field to sort by (inflation_percentage, year, month, product_name, average_price)"),
    order: Optional[str] = Query("desc", description="Sort order ('asc' or 'desc')"),
    limit: int = Query(100, ge=1, le=1000, description="Maximum number of results"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Fetches the monthly product inflation report from pre-calculated data.
    This endpoint reads from a data store that is updated periodically by a background job.
    Shows month-over-month price changes for products across the platform.
    Requires user authentication.
    
    **Response Format:**
    ```json
    [
      {
        "id": "uuid",
        "product_name": "Süt",
        "year": 2025,
        "month": 1,
        "average_price": 12.50,
        "purchase_count": 45,
        "previous_month_price": 11.80,
        "inflation_percentage": 5.93,
        "last_updated_at": "2025-01-15T10:30:00Z"
      }
    ]
    ```
    """
    try:
        # Build query with filters
        query = supabase.table("global_product_inflation").select("*")
        
        # Apply filters
        if year is not None:
            query = query.eq("year", year)
        if month is not None:
            query = query.eq("month", month)
        if product_name is not None:
            query = query.ilike("product_name", f"%{product_name}%")
        
        # Handle sorting
        sort_column = sort_by or "inflation_percentage"
        order_desc = (order == "desc") if order else True
        
        # Apply sorting and limit
        query = query.order(sort_column, desc=order_desc).limit(limit)
        
        response = query.execute()
        
        return response.data
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to retrieve monthly inflation data: {str(e)}")


@router.get("/spending-trends", summary="Spending Trends Over Time (Line Chart)")
async def get_spending_trends(
    period: PeriodType = Query(PeriodType.SIX_MONTHS, description="Time period for grouping (monthly/yearly)"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    **C. Line Chart Response**
    
    Returns spending trends in the exact format specified:
    ```json
    {
      "reportTitle": "Last 6 Months Spending Trends",
      "chartType": "line",
      "xAxisLabels": { "0": "Jan", "1": "Feb", "2": "Mar", "3": "Apr", "4": "May", "5": "Jun" },
      "datasets": [
        {
          "label": "Spending", "color": "#03A9F4",
          "data": [
            { "x": 0, "y": 2450.75 }, { "x": 1, "y": 2325.25 },
            { "x": 2, "y": 2600.00 }, { "x": 3, "y": 2550.50 },
            { "x": 4, "y": 2800.00 }, { "x": 5, "y": 2750.20 }
          ]
        }
      ]
    }
    ```
    
    **Period Options:**
    - `3_months`: Monthly trend for last 3 months (current month included)
    - `6_months`: Monthly trend for last 6 months (current month included)
    - `1_year`: Monthly trend for last 12 months (current month included)
    """
    try:
        # Calculate date range based on period
        end_date = date.today()
        
        if period == PeriodType.THREE_MONTHS:
            # Son 3 ay (şu anki ay dahil)
            current_month = end_date.replace(day=1)
            start_date = current_month
            for _ in range(2):  # 2 ay geriye git (toplam 3 ay olacak)
                start_date = (start_date - timedelta(days=1)).replace(day=1)
            title = "Last 3 Months Spending Trends"
        elif period == PeriodType.SIX_MONTHS:
            # Son 6 ay (şu anki ay dahil)
            current_month = end_date.replace(day=1)
            start_date = current_month
            for _ in range(5):  # 5 ay geriye git (toplam 6 ay olacak)
                start_date = (start_date - timedelta(days=1)).replace(day=1)
            title = "Last 6 Months Spending Trends"
        elif period == PeriodType.ONE_YEAR:
            # Son 12 ay (şu anki ay dahil)
            current_month = end_date.replace(day=1)
            start_date = current_month
            for _ in range(11):  # 11 ay geriye git (toplam 12 ay olacak)
                start_date = (start_date - timedelta(days=1)).replace(day=1)
            title = "Last 1 Year Spending Trends"
        else:
            # Default: Son 6 ay
            current_month = end_date.replace(day=1)
            start_date = current_month
            for _ in range(5):  # 5 ay geriye git (toplam 6 ay olacak)
                start_date = (start_date - timedelta(days=1)).replace(day=1)
            title = "Last 6 Months Spending Trends"
        
        # Get expense data
        query = supabase.table("expenses").select(
            "total_amount, expense_date"
        ).eq("user_id", current_user["id"]).gte("expense_date", start_date.isoformat()).lte("expense_date", end_date.isoformat())
        
        result = query.execute()
        
        if not result.data:
            return {
                "reportTitle": title,
                "chartType": "line",
                "xAxisLabels": {},
                "datasets": []
            }
        
        # Process monthly trend data
        monthly_totals = defaultdict(float)
        
        for expense in result.data:
            expense_date = parse_date_safely(expense["expense_date"])
            month_key = (expense_date.year, expense_date.month)
            amount = float(expense["total_amount"])
            monthly_totals[month_key] += amount
        
        # Create data points for each month
        data_points = []
        x_axis_labels = {}
        x_index = 0
        
        # Generate month range (şu anki ay dahil)
        current_date = start_date
        month_names_short = _reporting_service.month_names
        
        # Şu anki ayı da dahil etmek için end_date'i bu ayın sonuna kadar al
        end_month = end_date.replace(day=1)
        
        while current_date <= end_month:
            month_key = (current_date.year, current_date.month)
            amount = monthly_totals.get(month_key, 0.0)
            data_points.append({"x": x_index, "y": round(amount, 2)})
            x_axis_labels[str(x_index)] = month_names_short[current_date.month]
            
            # Move to next month
            if current_date.month == 12:
                current_date = current_date.replace(year=current_date.year + 1, month=1)
            else:
                current_date = current_date.replace(month=current_date.month + 1)
            x_index += 1
        
        return {
            "reportTitle": title,
            "chartType": "line",
            "xAxisLabels": x_axis_labels,
            "datasets": [
                {
                    "label": "Monthly Spending",
                    "color": "#03A9F4",
                    "data": data_points
                }
            ]
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate spending trends: {str(e)}")


# Convenience endpoints with POST method for complex requests
@router.post("/category-distribution", summary="Monthly Category Distribution (POST)")
async def post_category_distribution(
    request: MonthlyReportRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """POST version of category distribution endpoint for complex requests"""
    return await get_category_distribution(
        year=request.year,
        month=request.month,
        chart_type=request.chart_type,
        current_user=current_user,
        supabase=supabase
    )


@router.post("/budget-vs-actual", summary="Budget vs Actual Spending (POST)")
async def post_budget_vs_actual(
    request: MonthlyReportRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """POST version of budget vs actual endpoint for complex requests"""
    return await get_budget_vs_actual(
        year=request.year,
        month=request.month,
        current_user=current_user,
        supabase=supabase
    )


@router.post("/spending-trends", summary="Spending Trends Over Time (POST)")
async def post_spending_trends(
    request: TrendReportRequest,
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """POST version of spending trends endpoint for complex requests"""
    return await get_spending_trends(
        period=request.period,
        current_user=current_user,
        supabase=supabase
    )


@router.get("/export", summary="Export Report Data")
async def export_report(
    report_type: str = Query(..., description="Report type (category-distribution, budget-vs-actual, spending-trends)"),
    format: str = Query("json", description="Export format (json, csv)"),
    year: Optional[int] = Query(None, description="Year for monthly reports"),
    month: Optional[int] = Query(None, description="Month for monthly reports"),
    period: Optional[PeriodType] = Query(None, description="Period for trend reports"),
    current_user: dict = Depends(get_current_user),
    supabase: Client = Depends(get_authenticated_supabase_client)
):
    """
    Export report data in various formats
    
    **Supported Report Types:**
    - `category-distribution`: Monthly category breakdown
    - `budget-vs-actual`: Budget comparison
    - `spending-trends`: Spending trends over time
    
    **Supported Formats:**
    - `json`: JSON format (default)
    - `csv`: Comma-separated values
    """
    try:
        # Generate the requested report
        if report_type == "category-distribution":
            if not year or not month:
                raise HTTPException(status_code=400, detail="Year and month required for category distribution")
            result = await get_category_distribution(
                year=year, month=month, chart_type=ChartType.PIE,
                current_user=current_user, supabase=supabase
            )
        elif report_type == "budget-vs-actual":
            if not year or not month:
                raise HTTPException(status_code=400, detail="Year and month required for budget comparison")
            result = await get_budget_vs_actual(
                year=year, month=month,
                current_user=current_user, supabase=supabase
            )
        elif report_type == "spending-trends":
            if not period:
                raise HTTPException(status_code=400, detail="Period required for spending trends")
            result = await get_spending_trends(
                period=period,
                current_user=current_user, supabase=supabase
            )
        else:
            raise HTTPException(status_code=400, detail="Invalid report type")
        
        # For now, return JSON format
        # In a real implementation, you would convert to CSV or other formats
        export_data = {
            "export_format": format,
            "report_type": report_type,
            "generated_at": datetime.now(),
            "data": result
        }
        
        return export_data
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to export report: {str(e)}") 