"""
Financial Reporting Service
Generates chart-ready data according to specified response formats
"""

import asyncio
from datetime import datetime, date, timedelta
from typing import List, Dict, Any, Optional, Tuple
from collections import defaultdict
import calendar

from app.db.supabase_client import get_supabase_client
from app.schemas.reporting import (
    PieChartResponse, PieChartDataItem,
    BarChartResponse, BarChartDataset,
    LineChartResponse, LineChartDataset, LineChartDataPoint,
    DashboardResponse, DashboardSummary,
    ChartType, PeriodType
)
from app.services.budget_service import BudgetService


class ReportingService:
    """Service for generating financial reports and visualization data"""
    
    def __init__(self):
        self.supabase = get_supabase_client()
        self.budget_service = BudgetService()
        
        # Chart color palettes
        self.category_colors = [
            "#FF5722", "#2196F3", "#9C27B0", "#4CAF50", "#FF9800",
            "#607D8B", "#E91E63", "#00BCD4", "#8BC34A", "#FFC107"
        ]
        
        # Turkish month names for labels
        self.month_names = {
            1: "January", 2: "February", 3: "March", 4: "April", 5: "May", 6: "June",
            7: "July", 8: "August", 9: "September", 10: "October", 11: "November", 12: "December"
        }
    
    async def get_monthly_category_distribution(
        self, 
        user_id: str, 
        year: int, 
        month: int, 
        chart_type: ChartType = ChartType.PIE
    ) -> Dict[str, Any]:
        """
        A. Pie/Donut Graph - Monthly Category Distribution
        """
        try:
            # Calculate date range for the month
            start_date = date(year, month, 1)
            if month == 12:
                end_date = date(year + 1, 1, 1) - timedelta(days=1)
            else:
                end_date = date(year, month + 1, 1) - timedelta(days=1)
            
            # Get expense data for the month through expenses table
            query = self.supabase.table("expenses").select(
                "expense_items(amount, category_id, categories(name))"
            ).eq("user_id", user_id).gte("expense_date", start_date.isoformat()).lte("expense_date", end_date.isoformat())
            
            result = query.execute()
            
            if not result.data:
                return self._empty_pie_chart_response(year, month, chart_type)
            
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
                chart_data.append(PieChartDataItem(
                    label=category,
                    value=round(amount, 2),
                    percentage=round(percentage, 1),
                    color=self.category_colors[i % len(self.category_colors)]
                ))
            
            return PieChartResponse(
                reportTitle=f"{self.month_names[month]} {year} Category Distribution",
                totalAmount=round(total_amount, 2),
                chartType=chart_type.value,
                data=chart_data
            ).dict()
            
        except Exception as e:
            return {"error": f"Failed to generate category distribution: {str(e)}"}
    
    async def get_budget_vs_actual(
        self, 
        user_id: str, 
        year: int, 
        month: int
    ) -> Dict[str, Any]:
        """
        B. Bar Chart - Budget vs. Actual
        """
        try:
            # Get user's category budgets
            budget_result = await self.budget_service.get_category_budgets(user_id)
            if budget_result["status"] != "success":
                return {"error": "No budget data found"}
            
            category_budgets = {cb["category_id"]: cb for cb in budget_result["category_budgets"]}
            
            # Calculate date range for the month
            start_date = date(year, month, 1)
            if month == 12:
                end_date = date(year + 1, 1, 1) - timedelta(days=1)
            else:
                end_date = date(year, month + 1, 1) - timedelta(days=1)
            
            # Get actual spending for the month through expenses table
            query = self.supabase.table("expenses").select(
                "expense_items(amount, category_id)"
            ).eq("user_id", user_id).gte("expense_date", start_date.isoformat()).lte("expense_date", end_date.isoformat())
            
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
                labels.append(budget_info["category_name"])
                budget_data.append(budget_info["monthly_limit"])
                actual_data.append(actual_spending.get(category_id, 0.0))
            
            datasets = [
                BarChartDataset(
                    label="Budget",
                    color="#4CAF50",
                    data=budget_data
                ),
                BarChartDataset(
                    label="Actual",
                    color="#F44336",
                    data=actual_data
                )
            ]
            
            return BarChartResponse(
                reportTitle=f"{self.month_names[month]} {year} Budget vs. Actual",
                chartType="bar",
                labels=labels,
                datasets=datasets
            ).dict()
            
        except Exception as e:
            return {"error": f"Failed to generate budget vs actual: {str(e)}"}
    
    async def get_spending_trends(
        self, 
        user_id: str, 
        period: PeriodType
    ) -> Dict[str, Any]:
        """
        C. Line Chart - Spending Trends
        """
        try:
            # Calculate date range based on period
            end_date = date.today()
            
            if period == PeriodType.THIS_MONTH:
                start_date = end_date.replace(day=1)
                title = f"{self.month_names[end_date.month]} {end_date.year} Daily Spending Trends"
            elif period == PeriodType.THREE_MONTHS:
                start_date = end_date - timedelta(days=90)
                title = "Last 3 Months Spending Trends"
            elif period == PeriodType.SIX_MONTHS:
                start_date = end_date - timedelta(days=180)
                title = "Last 6 Months Spending Trends"
            elif period == PeriodType.ONE_YEAR:
                start_date = end_date - timedelta(days=365)
                title = "Last 1 Year Spending Trends"
            else:
                start_date = end_date - timedelta(days=180)
                title = "Last 6 Months Spending Trends"
            
            # Get expense data
            query = self.supabase.table("expenses").select(
                "total_amount, expense_date"
            ).eq("user_id", user_id).gte("expense_date", start_date.isoformat()).lte("expense_date", end_date.isoformat())
            
            result = query.execute()
            
            if not result.data:
                return self._empty_line_chart_response(title, period)
            
            # Process data based on period type
            if period == PeriodType.THIS_MONTH:
                return await self._process_daily_trend(result.data, title, start_date, end_date)
            else:
                return await self._process_monthly_trend(result.data, title, start_date, end_date)
            
        except Exception as e:
            return {"error": f"Failed to generate spending trends: {str(e)}"}
    
    async def get_dashboard_summary(self, user_id: str) -> Dict[str, Any]:
        """
        Dashboard summary data
        """
        try:
            # Get current and previous month data
            today = date.today()
            current_month_start = today.replace(day=1)
            previous_month_end = current_month_start - timedelta(days=1)
            previous_month_start = previous_month_end.replace(day=1)
            
            # Parallel queries for efficiency
            current_month_query = self.supabase.table("expenses").select(
                "total_amount, expense_date"
            ).eq("user_id", user_id).gte("expense_date", current_month_start.isoformat()).lte("expense_date", today.isoformat())
            
            previous_month_query = self.supabase.table("expenses").select(
                "total_amount"
            ).eq("user_id", user_id).gte("expense_date", previous_month_start.isoformat()).lte("expense_date", previous_month_end.isoformat())
            
            category_query = self.supabase.table("expenses").select(
                "expense_items(amount, categories(name))"
            ).eq("user_id", user_id).gte("expense_date", current_month_start.isoformat())
            
            # Execute queries
            current_result = current_month_query.execute()
            previous_result = previous_month_query.execute()
            category_result = category_query.execute()
            
            # Calculate current month metrics
            current_expenses = current_result.data or []
            current_total = sum(float(exp["total_amount"]) for exp in current_expenses)
            current_count = len(current_expenses)
            current_average = current_total / current_count if current_count > 0 else 0
            
            # Calculate previous month total
            previous_expenses = previous_result.data or []
            previous_total = sum(float(exp["total_amount"]) for exp in previous_expenses)
            
            # Calculate month-over-month change
            mom_change = ((current_total - previous_total) / previous_total * 100) if previous_total > 0 else 0
            
            # Calculate top category
            category_totals = defaultdict(float)
            for expense in category_result.data or []:
                expense_items = expense.get("expense_items", [])
                for item in expense_items:
                    category_name = "Other"
                    if item.get("categories"):
                        category_name = item["categories"].get("name", "Other")
                    category_totals[category_name] += float(item.get("amount", 0))
            
            top_category = max(category_totals.items(), key=lambda x: x[1]) if category_totals else ("No Data", 0)
            
            # Create summary
            summary = DashboardSummary(
                current_month_spending=round(current_total, 2),
                previous_month_spending=round(previous_total, 2),
                month_over_month_change=round(mom_change, 2),
                top_category=top_category[0],
                top_category_amount=round(top_category[1], 2),
                transaction_count=current_count,
                average_transaction=round(current_average, 2)
            )
            
            # Generate quick charts data
            quick_charts = await self._generate_quick_charts(user_id, current_month_start, today)
            
            # Get recent transactions
            recent_transactions = await self._get_recent_transactions(user_id, limit=5)
            
            return DashboardResponse(
                summary=summary,
                quick_charts=quick_charts,
                recent_transactions=recent_transactions,
                generated_at=datetime.now()
            ).dict()
            
        except Exception as e:
            return {"error": f"Failed to generate dashboard: {str(e)}"}
    
    # Helper methods
    async def _process_daily_trend(self, expense_data: List[Dict], title: str, start_date: date, end_date: date) -> Dict[str, Any]:
        """Process daily trend data for current month"""
        daily_totals = defaultdict(float)
        
        for expense in expense_data:
            expense_date = datetime.fromisoformat(expense["expense_date"]).date()
            amount = float(expense["total_amount"])
            daily_totals[expense_date] += amount
        
        # Create data points for each day in the month
        data_points = []
        x_axis_labels = {}
        current_date = start_date
        x_index = 0
        
        while current_date <= end_date:
            amount = daily_totals.get(current_date, 0.0)
            data_points.append(LineChartDataPoint(x=x_index, y=round(amount, 2)))
            x_axis_labels[str(x_index)] = str(current_date.day)
            current_date += timedelta(days=1)
            x_index += 1
        
        dataset = LineChartDataset(
            label="Daily Spending",
            color="#03A9F4",
            data=data_points
        )
        
        return LineChartResponse(
            reportTitle=title,
            chartType="line",
            xAxisLabels=x_axis_labels,
            datasets=[dataset]
        ).dict()
    
    async def _process_monthly_trend(self, expense_data: List[Dict], title: str, start_date: date, end_date: date) -> Dict[str, Any]:
        """Process monthly trend data for longer periods"""
        monthly_totals = defaultdict(float)
        
        for expense in expense_data:
            expense_date = datetime.fromisoformat(expense["expense_date"]).date()
            month_key = (expense_date.year, expense_date.month)
            amount = float(expense["total_amount"])
            monthly_totals[month_key] += amount
        
        # Create data points for each month
        data_points = []
        x_axis_labels = {}
        x_index = 0
        
        # Generate month range
        current_date = start_date.replace(day=1)
        while current_date <= end_date:
            month_key = (current_date.year, current_date.month)
            amount = monthly_totals.get(month_key, 0.0)
            data_points.append(LineChartDataPoint(x=x_index, y=round(amount, 2)))
            x_axis_labels[str(x_index)] = self.month_names[current_date.month]
            
            # Move to next month
            if current_date.month == 12:
                current_date = current_date.replace(year=current_date.year + 1, month=1)
            else:
                current_date = current_date.replace(month=current_date.month + 1)
            x_index += 1
        
        dataset = LineChartDataset(
            label="Monthly Spending",
            color="#03A9F4",
            data=data_points
        )
        
        return LineChartResponse(
            reportTitle=title,
            chartType="line",
            xAxisLabels=x_axis_labels,
            datasets=[dataset]
        ).dict()
    
    async def _generate_quick_charts(self, user_id: str, start_date: date, end_date: date) -> Dict[str, Any]:
        """Generate quick chart data for dashboard"""
        try:
            # Get category distribution for current month
            distribution = await self.get_monthly_category_distribution(
                user_id, start_date.year, start_date.month, ChartType.PIE
            )
            
            return {
                "category_distribution": distribution.get("data", [])
            }
        except Exception:
            return {"category_distribution": []}
    
    async def _get_recent_transactions(self, user_id: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Get recent transactions for dashboard"""
        try:
            query = self.supabase.table("expenses").select(
                "total_amount, expense_date, receipts(merchant_name)"
            ).eq("user_id", user_id).order("expense_date", desc=True).limit(limit)
            
            result = query.execute()
            
            transactions = []
            for expense in result.data or []:
                transactions.append({
                    "amount": float(expense["total_amount"]),
                    "date": expense["expense_date"],
                    "merchant": expense.get("receipts", {}).get("merchant_name", "Bilinmeyen") if expense.get("receipts") else "Manuel Giriş",
                    "formatted_amount": f"₺{float(expense['total_amount']):.2f}"
                })
            
            return transactions
        except Exception:
            return []
    
    def _empty_pie_chart_response(self, year: int, month: int, chart_type: ChartType) -> Dict[str, Any]:
        """Return empty pie chart response"""
        return PieChartResponse(
            reportTitle=f"{self.month_names[month]} {year} Category Distribution",
            totalAmount=0.0,
            chartType=chart_type.value,
            data=[]
        ).dict()
    
    def _empty_line_chart_response(self, title: str, period: PeriodType) -> Dict[str, Any]:
        """Return empty line chart response"""
        return LineChartResponse(
            reportTitle=title,
            chartType="line",
            xAxisLabels={},
            datasets=[]
        ).dict() 