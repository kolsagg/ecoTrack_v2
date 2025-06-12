"""
Advanced Analysis Service
Recurring expenses, price tracking, ve product expiration analysis
"""

import logging
import json
import asyncio
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime, timedelta
from decimal import Decimal
from collections import defaultdict
import re

from app.db.supabase_client import get_supabase_client

logger = logging.getLogger(__name__)


def safe_parse_datetime(date_str: str) -> Optional[datetime]:
    """
    Safely parse datetime string, handling microseconds with more than 6 digits
    
    Args:
        date_str: ISO format datetime string
        
    Returns:
        Parsed datetime object or None if parsing fails
    """
    if not date_str:
        return None
        
    try:
        # Handle timezone
        if date_str.endswith('Z'):
            date_str = date_str.replace('Z', '+00:00')
        
        # Check if there are microseconds
        if '.' in date_str and '+' in date_str:
            # Split into main part and timezone
            main_part, tz_part = date_str.rsplit('+', 1)
            
            # Split main part into datetime and microseconds
            if '.' in main_part:
                dt_part, microsec_part = main_part.split('.')
                
                # Truncate microseconds to 6 digits
                if len(microsec_part) > 6:
                    microsec_part = microsec_part[:6]
                
                # Reconstruct the datetime string
                date_str = f"{dt_part}.{microsec_part}+{tz_part}"
        
        return datetime.fromisoformat(date_str)
        
    except (ValueError, AttributeError) as e:
        logger.warning(f"Failed to parse datetime '{date_str}': {str(e)}")
        return None


class AdvancedAnalysisService:
    """Advanced analysis features for expense tracking"""
    
    def __init__(self):
        self.similarity_threshold = 0.8  # For matching similar expenses
        self.price_change_threshold = 0.05  # 5% price change threshold
    
    async def identify_recurring_expenses(self, user_id: str, days: int = 90) -> List[Dict[str, Any]]:
        """
        Identify recurring expense patterns
        
        Args:
            user_id: User ID
            days: Number of days to analyze (default: 90)
            
        Returns:
            List of recurring expense patterns
        """
        try:
            logger.info(f"Identifying recurring expenses for user {user_id} over {days} days")
            
            # Get user's expense data
            expense_data = await self._get_user_expense_items(user_id, days)
            
            if not expense_data:
                return []
            
            # Group similar expenses
            expense_groups = self._group_similar_expenses(expense_data)
            
            # Analyze patterns for each group
            recurring_patterns = []
            for group_key, expenses in expense_groups.items():
                if len(expenses) >= 3:  # Need at least 3 occurrences to identify pattern
                    pattern = await self._analyze_expense_pattern(group_key, expenses)
                    if pattern:
                        recurring_patterns.append(pattern)
            
            # Sort by confidence and frequency
            recurring_patterns.sort(key=lambda x: (x['confidence'], len(x.get('occurrences', []))), reverse=True)
            
            logger.info(f"Found {len(recurring_patterns)} recurring expense patterns")
            return recurring_patterns
            
        except Exception as e:
            logger.error(f"Recurring expense identification failed: {str(e)}")
            return []

    async def track_price_changes(self, user_id: str, days: int = 180) -> List[Dict[str, Any]]:
        """
        Track price changes for products over time
        
        Args:
            user_id: User ID
            days: Number of days to analyze (default: 180)
            
        Returns:
            List of price change alerts
        """
        try:
            logger.info(f"Tracking price changes for user {user_id} over {days} days")
            
            # Get expense items with product details
            expense_items = await self._get_user_expense_items(user_id, days)
            
            if not expense_items:
                return []
            
            # Group by product and merchant
            product_groups = self._group_by_product_and_merchant(expense_items)
            
            # Analyze price changes for each product
            price_changes = []
            for product_key, items in product_groups.items():
                if len(items) >= 2:  # Need at least 2 purchases to compare
                    changes = await self._analyze_price_changes(product_key, items)
                    price_changes.extend(changes)
            
            # Filter significant price changes
            significant_changes = [
                change for change in price_changes 
                if abs(change['price_change_percentage']) >= self.price_change_threshold * 100
            ]
            
            # Sort by price change percentage (descending)
            significant_changes.sort(key=lambda x: abs(x['price_change_percentage']), reverse=True)
            
            logger.info(f"Found {len(significant_changes)} significant price changes")
            return significant_changes
            
        except Exception as e:
            logger.error(f"Price change tracking failed: {str(e)}")
            return []

    async def track_product_expiration(self, user_id: str) -> List[Dict[str, Any]]:
        """
        Track product expiration dates from receipt data
        
        Args:
            user_id: User ID
            
        Returns:
            List of product expiration alerts
        """
        try:
            logger.info(f"Tracking product expiration for user {user_id}")
            
            # Get recent expense items (last 30 days)
            expense_items = await self._get_user_expense_items(user_id, 30)
            
            if not expense_items:
                return []
            
            # Extract products with potential expiration dates
            expiring_products = []
            for item in expense_items:
                expiration_info = await self._extract_expiration_info(item)
                if expiration_info:
                    expiring_products.append(expiration_info)
            
            # Filter products expiring soon (within 7 days)
            soon_expiring = []
            current_date = datetime.now()
            
            for product in expiring_products:
                expiration_date = product.get('expiration_date')
                if expiration_date:
                    days_until_expiration = (expiration_date - current_date).days
                    if 0 <= days_until_expiration <= 7:
                        product['days_until_expiration'] = days_until_expiration
                        soon_expiring.append(product)
            
            # Sort by days until expiration
            soon_expiring.sort(key=lambda x: x['days_until_expiration'])
            
            logger.info(f"Found {len(soon_expiring)} products expiring soon")
            return soon_expiring
            
        except Exception as e:
            logger.error(f"Product expiration tracking failed: {str(e)}")
            return []

    async def analyze_spending_patterns(self, user_id: str, days: int = 60) -> Dict[str, Any]:
        """
        Analyze daily/weekly spending patterns
        
        Args:
            user_id: User ID
            days: Number of days to analyze (default: 60)
            
        Returns:
            Dictionary containing pattern analysis
        """
        try:
            logger.info(f"Analyzing spending patterns for user {user_id} over {days} days")
            
            # Get expense data
            expense_data = await self._get_user_expenses(user_id, days)
            
            if not expense_data:
                return {
                    'status': 'no_data',
                    'daily_patterns': {},
                    'weekly_patterns': {},
                    'insights': []
                }
            
            # Analyze daily patterns
            daily_patterns = await self._analyze_daily_patterns(expense_data)
            
            # Analyze weekly patterns
            weekly_patterns = await self._analyze_weekly_patterns(expense_data)
            
            # Generate insights
            insights = await self._generate_pattern_insights(daily_patterns, weekly_patterns)
            
            return {
                'status': 'success',
                'analysis_period': f'{days} days',
                'daily_patterns': daily_patterns,
                'weekly_patterns': weekly_patterns,
                'insights': insights,
                'generated_at': datetime.now().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Spending pattern analysis failed: {str(e)}")
            return {
                'status': 'error',
                'message': f'Pattern analysis failed: {str(e)}',
                'daily_patterns': {},
                'weekly_patterns': {}
            }

    async def _get_user_expense_items(self, user_id: str, days: int) -> List[Dict[str, Any]]:
        """Get user's expense items for the specified number of days"""
        try:
            supabase = get_supabase_client()
            
            # Calculate date range
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            # Query expense items with related data
            response = supabase.table('expense_items').select(
                '*, expenses(expense_date, receipts(merchant_name, transaction_date)), categories(name)'
            ).eq('user_id', user_id).gte(
                'created_at', start_date.isoformat()
            ).lte(
                'created_at', end_date.isoformat()
            ).order('created_at', desc=True).execute()
            
            return response.data if response.data else []
            
        except Exception as e:
            logger.error(f"Failed to get user expense items: {str(e)}")
            return []

    async def _get_user_expenses(self, user_id: str, days: int) -> List[Dict[str, Any]]:
        """Get user's expenses for the specified number of days"""
        try:
            supabase = get_supabase_client()
            
            # Calculate date range
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days)
            
            # Query expenses
            response = supabase.table('expenses').select(
                '*, receipts(merchant_name, transaction_date)'
            ).eq('user_id', user_id).gte(
                'expense_date', start_date.isoformat()
            ).lte(
                'expense_date', end_date.isoformat()
            ).order('expense_date', desc=True).execute()
            
            return response.data if response.data else []
            
        except Exception as e:
            logger.error(f"Failed to get user expenses: {str(e)}")
            return []

    def _group_similar_expenses(self, expense_items: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
        """Group similar expenses together"""
        groups = defaultdict(list)
        
        for item in expense_items:
            # Create a key based on description and merchant
            description = item.get('description', '').lower().strip()
            merchant = ''
            if item.get('expenses') and item['expenses'].get('receipts'):
                merchant = item['expenses']['receipts'].get('merchant_name', '').lower().strip()
            
            # Normalize description (remove numbers, special chars)
            normalized_desc = re.sub(r'[0-9\W]+', ' ', description).strip()
            
            # Create group key
            group_key = f"{normalized_desc}|{merchant}"
            groups[group_key].append(item)
        
        return dict(groups)

    async def _analyze_expense_pattern(self, group_key: str, expenses: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """Analyze pattern for a group of similar expenses"""
        try:
            if len(expenses) < 3:
                return None
            
            # Extract dates and amounts
            dates = []
            amounts = []
            
            for expense in expenses:
                if expense.get('expenses') and expense['expenses'].get('expense_date'):
                    date_str = expense['expenses']['expense_date']
                    date = safe_parse_datetime(date_str)
                    if date:
                        dates.append(date)
                        amount = expense.get('amount')
                        amounts.append(float(amount) if amount is not None else 0.0)
            
            if len(dates) < 3:
                return None
            
            # Sort by date
            date_amount_pairs = sorted(zip(dates, amounts))
            dates = [pair[0] for pair in date_amount_pairs]
            amounts = [pair[1] for pair in date_amount_pairs]
            
            # Calculate intervals between occurrences
            intervals = []
            for i in range(1, len(dates)):
                interval = (dates[i] - dates[i-1]).days
                intervals.append(interval)
            
            # Determine frequency pattern
            avg_interval = sum(intervals) / len(intervals) if intervals else 0
            frequency = self._determine_frequency(avg_interval)
            
            # Calculate confidence based on consistency
            confidence = self._calculate_pattern_confidence(intervals, amounts)
            
            if confidence < 0.6:  # Low confidence threshold
                return None
            
            # Extract pattern details
            description_parts = group_key.split('|')
            description = description_parts[0].strip()
            merchant = description_parts[1].strip() if len(description_parts) > 1 else None
            
            return {
                'description': description,
                'merchant': merchant,
                'amount_range': {
                    'min': min(amounts),
                    'max': max(amounts),
                    'avg': sum(amounts) / len(amounts)
                },
                'frequency': frequency,
                'last_occurrence': max(dates),
                'confidence': confidence,
                'occurrences': len(expenses)
            }
            
        except Exception as e:
            logger.error(f"Pattern analysis failed: {str(e)}")
            return None

    def _determine_frequency(self, avg_interval: float) -> str:
        """Determine frequency based on average interval"""
        if avg_interval <= 2:
            return "daily"
        elif avg_interval <= 8:
            return "weekly"
        elif avg_interval <= 35:
            return "monthly"
        elif avg_interval <= 95:
            return "quarterly"
        else:
            return "irregular"

    def _calculate_pattern_confidence(self, intervals: List[int], amounts: List[float]) -> float:
        """Calculate confidence score for pattern recognition"""
        if not intervals or not amounts:
            return 0.0
        
        # Interval consistency (lower variance = higher confidence)
        avg_interval = sum(intervals) / len(intervals)
        interval_variance = sum((x - avg_interval) ** 2 for x in intervals) / len(intervals)
        interval_consistency = max(0, 1 - (interval_variance / (avg_interval ** 2)) if avg_interval > 0 else 0)
        
        # Amount consistency (lower variance = higher confidence)
        avg_amount = sum(amounts) / len(amounts)
        amount_variance = sum((x - avg_amount) ** 2 for x in amounts) / len(amounts)
        amount_consistency = max(0, 1 - (amount_variance / (avg_amount ** 2)) if avg_amount > 0 else 0)
        
        # Combine scores
        confidence = (interval_consistency * 0.6 + amount_consistency * 0.4)
        return min(1.0, max(0.0, confidence))

    def _group_by_product_and_merchant(self, expense_items: List[Dict[str, Any]]) -> Dict[str, List[Dict[str, Any]]]:
        """Group expense items by product and merchant"""
        groups = defaultdict(list)
        
        for item in expense_items:
            description = item.get('description', '').lower().strip()
            merchant = ''
            if item.get('expenses') and item['expenses'].get('receipts'):
                merchant = item['expenses']['receipts'].get('merchant_name', '').lower().strip()
            
            # Extract product name (remove quantities, sizes, etc.)
            product_name = self._extract_product_name(description)
            
            # Create group key
            group_key = f"{product_name}|{merchant}"
            groups[group_key].append(item)
        
        return dict(groups)

    def _extract_product_name(self, description: str) -> str:
        """Extract product name from description"""
        # Remove common quantity indicators
        description = re.sub(r'\b\d+\s*(adet|kg|gr|lt|ml|piece|pcs)\b', '', description, flags=re.IGNORECASE)
        
        # Remove numbers and special characters
        description = re.sub(r'[0-9\W]+', ' ', description)
        
        # Take first few words as product name
        words = description.strip().split()
        return ' '.join(words[:3]) if words else description

    async def _analyze_price_changes(self, product_key: str, items: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Analyze price changes for a specific product"""
        changes = []
        
        try:
            # Sort items by date
            sorted_items = sorted(items, key=lambda x: x.get('created_at', ''))
            
            # Compare consecutive purchases
            for i in range(1, len(sorted_items)):
                prev_item = sorted_items[i-1]
                curr_item = sorted_items[i]
                
                # Safely get prices, handling None values
                prev_unit_price = prev_item.get('unit_price')
                prev_amount = prev_item.get('amount')
                prev_price = float(prev_unit_price) if prev_unit_price is not None else (float(prev_amount) if prev_amount is not None else 0)
                
                curr_unit_price = curr_item.get('unit_price')
                curr_amount = curr_item.get('amount')
                curr_price = float(curr_unit_price) if curr_unit_price is not None else (float(curr_amount) if curr_amount is not None else 0)
                
                if prev_price > 0 and curr_price > 0:
                    price_change = curr_price - prev_price
                    price_change_percentage = (price_change / prev_price) * 100
                    
                    # Extract product and merchant info
                    product_parts = product_key.split('|')
                    product_name = product_parts[0].strip()
                    merchant = product_parts[1].strip() if len(product_parts) > 1 else 'Unknown'
                    
                    first_seen = safe_parse_datetime(prev_item.get('created_at', ''))
                    last_updated = safe_parse_datetime(curr_item.get('created_at', ''))
                    
                    if first_seen and last_updated:
                        changes.append({
                            'product_name': product_name,
                            'merchant': merchant,
                            'previous_price': prev_price,
                            'current_price': curr_price,
                            'price_change': price_change,
                            'price_change_percentage': price_change_percentage,
                            'first_seen': first_seen,
                            'last_updated': last_updated
                        })
            
            return changes
            
        except Exception as e:
            logger.error(f"Price change analysis failed: {str(e)}")
            return []

    async def _extract_expiration_info(self, item: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Extract expiration information from expense item"""
        try:
            description = item.get('description', '').lower()
            
            # Look for expiration-related keywords
            expiration_keywords = ['süt', 'milk', 'yogurt', 'yoğurt', 'peynir', 'cheese', 'et', 'meat', 'tavuk', 'chicken']
            
            has_expiration_keyword = any(keyword in description for keyword in expiration_keywords)
            
            if not has_expiration_keyword:
                return None
            
            # Estimate expiration based on product type
            expiration_days = self._estimate_expiration_days(description)
            
            if expiration_days is None:
                return None
            
            # Calculate expiration date
            purchase_date = safe_parse_datetime(item.get('created_at', ''))
            if not purchase_date:
                return None
            expiration_date = purchase_date + timedelta(days=expiration_days)
            
            # Get merchant info
            merchant = 'Unknown'
            if item.get('expenses') and item['expenses'].get('receipts'):
                merchant = item['expenses']['receipts'].get('merchant_name', 'Unknown')
            
            return {
                'product_name': item.get('description', ''),
                'expiration_date': expiration_date,
                'purchase_date': purchase_date,
                'merchant': merchant,
                'amount_paid': float(item.get('amount')) if item.get('amount') is not None else 0.0
            }
            
        except Exception as e:
            logger.error(f"Expiration info extraction failed: {str(e)}")
            return None

    def _estimate_expiration_days(self, description: str) -> Optional[int]:
        """Estimate expiration days based on product description"""
        # Simple heuristics for common products
        if any(keyword in description for keyword in ['süt', 'milk']):
            return 5  # Milk expires in ~5 days
        elif any(keyword in description for keyword in ['yogurt', 'yoğurt']):
            return 7  # Yogurt expires in ~7 days
        elif any(keyword in description for keyword in ['peynir', 'cheese']):
            return 14  # Cheese expires in ~14 days
        elif any(keyword in description for keyword in ['et', 'meat', 'tavuk', 'chicken']):
            return 3  # Fresh meat expires in ~3 days
        elif any(keyword in description for keyword in ['ekmek', 'bread']):
            return 2  # Bread expires in ~2 days
        
        return None

    async def _analyze_daily_patterns(self, expense_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze daily spending patterns"""
        daily_totals = defaultdict(float)
        
        for expense in expense_data:
            date_str = expense.get('expense_date', '')
            if date_str:
                date = safe_parse_datetime(date_str)
                if date:
                    day_of_week = date.strftime('%A')
                    total_amount = expense.get('total_amount')
                    amount = float(total_amount) if total_amount is not None else 0.0
                    daily_totals[day_of_week] += amount
        
        # Calculate averages
        day_counts = defaultdict(int)
        for expense in expense_data:
            date_str = expense.get('expense_date', '')
            if date_str:
                date = safe_parse_datetime(date_str)
                if date:
                    day_of_week = date.strftime('%A')
                    day_counts[day_of_week] += 1
        
        daily_averages = {}
        for day, total in daily_totals.items():
            count = day_counts.get(day, 1)
            daily_averages[day] = round(total / count, 2)
        
        return {
            'daily_totals': dict(daily_totals),
            'daily_averages': daily_averages,
            'highest_spending_day': max(daily_averages.items(), key=lambda x: x[1])[0] if daily_averages else None,
            'lowest_spending_day': min(daily_averages.items(), key=lambda x: x[1])[0] if daily_averages else None
        }

    async def _analyze_weekly_patterns(self, expense_data: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Analyze weekly spending patterns"""
        weekly_totals = defaultdict(float)
        
        for expense in expense_data:
            date_str = expense.get('expense_date', '')
            if date_str:
                date = safe_parse_datetime(date_str)
                if date:
                    week_start = date - timedelta(days=date.weekday())
                    week_key = week_start.strftime('%Y-W%U')
                    total_amount = expense.get('total_amount')
                    amount = float(total_amount) if total_amount is not None else 0.0
                    weekly_totals[week_key] += amount
        
        if not weekly_totals:
            return {}
        
        weekly_amounts = list(weekly_totals.values())
        
        return {
            'weekly_totals': dict(weekly_totals),
            'average_weekly_spending': round(sum(weekly_amounts) / len(weekly_amounts), 2),
            'highest_weekly_spending': round(max(weekly_amounts), 2),
            'lowest_weekly_spending': round(min(weekly_amounts), 2),
            'weekly_variance': round(
                sum((x - sum(weekly_amounts) / len(weekly_amounts)) ** 2 for x in weekly_amounts) / len(weekly_amounts), 2
            )
        }

    async def _generate_pattern_insights(self, daily_patterns: Dict[str, Any], weekly_patterns: Dict[str, Any]) -> List[str]:
        """Generate insights from spending patterns"""
        insights = []
        
        # Daily insights
        if daily_patterns.get('highest_spending_day') and daily_patterns.get('lowest_spending_day'):
            highest_day = daily_patterns['highest_spending_day']
            lowest_day = daily_patterns['lowest_spending_day']
            insights.append(f"You spend most on {highest_day}s and least on {lowest_day}s")
        
        # Weekly variance insights
        if weekly_patterns.get('weekly_variance'):
            variance = weekly_patterns['weekly_variance']
            if variance > 1000:
                insights.append("Your weekly spending varies significantly - consider budgeting for consistency")
            elif variance < 100:
                insights.append("Your weekly spending is very consistent - great budgeting!")
        
        return insights 