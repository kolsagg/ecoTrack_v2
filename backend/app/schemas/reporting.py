"""
Financial Reporting Schemas
Pydantic models for financial reporting and visualization data
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
from datetime import datetime, date
from enum import Enum


class ChartType(str, Enum):
    """Chart type options"""
    PIE = "pie"
    BAR = "bar"
    LINE = "line"
    DONUT = "donut"


class PeriodType(str, Enum):
    """Period type options for trends"""
    THREE_MONTHS = "3_months"
    SIX_MONTHS = "6_months"
    ONE_YEAR = "1_year"





# A. Pasta/Donut Grafik Schemas
class PieChartDataItem(BaseModel):
    """Single item in pie/donut chart"""
    label: str = Field(description="Category or merchant name")
    value: float = Field(description="Amount spent")
    percentage: float = Field(ge=0, le=100, description="Percentage of total")
    color: str = Field(description="Hex color code")


class PieChartResponse(BaseModel):
    """Pie/Donut chart response"""
    reportTitle: str = Field(description="Report title")
    totalAmount: float = Field(description="Total amount")
    chartType: str = Field(description="Chart type (pie/donut)")
    data: List[PieChartDataItem] = Field(description="Chart data items")


# B. Çubuk Grafik Schemas
class BarChartDataset(BaseModel):
    """Dataset for bar chart"""
    label: str = Field(description="Dataset label")
    color: str = Field(description="Dataset color")
    data: List[float] = Field(description="Data values")


class BarChartResponse(BaseModel):
    """Bar chart response"""
    reportTitle: str = Field(description="Report title")
    chartType: str = Field(description="Chart type (bar)")
    labels: List[str] = Field(description="Category labels")
    datasets: List[BarChartDataset] = Field(description="Chart datasets")


# C. Çizgi Grafik Schemas
class LineChartDataPoint(BaseModel):
    """Single data point in line chart"""
    x: int = Field(description="X-axis position")
    y: float = Field(description="Y-axis value (amount)")


class LineChartDataset(BaseModel):
    """Dataset for line chart"""
    label: str = Field(description="Dataset label")
    color: str = Field(description="Line color")
    data: List[LineChartDataPoint] = Field(description="Data points")


class LineChartResponse(BaseModel):
    """Line chart response"""
    reportTitle: str = Field(description="Report title")
    chartType: str = Field(description="Chart type (line)")
    xAxisLabels: Dict[str, str] = Field(description="X-axis labels mapping")
    datasets: List[LineChartDataset] = Field(description="Chart datasets")


# Request Schemas
class MonthlyReportRequest(BaseModel):
    """Request for monthly reports (pie/bar charts)"""
    year: int = Field(description="Year")
    month: int = Field(ge=1, le=12, description="Month (1-12)")
    chart_type: ChartType = Field(description="Chart type")


class TrendReportRequest(BaseModel):
    """Request for trend reports (line charts)"""
    period: PeriodType = Field(description="Time period")
    chart_type: ChartType = Field(default=ChartType.LINE, description="Chart type")


# Dashboard Response
class DashboardSummary(BaseModel):
    """Dashboard summary metrics"""
    current_month_spending: float = Field(description="Current month total spending")
    previous_month_spending: float = Field(description="Previous month total spending")
    month_over_month_change: float = Field(description="Month over month change percentage")
    top_category: str = Field(description="Top spending category")
    top_category_amount: float = Field(description="Top category amount")
    transaction_count: int = Field(description="Total transactions this month")
    average_transaction: float = Field(description="Average transaction amount")


class DashboardResponse(BaseModel):
    """Dashboard data response"""
    summary: DashboardSummary = Field(description="Dashboard summary")
    quick_charts: Dict[str, Any] = Field(description="Quick chart data")
    recent_transactions: List[Dict[str, Any]] = Field(description="Recent transactions")
    generated_at: datetime = Field(description="Generation timestamp") 