"""
Financial Reporting Schemas
Pydantic models for financial reporting and visualization data
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime, date
from enum import Enum


class AggregationPeriod(str, Enum):
    """Aggregation period options"""
    DAILY = "daily"
    WEEKLY = "weekly"
    MONTHLY = "monthly"
    QUARTERLY = "quarterly"
    YEARLY = "yearly"


class ChartType(str, Enum):
    """Chart type options"""
    PIE = "pie"
    BAR = "bar"
    LINE = "line"
    AREA = "area"
    DONUT = "donut"


class ReportingFilters(BaseModel):
    """Common filters for reporting endpoints"""
    start_date: Optional[date] = Field(None, description="Start date for filtering")
    end_date: Optional[date] = Field(None, description="End date for filtering")
    category_ids: Optional[List[str]] = Field(None, description="List of category IDs to filter")
    merchant_names: Optional[List[str]] = Field(None, description="List of merchant names to filter")
    min_amount: Optional[float] = Field(None, ge=0, description="Minimum amount filter")
    max_amount: Optional[float] = Field(None, ge=0, description="Maximum amount filter")


class SpendingDistributionItem(BaseModel):
    """Single item in spending distribution"""
    label: str = Field(description="Category or merchant name")
    value: float = Field(description="Total amount spent")
    percentage: float = Field(ge=0, le=100, description="Percentage of total spending")
    color: str = Field(description="Hex color code for visualization")
    count: int = Field(description="Number of transactions")


class SpendingDistributionRequest(BaseModel):
    """Request for spending distribution report"""
    distribution_type: str = Field(description="Type of distribution (category, merchant)")
    filters: Optional[ReportingFilters] = Field(None, description="Filtering options")
    chart_type: ChartType = Field(default=ChartType.PIE, description="Preferred chart type")
    limit: int = Field(default=10, ge=1, le=50, description="Maximum number of items to return")


class SpendingDistributionResponse(BaseModel):
    """Response for spending distribution report"""
    status: str = Field(description="Response status")
    distribution_type: str = Field(description="Type of distribution")
    total_amount: float = Field(description="Total amount in the distribution")
    total_transactions: int = Field(description="Total number of transactions")
    distribution_data: List[SpendingDistributionItem] = Field(description="Distribution data")
    chart_config: Dict[str, Any] = Field(description="Chart configuration suggestions")
    filters_applied: Optional[ReportingFilters] = Field(description="Applied filters")
    generated_at: datetime = Field(description="Report generation time")


class TrendDataPoint(BaseModel):
    """Single data point in trend analysis"""
    period: str = Field(description="Time period (e.g., '2024-01', 'Week 1')")
    period_date: date = Field(description="Date for the period")
    total_amount: float = Field(description="Total amount for the period")
    transaction_count: int = Field(description="Number of transactions")
    average_amount: float = Field(description="Average transaction amount")


class TrendDataset(BaseModel):
    """Dataset for trend charts"""
    label: str = Field(description="Dataset label (e.g., 'Total Spending', 'Food Category')")
    values: List[float] = Field(description="Data values")
    border_color: str = Field(description="Line/border color")
    background_color: Optional[str] = Field(description="Fill/background color")
    fill: bool = Field(default=False, description="Whether to fill area under line")


class SpendingTrendsRequest(BaseModel):
    """Request for spending trends report"""
    aggregation_period: AggregationPeriod = Field(description="Time aggregation period")
    filters: Optional[ReportingFilters] = Field(None, description="Filtering options")
    chart_type: ChartType = Field(default=ChartType.LINE, description="Preferred chart type")
    include_average: bool = Field(default=True, description="Include average trend line")


class SpendingTrendsResponse(BaseModel):
    """Response for spending trends report"""
    status: str = Field(description="Response status")
    aggregation_period: str = Field(description="Time aggregation period used")
    labels: List[str] = Field(description="Time period labels for x-axis")
    datasets: List[TrendDataset] = Field(description="Trend datasets")
    data_points: List[TrendDataPoint] = Field(description="Detailed data points")
    summary: Dict[str, Any] = Field(description="Trend summary statistics")
    chart_config: Dict[str, Any] = Field(description="Chart configuration suggestions")
    filters_applied: Optional[ReportingFilters] = Field(description="Applied filters")
    generated_at: datetime = Field(description="Report generation time")


class CategorySpendingDataPoint(BaseModel):
    """Data point for category spending over time"""
    period: str = Field(description="Time period")
    period_date: date = Field(description="Date for the period")
    categories: Dict[str, float] = Field(description="Category amounts for this period")


class CategorySpendingRequest(BaseModel):
    """Request for category spending over time"""
    aggregation_period: AggregationPeriod = Field(description="Time aggregation period")
    category_ids: Optional[List[str]] = Field(None, description="Specific categories to include")
    filters: Optional[ReportingFilters] = Field(None, description="Additional filtering options")
    chart_type: ChartType = Field(default=ChartType.LINE, description="Preferred chart type")
    stacked: bool = Field(default=False, description="Whether to stack categories")


class CategorySpendingResponse(BaseModel):
    """Response for category spending over time"""
    status: str = Field(description="Response status")
    aggregation_period: str = Field(description="Time aggregation period used")
    labels: List[str] = Field(description="Time period labels")
    datasets: List[TrendDataset] = Field(description="Category datasets")
    data_points: List[CategorySpendingDataPoint] = Field(description="Detailed data points")
    categories_included: List[str] = Field(description="Categories included in the report")
    chart_config: Dict[str, Any] = Field(description="Chart configuration suggestions")
    filters_applied: Optional[ReportingFilters] = Field(description="Applied filters")
    generated_at: datetime = Field(description="Report generation time")


class BudgetVsActualItem(BaseModel):
    """Budget vs actual comparison item"""
    category: str = Field(description="Category name")
    budgeted: float = Field(description="Budgeted amount")
    actual: float = Field(description="Actual spending")
    variance: float = Field(description="Variance (actual - budgeted)")
    variance_percentage: float = Field(description="Variance as percentage")
    status: str = Field(description="Budget status (under, over, on_track)")
    color: str = Field(description="Status color for visualization")


class BudgetVsActualRequest(BaseModel):
    """Request for budget vs actual report"""
    period_start: date = Field(description="Budget period start date")
    period_end: date = Field(description="Budget period end date")
    category_ids: Optional[List[str]] = Field(None, description="Specific categories to include")
    chart_type: ChartType = Field(default=ChartType.BAR, description="Preferred chart type")


class BudgetVsActualResponse(BaseModel):
    """Response for budget vs actual report"""
    status: str = Field(description="Response status")
    period_start: date = Field(description="Budget period start")
    period_end: date = Field(description="Budget period end")
    comparison_data: List[BudgetVsActualItem] = Field(description="Budget comparison data")
    summary: Dict[str, Any] = Field(description="Overall budget summary")
    chart_config: Dict[str, Any] = Field(description="Chart configuration suggestions")
    generated_at: datetime = Field(description="Report generation time")


class ReportMetadata(BaseModel):
    """Metadata for reports"""
    report_type: str = Field(description="Type of report")
    data_freshness: datetime = Field(description="When the underlying data was last updated")
    cache_duration: int = Field(description="Recommended cache duration in seconds")
    export_formats: List[str] = Field(description="Available export formats")


class CustomReportRequest(BaseModel):
    """Request for custom report generation"""
    report_name: str = Field(description="Custom report name")
    metrics: List[str] = Field(description="Metrics to include")
    dimensions: List[str] = Field(description="Dimensions to group by")
    filters: Optional[ReportingFilters] = Field(None, description="Filtering options")
    aggregation_period: Optional[AggregationPeriod] = Field(None, description="Time aggregation")
    chart_type: ChartType = Field(description="Preferred chart type")


class CustomReportResponse(BaseModel):
    """Response for custom report"""
    status: str = Field(description="Response status")
    report_name: str = Field(description="Report name")
    report_data: List[Dict[str, Any]] = Field(description="Report data")
    chart_config: Dict[str, Any] = Field(description="Chart configuration")
    metadata: ReportMetadata = Field(description="Report metadata")
    generated_at: datetime = Field(description="Report generation time")


class ReportExportRequest(BaseModel):
    """Request for report export"""
    report_type: str = Field(description="Type of report to export")
    format: str = Field(description="Export format (csv, xlsx, pdf)")
    filters: Optional[ReportingFilters] = Field(None, description="Filtering options")
    include_charts: bool = Field(default=True, description="Include charts in export")


class ReportExportResponse(BaseModel):
    """Response for report export"""
    status: str = Field(description="Export status")
    download_url: str = Field(description="URL to download the exported report")
    file_size: int = Field(description="File size in bytes")
    expires_at: datetime = Field(description="Download link expiration time")
    format: str = Field(description="Export format used")


class DashboardSummary(BaseModel):
    """Dashboard summary data"""
    total_spending_current_month: float = Field(description="Current month total spending")
    total_spending_previous_month: float = Field(description="Previous month total spending")
    month_over_month_change: float = Field(description="Month over month change percentage")
    top_category: str = Field(description="Top spending category")
    top_category_amount: float = Field(description="Top category spending amount")
    transaction_count: int = Field(description="Total transactions this month")
    average_transaction: float = Field(description="Average transaction amount")
    budget_utilization: Optional[float] = Field(description="Budget utilization percentage")


class DashboardResponse(BaseModel):
    """Dashboard data response"""
    status: str = Field(description="Response status")
    summary: DashboardSummary = Field(description="Dashboard summary")
    quick_charts: Dict[str, Any] = Field(description="Quick chart data")
    recent_transactions: List[Dict[str, Any]] = Field(description="Recent transactions")
    alerts: List[Dict[str, Any]] = Field(description="Financial alerts")
    generated_at: datetime = Field(description="Dashboard generation time") 