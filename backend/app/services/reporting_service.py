"""
Financial Reporting Service
Processes AI analysis data and prepares chart-ready data for frontend visualization
"""

import asyncio
from datetime import datetime, date, timedelta
from typing import List, Dict, Any, Optional, Tuple
from collections import defaultdict
import calendar

from app.db.supabase_client import get_supabase_client
from app.schemas.reporting import (
    ReportingFilters, SpendingDistributionItem, TrendDataPoint, 
    TrendDataset, CategorySpendingDataPoint, BudgetVsActualItem,
    AggregationPeriod, ChartType, DashboardSummary
)
from app.services.ai_analysis_service import AIAnalysisService


class ReportingService:
    """Service for generating financial reports and visualization data"""
    
    def __init__(self):
        self.supabase = get_supabase_client()
        self.ai_service = AIAnalysisService()
        
        # Chart color palettes
        self.category_colors = [
            "#FF6384", "#36A2EB", "#FFCE56", "#4BC0C0", "#9966FF",
            "#FF9F40", "#FF6384", "#C9CBCF", "#4BC0C0", "#FF6384"
        ]
        
        self.status_colors = {
            "under": "#4CAF50",  # Green
            "over": "#F44336",   # Red
            "on_track": "#FF9800"  # Orange
        }
    
    async def get_spending_distribution(
        self,
        user_id: str,
        distribution_type: str,
        filters: Optional[ReportingFilters] = None,
        chart_type: ChartType = ChartType.PIE,
        limit: int = 10
    ) -> Dict[str, Any]:
        """
        Generate spending distribution data for charts
        
        Args:
            user_id: User ID
            distribution_type: 'category' or 'merchant'
            filters: Optional filtering parameters
            chart_type: Preferred chart type
            limit: Maximum number of items to return
        """
        try:
            # Build query based on distribution type
            if distribution_type == "category":
                query = self.supabase.table("expense_items").select(
                    "amount, categories(name), expenses(expense_date)"
                ).eq("user_id", user_id)
            else:  # merchant
                query = self.supabase.table("expenses").select(
                    "total_amount, expense_date, receipts(merchant_name)"
                ).eq("user_id", user_id)
            
            # Apply filters
            if filters:
                if filters.start_date:
                    query = query.gte("expense_date" if distribution_type == "merchant" else "expenses.expense_date", 
                                    filters.start_date.isoformat())
                if filters.end_date:
                    query = query.lte("expense_date" if distribution_type == "merchant" else "expenses.expense_date", 
                                    filters.end_date.isoformat())
                if filters.min_amount:
                    amount_field = "total_amount" if distribution_type == "merchant" else "amount"
                    query = query.gte(amount_field, filters.min_amount)
                if filters.max_amount:
                    amount_field = "total_amount" if distribution_type == "merchant" else "amount"
                    query = query.lte(amount_field, filters.max_amount)
            
            result = query.execute()
            
            if not result.data:
                return self._empty_distribution_response(distribution_type, chart_type, filters)
            
            # Process data
            distribution_data = defaultdict(lambda: {"amount": 0.0, "count": 0})
            total_amount = 0.0
            total_transactions = 0
            
            for item in result.data:
                if distribution_type == "category":
                    label = item.get("categories", {}).get("name", "Uncategorized") if item.get("categories") else "Uncategorized"
                    amount = float(item.get("amount", 0))
                else:  # merchant
                    label = item.get("receipts", {}).get("merchant_name", "Unknown Merchant") if item.get("receipts") else "Unknown Merchant"
                    amount = float(item.get("total_amount", 0))
                
                distribution_data[label]["amount"] += amount
                distribution_data[label]["count"] += 1
                total_amount += amount
                total_transactions += 1
            
            # Convert to list and sort by amount
            distribution_list = []
            for i, (label, data) in enumerate(sorted(distribution_data.items(), 
                                                   key=lambda x: x[1]["amount"], reverse=True)[:limit]):
                percentage = (data["amount"] / total_amount * 100) if total_amount > 0 else 0
                distribution_list.append(SpendingDistributionItem(
                    label=label,
                    value=data["amount"],
                    percentage=round(percentage, 2),
                    color=self.category_colors[i % len(self.category_colors)],
                    count=data["count"]
                ))
            
            # Generate chart configuration
            chart_config = self._generate_distribution_chart_config(chart_type, distribution_list)
            
            return {
                "status": "success",
                "distribution_type": distribution_type,
                "total_amount": round(total_amount, 2),
                "total_transactions": total_transactions,
                "distribution_data": distribution_list,
                "chart_config": chart_config,
                "filters_applied": filters,
                "generated_at": datetime.now()
            }
            
        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "distribution_type": distribution_type,
                "distribution_data": [],
                "generated_at": datetime.now()
            }
    
    async def get_budget_vs_actual(
        self,
        user_id: str,
        period_start: date,
        period_end: date,
        category_ids: Optional[List[str]] = None,
        chart_type: ChartType = ChartType.BAR
    ) -> Dict[str, Any]:
        """
        Generate budget vs actual spending comparison
        Note: This uses AI-generated budget suggestions as budget data
        """
        try:
            # Get AI budget suggestions
            budget_suggestions = await self.ai_service.get_budget_suggestions(user_id)
            
            if budget_suggestions["status"] != "success":
                return {
                    "status": "error",
                    "error": "Could not retrieve budget suggestions",
                    "comparison_data": [],
                    "generated_at": datetime.now()
                }
            
            # Get actual spending by category
            query = self.supabase.table("expense_items").select(
                "amount, category_id, categories(name)"
            ).eq("user_id", user_id).gte("created_at", period_start.isoformat()).lte("created_at", period_end.isoformat())
            
            if category_ids:
                query = query.in_("category_id", category_ids)
            
            result = query.execute()
            
            # Calculate actual spending by category
            actual_spending = defaultdict(float)
            for item in result.data:
                category_name = item.get("categories", {}).get("name", "Uncategorized") if item.get("categories") else "Uncategorized"
                actual_spending[category_name] += float(item.get("amount", 0))
            
            # Create budget vs actual comparison
            comparison_data = []
            
            for suggestion in budget_suggestions["suggestions"]:
                category = suggestion["category"]
                budgeted = suggestion["suggested_amount"]
                actual = actual_spending.get(category, 0.0)
                variance = actual - budgeted
                variance_percentage = (variance / budgeted * 100) if budgeted > 0 else 0
                
                # Determine status
                if variance <= -budgeted * 0.1:  # 10% under budget
                    status = "under"
                elif variance >= budgeted * 0.1:  # 10% over budget
                    status = "over"
                else:
                    status = "on_track"
                
                comparison_data.append(BudgetVsActualItem(
                    category=category,
                    budgeted=budgeted,
                    actual=actual,
                    variance=variance,
                    variance_percentage=round(variance_percentage, 2),
                    status=status,
                    color=self.status_colors[status]
                ))
            
            # Generate summary
            total_budgeted = sum(item.budgeted for item in comparison_data)
            total_actual = sum(item.actual for item in comparison_data)
            total_variance = total_actual - total_budgeted
            
            summary = {
                "total_budgeted": round(total_budgeted, 2),
                "total_actual": round(total_actual, 2),
                "total_variance": round(total_variance, 2),
                "variance_percentage": round((total_variance / total_budgeted * 100) if total_budgeted > 0 else 0, 2),
                "categories_over_budget": len([item for item in comparison_data if item.status == "over"]),
                "categories_under_budget": len([item for item in comparison_data if item.status == "under"])
            }
            
            # Generate chart configuration
            chart_config = self._generate_budget_chart_config(chart_type, comparison_data)
            
            return {
                "status": "success",
                "period_start": period_start,
                "period_end": period_end,
                "comparison_data": comparison_data,
                "summary": summary,
                "chart_config": chart_config,
                "generated_at": datetime.now()
            }
            
        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "comparison_data": [],
                "generated_at": datetime.now()
            }

    async def get_dashboard_summary(self, user_id: str) -> Dict[str, Any]:
        """
        Generate dashboard summary with key metrics and quick charts
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
            
            category_query = self.supabase.table("expense_items").select(
                "amount, categories(name)"
            ).eq("user_id", user_id).gte("created_at", current_month_start.isoformat())
            
            # Execute queries in parallel
            current_result, previous_result, category_result = await asyncio.gather(
                current_month_query.execute(),
                previous_month_query.execute(),
                category_query.execute()
            )
            
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
            for item in category_result.data or []:
                category_name = item.get("categories", {}).get("name", "Uncategorized") if item.get("categories") else "Uncategorized"
                category_totals[category_name] += float(item.get("amount", 0))
            
            top_category = max(category_totals.items(), key=lambda x: x[1]) if category_totals else ("No Data", 0)
            
            # Create summary
            summary = DashboardSummary(
                total_spending_current_month=round(current_total, 2),
                total_spending_previous_month=round(previous_total, 2),
                month_over_month_change=round(mom_change, 2),
                top_category=top_category[0],
                top_category_amount=round(top_category[1], 2),
                transaction_count=current_count,
                average_transaction=round(current_average, 2),
                budget_utilization=None  # Would need budget data
            )
            
            # Generate quick charts data
            quick_charts = await self._generate_quick_charts(user_id, current_month_start, today)
            
            # Get recent transactions
            recent_transactions = await self._get_recent_transactions(user_id, limit=5)
            
            # Generate alerts
            alerts = await self._generate_financial_alerts(user_id, summary)
            
            return {
                "status": "success",
                "summary": summary,
                "quick_charts": quick_charts,
                "recent_transactions": recent_transactions,
                "alerts": alerts,
                "generated_at": datetime.now()
            }
            
        except Exception as e:
            return {
                "status": "error",
                "error": str(e),
                "generated_at": datetime.now()
            }
    
    # Helper methods
    def _generate_distribution_chart_config(self, chart_type: ChartType, data: List[SpendingDistributionItem]) -> Dict[str, Any]:
        """Generate chart configuration for distribution charts"""
        return {
            "type": chart_type.value,
            "responsive": True,
            "plugins": {
                "legend": {
                    "position": "right" if chart_type == ChartType.PIE else "top"
                },
                "tooltip": {
                    "callbacks": {
                        "label": "function(context) { return context.label + ': $' + context.parsed.toFixed(2) + ' (' + context.dataset.data[context.dataIndex].percentage + '%)'; }"
                    }
                }
            },
            "scales": {} if chart_type in [ChartType.PIE, ChartType.DONUT] else {
                "y": {
                    "beginAtZero": True,
                    "ticks": {
                        "callback": "function(value) { return '$' + value.toFixed(2); }"
                    }
                }
            }
        }
    
    async def _generate_quick_charts(self, user_id: str, start_date: date, end_date: date) -> Dict[str, Any]:
        """Generate quick chart data for dashboard"""
        # Get spending distribution for current month
        distribution = await self.get_spending_distribution(
            user_id, "category", 
            ReportingFilters(start_date=start_date, end_date=end_date),
            limit=5
        )
        
        return {
            "category_distribution": distribution.get("distribution_data", [])
        }
    
    async def _get_recent_transactions(self, user_id: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Get recent transactions for dashboard"""
        query = self.supabase.table("expenses").select(
            "total_amount, expense_date, receipts(merchant_name)"
        ).eq("user_id", user_id).order("expense_date", desc=True).limit(limit)
        
        result = query.execute()
        
        transactions = []
        for expense in result.data or []:
            transactions.append({
                "amount": float(expense["total_amount"]),
                "date": expense["expense_date"],
                "merchant": expense.get("receipts", {}).get("merchant_name", "Unknown") if expense.get("receipts") else "Manual Entry",
                "formatted_amount": f"${float(expense['total_amount']):.2f}"
            })
        
        return transactions
    
    async def _generate_financial_alerts(self, user_id: str, summary: DashboardSummary) -> List[Dict[str, Any]]:
        """Generate financial alerts based on spending patterns"""
        alerts = []
        
        # High spending alert
        if summary.month_over_month_change > 20:
            alerts.append({
                "type": "warning",
                "title": "Spending Increase",
                "message": f"Your spending increased by {summary.month_over_month_change:.1f}% this month",
                "action": "Review your expenses"
            })
        
        # Low spending alert
        elif summary.month_over_month_change < -20:
            alerts.append({
                "type": "success",
                "title": "Great Savings",
                "message": f"You reduced spending by {abs(summary.month_over_month_change):.1f}% this month",
                "action": "Keep up the good work!"
            })
        
        # High transaction frequency
        if summary.transaction_count > 50:
            alerts.append({
                "type": "info",
                "title": "Frequent Transactions",
                "message": f"You made {summary.transaction_count} transactions this month",
                "action": "Consider consolidating purchases"
            })
        
        return alerts
    
    def _generate_budget_chart_config(self, chart_type: ChartType, data: List[BudgetVsActualItem]) -> Dict[str, Any]:
        """Generate chart configuration for budget comparison charts"""
        return {
            "type": chart_type.value,
            "responsive": True,
            "plugins": {
                "legend": {
                    "position": "top"
                }
            },
            "scales": {
                "x": {
                    "title": {
                        "display": True,
                        "text": "Categories"
                    }
                },
                "y": {
                    "beginAtZero": True,
                    "title": {
                        "display": True,
                        "text": "Amount ($)"
                    },
                    "ticks": {
                        "callback": "function(value) { return '$' + value.toFixed(2); }"
                    }
                }
            }
        }
    
    def _empty_distribution_response(self, distribution_type: str, chart_type: ChartType, filters: Optional[ReportingFilters]) -> Dict[str, Any]:
        """Return empty distribution response"""
        return {
            "status": "success",
            "distribution_type": distribution_type,
            "total_amount": 0.0,
            "total_transactions": 0,
            "distribution_data": [],
            "chart_config": self._generate_distribution_chart_config(chart_type, []),
            "filters_applied": filters,
            "generated_at": datetime.now()
        } 