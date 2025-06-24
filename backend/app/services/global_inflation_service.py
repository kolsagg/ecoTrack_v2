import logging
import json
import os
from typing import Dict, Any, List, Optional, Tuple
from decimal import Decimal, InvalidOperation
from collections import defaultdict
import re
from datetime import datetime, date
from unidecode import unidecode
from dateutil.parser import isoparse

from app.db.supabase_client import get_supabase_client
from app.core.config import settings

logger = logging.getLogger(__name__)

def _safe_parse_datetime(date_str: str) -> Optional[datetime]:
    """
    Safely parse datetime string using dateutil.parser.isoparse for robustness.
    Returns None if parsing fails.
    """
    if not date_str or not isinstance(date_str, str):
        return None
    try:
        # isoparse is more flexible than fromisoformat
        return isoparse(date_str)
    except (ValueError, TypeError) as e:
        logger.warning(f"Could not parse datetime string '{date_str}': {e}")
        return None

def _normalize_product_name(description: str) -> str:
    """
    Extract a more robust, normalized product name from its description.
    Handles character variations, word order, and common units.
    """
    if not description:
        return "Unknown Product"

    # 1. Convert to lowercase and handle Turkish characters (e.g., ş -> s)
    normalized = unidecode(description.lower())

    # 2. Remove non-alphanumeric characters (except spaces) to clean up
    normalized = re.sub(r'[^a-z0-9\s]', '', normalized)

    # 3. Aggressively remove common units, quantities, and noise words
    noise = r'\b(\d+\s*(kg|g|gr|lt|l|ml|cc|adet|li|lu|lü|paket|pk|x\d+))\b'
    normalized = re.sub(noise, '', normalized)

    # 4. Split into words, sort them alphabetically, and rejoin
    # This makes "Süt Sütaş" and "Sütaş Süt" identical
    words = sorted(normalized.strip().split())
    
    # Filter out very short, likely meaningless words if necessary
    words = [word for word in words if len(word) > 1]

    if not words:
        return "Unknown Product"
        
    return " ".join(words)

class GlobalInflationService:
    """Service to calculate and store monthly product inflation data."""

    def __init__(self):
        self.supabase = settings.supabase_admin
        self.table_name = "global_product_inflation"
        self.product_mappings = self._load_product_mappings()

    def _load_product_mappings(self) -> Dict[str, str]:
        """
        Load product mapping rules from JSON file.
        Returns empty dict if file doesn't exist or has errors.
        """
        try:
            mappings_path = os.path.join(os.path.dirname(__file__), '..', 'core', 'product_mappings.json')
            with open(mappings_path, 'r', encoding='utf-8') as f:
                mappings = json.load(f)
                logger.info(f"Loaded {len(mappings)} product mapping rules")
                return mappings
        except (FileNotFoundError, json.JSONDecodeError) as e:
            logger.warning(f"Could not load product mappings: {e}. Using automatic normalization only.")
            return {}

    def _get_canonical_product_name(self, description: str) -> str:
        """
        Get the canonical product name using both normalization and mapping rules.
        """
        # First, normalize the product name
        normalized = _normalize_product_name(description)
        
        # Then check if we have a mapping rule for this normalized name
        canonical_name = self.product_mappings.get(normalized, normalized)
        
        return canonical_name

    async def calculate_and_store_monthly_inflation(self):
        """
        Fetches all expense items, calculates monthly inflation for each product,
        and stores the results in the database.
        
        Monthly inflation is calculated as month-over-month price changes.
        """
        logger.info("Starting monthly product inflation calculation...")
        try:
            # 1. Fetch all expense items with their dates
            logger.info("Fetching expenses data from database...")
            response = self.supabase.table("expenses").select(
                "expense_date, items:expense_items(description, amount)"
            ).execute()

            logger.info(f"Database query completed. Found {len(response.data) if response.data else 0} expense records.")
            
            if not response.data:
                logger.warning("No expense data found to calculate inflation.")
                return

            # 2. Process and group items by product and month
            logger.info("Processing and grouping expense items by product and month...")
            monthly_product_data = self._group_items_by_month(response.data)
            
            logger.info(f"Found data for {len(monthly_product_data)} unique product-month combinations.")
            
            # 3. Calculate monthly averages and inflation
            logger.info("Calculating monthly averages and inflation rates...")
            inflation_results = self._calculate_monthly_inflation(monthly_product_data)

            logger.info(f"Successfully calculated inflation for {len(inflation_results)} product-month combinations.")

            # 4. Store results in the database
            if inflation_results:
                logger.info("Storing monthly inflation data to database...")
                self._upsert_monthly_inflation_data(inflation_results)
                logger.info(f"Successfully stored monthly inflation data for {len(inflation_results)} records.")
            else:
                logger.info("No products with sufficient data to calculate monthly inflation.")

        except Exception as e:
            logger.error(f"Monthly inflation calculation process failed: {e}", exc_info=True)

    def _group_items_by_month(self, expenses: List[Dict[str, Any]]) -> Dict[Tuple[str, int, int], List[Decimal]]:
        """
        Groups all items by canonical product name and month.
        Returns dict with key (product_name, year, month) and value list of prices.
        """
        monthly_groups = defaultdict(list)
        total_items_processed = 0
        
        for expense in expenses:
            expense_date_str = expense.get('expense_date')
            items = expense.get('items', [])
            
            # Parse the expense date
            if not expense_date_str:
                logger.warning(f"Skipping expense with missing date")
                continue
                
            expense_dt = _safe_parse_datetime(expense_date_str)
            if not expense_dt:
                logger.warning(f"Skipping expense with invalid date: {expense_date_str}")
                continue
                
            expense_year = expense_dt.year
            expense_month = expense_dt.month
            
            logger.info(f"Processing expense from {expense_year}-{expense_month} with {len(items)} items")
            
            for item in items:
                total_items_processed += 1
                description = item.get('description', '')
                
                # Get canonical product name
                product_name = self._get_canonical_product_name(description)
                
                try:
                    price = Decimal(item.get('amount') or 0)
                    if price > 0:
                        month_key = (product_name, expense_year, expense_month)
                        monthly_groups[month_key].append(price)
                        logger.debug(f"Added to group {month_key}: price={price}")
                    else:
                        logger.warning(f"Skipping item with invalid price: {price}")
                except (InvalidOperation, TypeError) as e:
                    logger.warning(f"Skipping item with invalid amount data: {e}")
                    continue
                    
        logger.info(f"Processed {total_items_processed} total items into {len(monthly_groups)} product-month groups")
        return dict(monthly_groups)

    def _calculate_monthly_inflation(self, monthly_data: Dict[Tuple[str, int, int], List[Decimal]]) -> List[Dict[str, Any]]:
        """
        Calculate monthly inflation for each product.
        Returns list of records ready for database insertion.
        """
        results = []
        
        # Group by product name to calculate month-over-month changes
        products_by_name = defaultdict(list)
        
        # First, organize data by product name
        for (product_name, year, month), prices in monthly_data.items():
            if len(prices) == 0:
                continue
                
            # Calculate average price for this month
            avg_price = sum(prices) / len(prices)
            purchase_count = len(prices)
            
            products_by_name[product_name].append({
                'year': year,
                'month': month,
                'average_price': avg_price,
                'purchase_count': purchase_count
            })
        
        # Now calculate month-over-month inflation for each product
        for product_name, monthly_records in products_by_name.items():
            # Sort by year, month
            monthly_records.sort(key=lambda x: (x['year'], x['month']))
            
            logger.info(f"Calculating inflation for product '{product_name}' with {len(monthly_records)} monthly records")
            
            # Calculate inflation for each month (compared to previous month)
            for i, current_month in enumerate(monthly_records):
                current_year = current_month['year']
                current_month_num = current_month['month']
                current_avg_price = current_month['average_price']
                current_purchase_count = current_month['purchase_count']
                
                # Find previous month data
                previous_month_price = None
                inflation_percentage = None
                
                if i > 0:
                    # Use the immediately previous record
                    prev_record = monthly_records[i - 1]
                    previous_month_price = prev_record['average_price']
                    
                    # Calculate month-over-month inflation percentage
                    if previous_month_price > 0:
                        inflation_percentage = ((current_avg_price - previous_month_price) / previous_month_price) * 100
                
                # Create record for database
                record = {
                    'product_name': product_name,
                    'year': current_year,
                    'month': current_month_num,
                    'average_price': float(current_avg_price),
                    'purchase_count': current_purchase_count,
                    'previous_month_price': float(previous_month_price) if previous_month_price is not None else None,
                    'inflation_percentage': float(inflation_percentage) if inflation_percentage is not None else None,
                    'last_updated_at': datetime.now().isoformat()
                }
                
                results.append(record)
                
                logger.debug(f"Product '{product_name}' {current_year}-{current_month_num}: "
                           f"avg_price={current_avg_price:.2f}, inflation={inflation_percentage:.2f}%" 
                           if inflation_percentage is not None else f"avg_price={current_avg_price:.2f}, no previous data")
        
        return results

    def _upsert_monthly_inflation_data(self, data: List[Dict[str, Any]]):
        """
        Insert or update monthly inflation data in the database.
        Uses upsert to handle conflicts on unique constraint (product_name, year, month).
        """
        try:
            logger.info(f"Upserting {len(data)} monthly inflation records...")
            
            # Supabase upsert with conflict resolution
            response = self.supabase.table(self.table_name).upsert(
                data,
                on_conflict="product_name,year,month"
            ).execute()
            
            logger.info(f"Successfully upserted {len(response.data) if response.data else len(data)} records")
            
        except Exception as e:
            logger.error(f"Failed to upsert monthly inflation data: {e}", exc_info=True)
            raise

    # Keep the old method name for backward compatibility
    async def calculate_and_store_global_inflation(self):
        """
        Backward compatibility method - delegates to the new monthly calculation.
        """
        logger.info("Delegating to monthly inflation calculation...")
        await self.calculate_and_store_monthly_inflation() 