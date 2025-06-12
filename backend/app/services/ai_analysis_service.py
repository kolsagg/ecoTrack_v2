"""
AI Analysis Engine Service
Ollama qwen2.5:3b kullanarak harcama analizi, tasarruf önerileri ve bütçe planlaması
"""

import logging
import json
import asyncio
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timedelta
from decimal import Decimal

try:
    import ollama
    OLLAMA_AVAILABLE = True
except ImportError:
    ollama = None
    OLLAMA_AVAILABLE = False

from app.db.supabase_client import get_supabase_client

logger = logging.getLogger(__name__)


class AIAnalysisService:
    """AI-powered spending analysis and financial insights service"""
    
    def __init__(self):
        self.model_name = "qwen2.5:3b"
        self.client = ollama.Client() if OLLAMA_AVAILABLE else None
        self._model_available = False
        self._check_model_availability()
    
    def _check_model_availability(self):
        """Check if qwen2.5:3b model is available"""
        if not OLLAMA_AVAILABLE or not self.client:
            self._model_available = False
            logger.warning("Ollama not available - AI analysis disabled")
            return
            
        try:
            models_response = self.client.list()
            if hasattr(models_response, 'models'):
                available_models = [model.model for model in models_response.models]
            elif isinstance(models_response, dict) and 'models' in models_response:
                available_models = [model['name'] for model in models_response['models']]
            else:
                available_models = [str(model) for model in models_response]
            
            self._model_available = self.model_name in available_models
            
            if not self._model_available:
                logger.warning(f"Model {self.model_name} not found")
                try:
                    self.client.pull(self.model_name)
                    self._model_available = True
                    logger.info("Successfully pulled qwen2.5:3b model")
                except Exception as e:
                    logger.error(f"Failed to pull model: {str(e)}")
            else:
                logger.info(f"Model {self.model_name} is available")
                
        except Exception as e:
            logger.error(f"Failed to check model availability: {str(e)}")
            self._model_available = False

    async def analyze_spending_patterns(self, user_id: str, days: int = 30) -> Dict[str, Any]:
        """
        Analyze user's spending patterns over specified period
        
        Args:
            user_id: User ID
            days: Number of days to analyze (default: 30)
            
        Returns:
            Dictionary containing spending pattern analysis
        """
        try:
            logger.info(f"Analyzing spending patterns for user {user_id} over {days} days")
            
            # Get user's expense data
            expense_data = await self._get_user_expenses(user_id, days)
            
            if not expense_data:
                return {
                    'status': 'no_data',
                    'analysis_period': f'{days} days',
                    'total_expenses': 0,
                    'total_amount': 0.0,
                    'patterns': [],
                    'ai_insights': None,
                    'generated_at': datetime.now()
                }
            
            # Analyze patterns
            patterns = await self._analyze_patterns(expense_data)
            
            # Generate AI insights if available
            ai_insights = None
            if self._model_available:
                ai_insights = await self._generate_ai_insights(expense_data, patterns)
            
            return {
                'status': 'success',
                'analysis_period': f'{days} days',
                'total_expenses': len(expense_data),
                'total_amount': sum(float(exp.get('total_amount', 0)) for exp in expense_data),
                'patterns': patterns,
                'ai_insights': ai_insights,
                'generated_at': datetime.now()
            }
            
        except Exception as e:
            logger.error(f"Spending pattern analysis failed: {str(e)}")
            return {
                'status': 'error',
                'message': f'Analysis failed: {str(e)}',
                'analysis_period': f'{days} days',
                'total_expenses': 0,
                'total_amount': 0.0,
                'patterns': [],
                'ai_insights': None,
                'generated_at': datetime.now()
            }

    async def generate_savings_suggestions(self, user_id: str) -> Dict[str, Any]:
        """
        Generate personalized savings suggestions based on spending analysis
        
        Args:
            user_id: User ID
            
        Returns:
            Dictionary containing savings suggestions
        """
        try:
            logger.info(f"Generating savings suggestions for user {user_id}")
            
            # Get recent spending data (last 60 days for better analysis)
            expense_data = await self._get_user_expenses(user_id, 60)
            
            if not expense_data:
                return {
                    'status': 'no_data',
                    'analysis_period': '60 days',
                    'total_analyzed_amount': 0.0,
                    'potential_monthly_savings': 0.0,
                    'suggestions': [],
                    'generated_at': datetime.now()
                }
            
            # Analyze spending for savings opportunities
            savings_analysis = await self._analyze_savings_opportunities(expense_data)
            
            # Generate AI-powered suggestions
            ai_suggestions = None
            if self._model_available:
                ai_suggestions = await self._generate_ai_savings_suggestions(expense_data, savings_analysis)
            
            # Combine rule-based and AI suggestions
            suggestions = self._combine_savings_suggestions(savings_analysis, ai_suggestions)
            
            return {
                'status': 'success',
                'analysis_period': '60 days',
                'total_analyzed_amount': sum(float(exp.get('total_amount', 0)) for exp in expense_data),
                'potential_monthly_savings': self._calculate_potential_savings(suggestions),
                'suggestions': suggestions,
                'generated_at': datetime.now()
            }
            
        except Exception as e:
            logger.error(f"Savings suggestions generation failed: {str(e)}")
            return {
                'status': 'error',
                'message': f'Suggestion generation failed: {str(e)}',
                'analysis_period': '60 days',
                'total_analyzed_amount': 0.0,
                'potential_monthly_savings': 0.0,
                'suggestions': [],
                'generated_at': datetime.now()
            }

    async def generate_budget_suggestions(self, user_id: str) -> Dict[str, Any]:
        """
        Generate budget planning suggestions based on spending history
        
        Args:
            user_id: User ID
            
        Returns:
            Dictionary containing budget suggestions
        """
        try:
            logger.info(f"Generating budget suggestions for user {user_id}")
            
            # Get spending data for last 90 days for better budget analysis
            expense_data = await self._get_user_expenses(user_id, 90)
            
            if not expense_data:
                return {
                    'status': 'no_data',
                    'analysis_period': '90 days',
                    'category_analysis': {},
                    'budget_recommendations': {},
                    'ai_insights': None,
                    'generated_at': datetime.now()
                }
            
            # Analyze spending by category
            category_analysis = await self._analyze_spending_by_category(expense_data)
            
            # Generate budget recommendations
            budget_recommendations = await self._generate_budget_recommendations(category_analysis)
            
            # Generate AI-powered budget insights
            ai_budget_insights = None
            if self._model_available:
                ai_budget_insights = await self._generate_ai_budget_insights(expense_data, category_analysis)
            
            return {
                'status': 'success',
                'analysis_period': '90 days',
                'category_analysis': category_analysis,
                'budget_recommendations': budget_recommendations,
                'ai_insights': ai_budget_insights,
                'generated_at': datetime.now()
            }
            
        except Exception as e:
            logger.error(f"Budget suggestions generation failed: {str(e)}")
            return {
                'status': 'error',
                'message': f'Budget suggestion generation failed: {str(e)}',
                'analysis_period': '90 days',
                'category_analysis': {},
                'budget_recommendations': {},
                'ai_insights': None,
                'generated_at': datetime.now()
            }

    async def get_analytics_summary(self, user_id: str) -> Dict[str, Any]:
        """
        Get comprehensive spending analytics summary for charts and visualizations
        
        Args:
            user_id: User ID
            
        Returns:
            Dictionary containing analytics data suitable for charts
        """
        try:
            logger.info(f"Generating analytics summary for user {user_id}")
            
            # Get data for different time periods
            last_30_days = await self._get_user_expenses(user_id, 30)
            last_7_days = await self._get_user_expenses(user_id, 7)
            
            # Generate summary statistics
            summary = {
                'status': 'success',
                'overview': {
                    'last_7_days': {
                        'total_amount': sum(float(exp.get('total_amount', 0)) for exp in last_7_days),
                        'transaction_count': len(last_7_days),
                        'avg_transaction': sum(float(exp.get('total_amount', 0)) for exp in last_7_days) / len(last_7_days) if last_7_days else 0
                    },
                    'last_30_days': {
                        'total_amount': sum(float(exp.get('total_amount', 0)) for exp in last_30_days),
                        'transaction_count': len(last_30_days),
                        'avg_transaction': sum(float(exp.get('total_amount', 0)) for exp in last_30_days) / len(last_30_days) if last_30_days else 0
                    }
                },
                'category_breakdown': await self._get_category_breakdown(last_30_days),
                'daily_spending': await self._get_daily_spending_trend(last_30_days),
                'top_merchants': await self._get_top_merchants(last_30_days),
                'generated_at': datetime.now()
            }
            
            return summary
            
        except Exception as e:
            logger.error(f"Analytics summary generation failed: {str(e)}")
            return {
                'status': 'error',
                'message': f'Analytics generation failed: {str(e)}',
                'overview': {},
                'category_breakdown': [],
                'daily_spending': [],
                'top_merchants': [],
                'generated_at': datetime.now()
            }

    async def _get_user_expenses(self, user_id: str, days: int) -> List[Dict[str, Any]]:
        """Get user's expenses for the specified number of days"""
        try:
            supabase = get_supabase_client()
            
            # Calculate date range
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            # Query expenses with related data
            response = supabase.table('expenses').select(
                '*, expense_items(*, categories(name)), receipts(merchant_name, transaction_date)'
            ).eq('user_id', user_id).gte(
                'expense_date', start_date.isoformat()
            ).lte(
                'expense_date', end_date.isoformat()
            ).order('expense_date', desc=True).execute()
            
            return response.data if response.data else []
            
        except Exception as e:
            logger.error(f"Failed to get user expenses: {str(e)}")
            return []

    async def _analyze_patterns(self, expense_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Analyze spending patterns from expense data"""
        patterns = []
        
        try:
            # Daily spending pattern
            daily_amounts = {}
            for expense in expense_data:
                date = expense.get('expense_date', '').split('T')[0]
                amount = float(expense.get('total_amount', 0))
                daily_amounts[date] = daily_amounts.get(date, 0) + amount
            
            if daily_amounts:
                avg_daily = sum(daily_amounts.values()) / len(daily_amounts)
                max_daily = max(daily_amounts.values())
                min_daily = min(daily_amounts.values())
                
                patterns.append({
                    'type': 'daily_spending',
                    'description': 'Daily spending pattern analysis',
                    'metrics': {
                        'average_daily': round(avg_daily, 2),
                        'highest_daily': round(max_daily, 2),
                        'lowest_daily': round(min_daily, 2),
                        'variance': round(max_daily - min_daily, 2)
                    }
                })
            
            # Category concentration
            category_amounts = {}
            for expense in expense_data:
                items = expense.get('expense_items', [])
                for item in items:
                    category = item.get('categories', {}).get('name', 'Other') if item.get('categories') else 'Other'
                    amount = float(item.get('amount', 0))
                    category_amounts[category] = category_amounts.get(category, 0) + amount
            
            if category_amounts:
                total_amount = sum(category_amounts.values())
                top_category = max(category_amounts.items(), key=lambda x: x[1])
                concentration = (top_category[1] / total_amount) * 100 if total_amount > 0 else 0
                
                patterns.append({
                    'type': 'category_concentration',
                    'description': 'Spending concentration by category',
                    'metrics': {
                        'average_daily': round(total_amount / 30, 2),  # Approximate daily average
                        'highest_daily': round(top_category[1], 2),
                        'lowest_daily': 0.0,
                        'variance': round(concentration, 1)
                    }
                })
            
            return patterns
            
        except Exception as e:
            logger.error(f"Pattern analysis failed: {str(e)}")
            return []

    async def _generate_ai_insights(self, expense_data: List[Dict[str, Any]], patterns: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """Generate AI insights from expense data and patterns using Qwen2.5:3B"""
        if not self._model_available:
            return None
            
        try:
            # Prepare data summary for AI
            total_amount = sum(float(exp.get('total_amount', 0)) for exp in expense_data)
            transaction_count = len(expense_data)
            
            # Create optimized prompt for Qwen2.5:3B
            prompt = f"""You are a financial analysis expert. Analyze the following spending data:

SPENDING SUMMARY:
- Total Amount: {total_amount:.2f} TRY
- Transaction Count: {transaction_count}
- Analysis Period: Last 30 days

IDENTIFIED PATTERNS:
{json.dumps(patterns, indent=2, ensure_ascii=False)}

PLEASE PROVIDE:
1. Key spending insights
2. Notable patterns or trends
3. Areas of concern or opportunities

Keep your response concise and actionable."""
            
            response = self.client.chat(
                model=self.model_name,
                messages=[
                    {
                        'role': 'system',
                        'content': 'You are a financial analysis expert. You provide concise and clear analyses.'
                    },
                    {
                        'role': 'user',
                        'content': prompt
                    }
                ],
                options={
                    'temperature': 0.3,
                    'top_p': 0.8,
                    'num_predict': 300
                }
            )
            
            return {
                'ai_analysis': response['message']['content'] if 'message' in response else str(response),
                'confidence': 0.8,
                'generated_by': 'qwen2.5:3b'
            }
            
        except Exception as e:
            logger.error(f"AI insights generation failed: {str(e)}")
            return None

    async def _analyze_savings_opportunities(self, expense_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze spending data for savings opportunities"""
        opportunities = {}
        
        try:
            # Analyze by category for potential savings
            category_spending = {}
            for expense in expense_data:
                items = expense.get('expense_items', [])
                for item in items:
                    category = item.get('categories', {}).get('name', 'Other') if item.get('categories') else 'Other'
                    amount = float(item.get('amount', 0))
                    category_spending[category] = category_spending.get(category, 0) + amount
            
            # Identify high-spending categories
            total_spending = sum(category_spending.values())
            for category, amount in category_spending.items():
                percentage = (amount / total_spending) * 100 if total_spending > 0 else 0
                
                if percentage > 25:  # Categories taking more than 25% of budget
                    opportunities[category] = {
                        'amount': round(amount, 2),
                        'percentage': round(percentage, 1),
                        'potential_savings': round(amount * 0.1, 2),  # Suggest 10% reduction
                        'priority': 'high' if percentage > 40 else 'medium'
                    }
            
            return opportunities
            
        except Exception as e:
            logger.error(f"Savings opportunity analysis failed: {str(e)}")
            return {}

    async def _generate_ai_savings_suggestions(self, expense_data: List[Dict[str, Any]], savings_analysis: Dict[str, Any]) -> Optional[List[Dict[str, Any]]]:
        """Generate AI-powered savings suggestions"""
        if not self._model_available:
            return None
            
        try:
            prompt = f"""
            Based on this spending analysis, suggest 3 practical money-saving tips:
            
            Spending Analysis:
            {json.dumps(savings_analysis, indent=2)}
            
            Provide specific, actionable suggestions for saving money.
            Format as numbered list.
            """
            
            response = self.client.generate(
                model=self.model_name,
                prompt=prompt,
                options={'temperature': 0.8, 'max_tokens': 200}
            )
            
            ai_text = response.response if hasattr(response, 'response') else str(response)
            
            # Parse AI response into structured suggestions
            suggestions = []
            lines = ai_text.split('\n')
            for line in lines:
                line = line.strip()
                if line and (line[0].isdigit() or line.startswith('-')):
                    suggestions.append({
                        'suggestion': line,
                        'type': 'ai_generated',
                        'confidence': 0.7
                    })
            
            return suggestions[:3]  # Return top 3 suggestions
            
        except Exception as e:
            logger.error(f"AI savings suggestions failed: {str(e)}")
            return None

    def _combine_savings_suggestions(self, rule_based: Dict[str, Any], ai_suggestions: Optional[List[Dict[str, Any]]]) -> List[Dict[str, Any]]:
        """Combine rule-based and AI savings suggestions"""
        combined = []
        
        # Add rule-based suggestions
        for category, data in rule_based.items():
            combined.append({
                'type': 'category_optimization',
                'category': category,
                'current_spending': data['amount'],
                'potential_savings': data['potential_savings'],
                'suggestion': f"Consider reducing {category} spending by 10% to save {data['potential_savings']:.2f} TRY monthly",
                'priority': data['priority'],
                'confidence': 0.9
            })
        
        # Add AI suggestions
        if ai_suggestions:
            combined.extend(ai_suggestions)
        
        return combined

    def _calculate_potential_savings(self, suggestions: List[Dict[str, Any]]) -> float:
        """Calculate total potential monthly savings"""
        total = 0
        for suggestion in suggestions:
            if 'potential_savings' in suggestion:
                total += float(suggestion['potential_savings'])
        return round(total, 2)

    async def _analyze_spending_by_category(self, expense_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze spending breakdown by category"""
        category_data = {}
        
        try:
            for expense in expense_data:
                items = expense.get('expense_items', [])
                for item in items:
                    category = item.get('categories', {}).get('name', 'Other') if item.get('categories') else 'Other'
                    amount = float(item.get('amount', 0))
                    
                    if category not in category_data:
                        category_data[category] = {
                            'total_amount': 0,
                            'transaction_count': 0,
                            'avg_transaction': 0
                        }
                    
                    category_data[category]['total_amount'] += amount
                    category_data[category]['transaction_count'] += 1
            
            # Calculate averages
            for category in category_data:
                data = category_data[category]
                data['avg_transaction'] = data['total_amount'] / data['transaction_count'] if data['transaction_count'] > 0 else 0
                data['total_amount'] = round(data['total_amount'], 2)
                data['avg_transaction'] = round(data['avg_transaction'], 2)
            
            return category_data
            
        except Exception as e:
            logger.error(f"Category analysis failed: {str(e)}")
            return {}

    async def _generate_budget_recommendations(self, category_analysis: Dict[str, Any]) -> Dict[str, Any]:
        """Generate budget recommendations based on category analysis"""
        recommendations = {}
        
        try:
            total_spending = sum(data['total_amount'] for data in category_analysis.values())
            
            for category, data in category_analysis.items():
                percentage = (data['total_amount'] / total_spending) * 100 if total_spending > 0 else 0
                
                # Suggest budget based on current spending + 10% buffer
                suggested_budget = data['total_amount'] * 1.1
                
                recommendations[category] = {
                    'current_spending': data['total_amount'],
                    'suggested_monthly_budget': round(suggested_budget, 2),
                    'current_percentage': round(percentage, 1),
                    'recommendation': self._get_budget_recommendation(category, percentage)
                }
            
            return recommendations
            
        except Exception as e:
            logger.error(f"Budget recommendations failed: {str(e)}")
            return {}

    def _get_budget_recommendation(self, category: str, percentage: float) -> str:
        """Get budget recommendation text for category"""
        if percentage > 40:
            return f"High spending in {category}. Consider setting a stricter budget limit."
        elif percentage > 25:
            return f"Moderate spending in {category}. Monitor closely and set reasonable limits."
        elif percentage < 5:
            return f"Low spending in {category}. Current level seems appropriate."
        else:
            return f"Balanced spending in {category}. Maintain current budget level."

    async def _generate_ai_budget_insights(self, expense_data: List[Dict[str, Any]], category_analysis: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Generate AI-powered budget insights using Qwen2.5:3B"""
        if not self._model_available:
            return None
            
        try:
            prompt = f"""You are a budget advisor. Evaluate the following category-based spending analysis:

CATEGORY BREAKDOWN:
{json.dumps(category_analysis, indent=2, ensure_ascii=False)}

PLEASE PROVIDE:
1. Overall budget health assessment
2. Key recommendations for budget optimization
3. Warning signs or positive trends

Keep your response practical and actionable."""
            
            response = self.client.chat(
                model=self.model_name,
                messages=[
                    {
                        'role': 'system',
                        'content': 'You are a budget advisor. You provide practical and actionable recommendations.'
                    },
                    {
                        'role': 'user',
                        'content': prompt
                    }
                ],
                options={
                    'temperature': 0.3,
                    'top_p': 0.8,
                    'num_predict': 250
                }
            )
            
            return {
                'ai_analysis': response['message']['content'] if 'message' in response else str(response),
                'confidence': 0.8,
                'generated_by': 'qwen2.5:3b'
            }
            
        except Exception as e:
            logger.error(f"AI budget insights failed: {str(e)}")
            return None

    async def _get_category_breakdown(self, expense_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Get category breakdown for charts"""
        category_totals = {}
        
        for expense in expense_data:
            items = expense.get('expense_items', [])
            for item in items:
                category = item.get('categories', {}).get('name', 'Other') if item.get('categories') else 'Other'
                amount = float(item.get('amount', 0))
                category_totals[category] = category_totals.get(category, 0) + amount
        
        # Convert to chart-friendly format
        breakdown = []
        total = sum(category_totals.values())
        
        for category, amount in sorted(category_totals.items(), key=lambda x: x[1], reverse=True):
            percentage = (amount / total) * 100 if total > 0 else 0
            breakdown.append({
                'category': category,
                'amount': round(amount, 2),
                'percentage': round(percentage, 1)
            })
        
        return breakdown

    async def _get_daily_spending_trend(self, expense_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Get daily spending trend for charts"""
        daily_totals = {}
        
        for expense in expense_data:
            date = expense.get('expense_date', '').split('T')[0]
            amount = float(expense.get('total_amount', 0))
            daily_totals[date] = daily_totals.get(date, 0) + amount
        
        # Convert to chart-friendly format
        trend = []
        for date in sorted(daily_totals.keys()):
            trend.append({
                'date': date,
                'amount': round(daily_totals[date], 2)
            })
        
        return trend

    async def _get_top_merchants(self, expense_data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Get top merchants by spending"""
        merchant_totals = {}
        
        for expense in expense_data:
            merchant = expense.get('receipts', {}).get('merchant_name', 'Unknown') if expense.get('receipts') else 'Unknown'
            amount = float(expense.get('total_amount', 0))
            merchant_totals[merchant] = merchant_totals.get(merchant, 0) + amount
        
        # Convert to chart-friendly format and get top 10
        top_merchants = []
        for merchant, amount in sorted(merchant_totals.items(), key=lambda x: x[1], reverse=True)[:10]:
            top_merchants.append({
                'merchant': merchant,
                'total_amount': round(amount, 2)
            })
        
        return top_merchants 