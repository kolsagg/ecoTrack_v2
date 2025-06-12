"""
KDV (Turkish VAT) Calculator Utility
Handles different VAT rates used in Turkey: 1%, 10%, 20%
"""

from typing import Dict, List, Tuple
from decimal import Decimal, ROUND_HALF_UP


class KDVCalculator:
    """Calculator for Turkish KDV (VAT) with different rates"""
    
    # Valid KDV rates in Turkey
    VALID_KDV_RATES = [1.0, 10.0, 20.0]
    
    # Default KDV rate (most common)
    DEFAULT_KDV_RATE = 20.0
    
    # KDV rate categories for different product types (2025 Turkey rates)
    KDV_CATEGORIES = {
        # 1% KDV - Basic necessities and essential items
        1.0: [
            "basic_food", "bread", "milk", "cheese", "eggs", "rice", "flour",
            "vegetables", "fruits", "meat", "fish", "chicken", "oil", "sugar",
            "tea", "coffee", "pasta", "legumes", "dairy", "agriculture",
            "health", "medicine", "medical", "education", "second_hand_vehicle"
        ],
        
        # 10% KDV - Reduced rate items (increased from 8% in July 2023)
        10.0: [
            "housing", "residential", "apartment", "home", "books", "newspaper",
            "magazine", "publication", "cinema", "theater", "culture", "arts",
            "sports", "entertainment", "hotel", "accommodation", "tourism",
            "restaurant", "food_service", "catering"
        ],
        
        # 20% KDV - General rate (increased from 18% in July 2023)
        20.0: [
            "general", "clothing", "electronics", "furniture", "automotive",
            "services", "retail", "shopping", "technology", "household",
            "luxury", "jewelry", "tobacco", "alcohol", "cosmetics",
            "perfume", "telecommunications", "mobile", "internet",
            "software", "hardware", "appliances", "tools", "equipment"
        ]
    }
    
    @classmethod
    def validate_kdv_rate(cls, rate: float) -> bool:
        """Validate if KDV rate is valid"""
        return rate in cls.VALID_KDV_RATES
    
    @classmethod
    def calculate_kdv_amount(cls, total_amount: float, kdv_rate: float) -> float:
        """
        Calculate KDV amount from total amount (KDV included)
        Formula: KDV = (Total * KDV_Rate) / (100 + KDV_Rate)
        """
        if not cls.validate_kdv_rate(kdv_rate):
            raise ValueError(f"Invalid KDV rate: {kdv_rate}. Must be one of {cls.VALID_KDV_RATES}")
        
        if kdv_rate == 0.0:
            return 0.0
        
        # Use Decimal for precise calculations
        total = Decimal(str(total_amount))
        rate = Decimal(str(kdv_rate))
        
        kdv_amount = (total * rate) / (100 + rate)
        return float(kdv_amount.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
    
    @classmethod
    def calculate_amount_without_kdv(cls, total_amount: float, kdv_rate: float) -> float:
        """
        Calculate amount without KDV from total amount (KDV included)
        Formula: Amount_Without_KDV = Total / (1 + KDV_Rate/100)
        """
        if not cls.validate_kdv_rate(kdv_rate):
            raise ValueError(f"Invalid KDV rate: {kdv_rate}. Must be one of {cls.VALID_KDV_RATES}")
        
        if kdv_rate == 0.0:
            return total_amount
        
        # Use Decimal for precise calculations
        total = Decimal(str(total_amount))
        rate = Decimal(str(kdv_rate))
        
        amount_without_kdv = total / (1 + rate / 100)
        return float(amount_without_kdv.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
    
    @classmethod
    def calculate_total_with_kdv(cls, amount_without_kdv: float, kdv_rate: float) -> float:
        """
        Calculate total amount with KDV from amount without KDV
        Formula: Total = Amount_Without_KDV * (1 + KDV_Rate/100)
        """
        if not cls.validate_kdv_rate(kdv_rate):
            raise ValueError(f"Invalid KDV rate: {kdv_rate}. Must be one of {cls.VALID_KDV_RATES}")
        
        if kdv_rate == 0.0:
            return amount_without_kdv
        
        # Use Decimal for precise calculations
        amount = Decimal(str(amount_without_kdv))
        rate = Decimal(str(kdv_rate))
        
        total = amount * (1 + rate / 100)
        return float(total.quantize(Decimal('0.01'), rounding=ROUND_HALF_UP))
    
    @classmethod
    def get_kdv_breakdown(cls, total_amount: float, kdv_rate: float) -> Dict[str, float]:
        """
        Get complete KDV breakdown for an amount
        Returns: {
            'total_amount': float,
            'kdv_rate': float,
            'kdv_amount': float,
            'amount_without_kdv': float
        }
        """
        kdv_amount = cls.calculate_kdv_amount(total_amount, kdv_rate)
        amount_without_kdv = cls.calculate_amount_without_kdv(total_amount, kdv_rate)
        
        return {
            'total_amount': total_amount,
            'kdv_rate': kdv_rate,
            'kdv_amount': kdv_amount,
            'amount_without_kdv': amount_without_kdv
        }
    
    @classmethod
    def suggest_kdv_rate_by_category(cls, category: str) -> float:
        """
        Suggest KDV rate based on category
        Returns the most appropriate KDV rate for the given category
        """
        category_lower = category.lower()
        
        for rate, categories in cls.KDV_CATEGORIES.items():
            if any(cat in category_lower for cat in categories):
                return rate
        
        # Default to standard rate if no match found
        return cls.DEFAULT_KDV_RATE
    
    @classmethod
    def suggest_kdv_rate_by_description(cls, description: str) -> float:
        """
        Suggest KDV rate based on item description
        Returns the most appropriate KDV rate for the given description
        """
        description_lower = description.lower()
        
        # Check for specific keywords in description
        for rate, categories in cls.KDV_CATEGORIES.items():
            if any(cat in description_lower for cat in categories):
                return rate
        
        # Default to standard rate if no match found
        return cls.DEFAULT_KDV_RATE
    
    @classmethod
    def calculate_mixed_kdv_total(cls, items: List[Dict]) -> Dict[str, float]:
        """
        Calculate total KDV for multiple items with different KDV rates
        
        Args:
            items: List of dicts with 'amount' and 'kdv_rate' keys
            
        Returns:
            Dict with total amounts, KDV breakdown by rate, etc.
        """
        total_amount = 0.0
        total_kdv = 0.0
        total_without_kdv = 0.0
        kdv_by_rate = {}
        
        for item in items:
            amount = item.get('amount', 0.0)
            kdv_rate = item.get('kdv_rate', cls.DEFAULT_KDV_RATE)
            
            breakdown = cls.get_kdv_breakdown(amount, kdv_rate)
            
            total_amount += breakdown['total_amount']
            total_kdv += breakdown['kdv_amount']
            total_without_kdv += breakdown['amount_without_kdv']
            
            # Group by KDV rate
            if kdv_rate not in kdv_by_rate:
                kdv_by_rate[kdv_rate] = {
                    'total_amount': 0.0,
                    'kdv_amount': 0.0,
                    'amount_without_kdv': 0.0,
                    'item_count': 0
                }
            
            kdv_by_rate[kdv_rate]['total_amount'] += breakdown['total_amount']
            kdv_by_rate[kdv_rate]['kdv_amount'] += breakdown['kdv_amount']
            kdv_by_rate[kdv_rate]['amount_without_kdv'] += breakdown['amount_without_kdv']
            kdv_by_rate[kdv_rate]['item_count'] += 1
        
        return {
            'total_amount': round(total_amount, 2),
            'total_kdv': round(total_kdv, 2),
            'total_without_kdv': round(total_without_kdv, 2),
            'kdv_by_rate': kdv_by_rate,
            'average_kdv_rate': round((total_kdv / total_without_kdv * 100) if total_without_kdv > 0 else 0, 2)
        } 