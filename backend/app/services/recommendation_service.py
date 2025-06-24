"""
AI-powered recommendation service for financial insights and waste prevention.
Uses Ollama with qwen2.5:3b for intelligent analysis of user spending patterns.
"""

import json
import logging
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta, date
import asyncio

from app.schemas.recommendation_schemas import (
    WastePreventionAlert,
    CategoryAnomalyAlert,
    SpendingPatternInsight,
    RecommendationResponse,
    LLMWastePreventionResponse,
    LLMAnomalyResponse,
    LLMPatternResponse
)
from app.db.supabase_client import get_supabase_client, get_authenticated_supabase_client
from collections import defaultdict

logger = logging.getLogger(__name__)

def parse_date_safely(date_str: Any) -> date:
    """Safely parse date string from Supabase"""
    try:
        if isinstance(date_str, (datetime, date)):
            return date_str.date() if isinstance(date_str, datetime) else date_str
        if isinstance(date_str, str):
            # Handle Z suffix
            if date_str.endswith('Z'):
                date_str = date_str.replace('Z', '+00:00')
            
            # Handle microseconds with more than 6 digits (Supabase issue)
            if '+' in date_str and '.' in date_str:
                # Split at timezone
                date_part, tz_part = date_str.rsplit('+', 1)
                if '.' in date_part:
                    # Limit microseconds to 6 digits
                    main_part, microsec_part = date_part.rsplit('.', 1)
                    microsec_part = microsec_part[:6].ljust(6, '0')  # Ensure exactly 6 digits
                    date_str = f"{main_part}.{microsec_part}+{tz_part}"
            
            return datetime.fromisoformat(date_str).date()
    except (ValueError, TypeError) as e:
        logger.debug(f"First parse attempt failed for '{date_str}': {e}")
        try:
            # Fallback: try simple date format
            return datetime.strptime(str(date_str), '%Y-%m-%d').date()
        except (ValueError, TypeError, AttributeError) as e2:
            logger.warning(f"Could not parse date: {date_str}. Error: {e2}. Returning today's date.")
            return date.today()
    return date.today()

class RecommendationService:
    """Service for AI-powered financial recommendations and insights"""
    
    def __init__(self):
        self.supabase = get_supabase_client()

    @property
    def client(self):
        """Lazily get the Ollama client from the ai_categorizer singleton."""
        from app.services.ai_categorizer import ai_categorizer
        return ai_categorizer.client

    @property
    def model_name(self):
        """Lazily get the model name from the ai_categorizer singleton."""
        from app.services.ai_categorizer import ai_categorizer
        return ai_categorizer.model_name

    @property
    def _model_available(self):
        """Lazily check if the model is available via the ai_categorizer singleton."""
        from app.services.ai_categorizer import ai_categorizer
        return ai_categorizer._model_available

    async def generate_recommendations(self, user_id: str, supabase_client=None) -> RecommendationResponse:
        """Generate comprehensive recommendations for a user"""
        logger.info(f"Generating recommendations for user: {user_id}")
        
        # Use provided client or get authenticated client
        client = supabase_client if supabase_client else get_authenticated_supabase_client()
        
        # Run all recommendation types in parallel for better performance
        waste_alerts_task = self.generate_waste_prevention_alerts(user_id, client)
        anomaly_alerts_task = self.generate_anomaly_alerts(user_id, client)
        pattern_insights_task = self.generate_pattern_insights(user_id, client)
        
        # Wait for all tasks to complete
        results = await asyncio.gather(
            waste_alerts_task,
            anomaly_alerts_task,
            pattern_insights_task,
            return_exceptions=True
        )
        
        # Handle any exceptions and ensure type safety for the response model
        waste_alerts = results[0] if isinstance(results[0], list) else []
        if isinstance(results[0], Exception):
            logger.error(f"Waste prevention alerts failed: {results[0]}")

        anomaly_alerts = results[1] if isinstance(results[1], list) else []
        if isinstance(results[1], Exception):
            logger.error(f"Anomaly alerts failed: {results[1]}")

        pattern_insights = results[2] if isinstance(results[2], list) else []
        if isinstance(results[2], Exception):
            logger.error(f"Pattern insights failed: {results[2]}")
        
        return RecommendationResponse(
            waste_prevention_alerts=waste_alerts,
            anomaly_alerts=anomaly_alerts,
            pattern_insights=pattern_insights
        )

    def _calculate_risk_level(self, days_since_purchase: int, shelf_life: int) -> tuple[str, str]:
        """Calculates risk level and generates an alert message based on product age."""
        if shelf_life <= 0:
            return "low", "Raf ömrü belirlenemedi."

        if days_since_purchase < 0:
            return "low", f"Bu ürün henüz yeni."

        if days_since_purchase >= shelf_life:
            days_expired = days_since_purchase - shelf_life
            if days_expired == 0:
                return "high", "Bugün son kullanma tarihi! Hemen kontrol edin."
            else:
                return "high", f"{days_expired} gün önce son kullanma tarihi geçti. Lütfen kontrol edin."

        risk_percentage = (days_since_purchase / shelf_life) * 100

        if risk_percentage >= 80:
            return "high", "Son kullanma tarihine çok az kaldı. Bugün veya yarın tüketin."
        elif risk_percentage >= 50:
            return "medium", "Tazeliğini kaybetmeye başlıyor. Yakında tüketmeyi unutmayın."
        else:
            return "low", "Hala taze."

    async def generate_waste_prevention_alerts(self, user_id: str, supabase_client=None) -> List[WastePreventionAlert]:
        """Generate waste prevention alerts for grocery items with Python-based logic."""
        alerts = []
        if not self._model_available:
            logger.info("LLM not available, skipping waste prevention alerts")
            return alerts

        NON_FOOD_KEYWORDS = ['servis', 'ücret', 'poşet', 'kurye', 'bag', 'fee', 'service', 'delivery', 'condom']
        
        try:
            grocery_transactions = await self._get_grocery_transactions(user_id, supabase_client)
            
            for transaction in grocery_transactions:
                try:
                    product_name = transaction['description']
                    
                    if any(keyword in product_name.lower() for keyword in NON_FOOD_KEYWORDS):
                        logger.info(f"Skipping non-food item: '{product_name}'")
                        continue

                    purchase_date = transaction['date']
                    days_since_purchase = (datetime.now().date() - purchase_date).days
                    
                    # Step 1: Get shelf life estimation from LLM
                    prompt = self._generate_waste_prevention_prompt(product_name)
                    llm_response = await self._call_llm_with_schema(prompt)
                    
                    # We only need the shelf life from the LLM.
                    shelf_life = int(llm_response.get("estimated_shelf_life_days", 0))

                    # Step 2: Calculate risk and message in Python
                    risk_level, alert_message = self._calculate_risk_level(days_since_purchase, shelf_life)
                    
                    alert = WastePreventionAlert(
                        product_name=product_name,
                        estimated_shelf_life_days=shelf_life,
                        purchase_date=purchase_date,
                        days_since_purchase=days_since_purchase,
                        risk_level=risk_level,
                        alert_message=f"'{product_name}': {alert_message}"
                    )
                    
                    # Step 3: Only add alerts with actual risk
                    if alert.risk_level in ['medium', 'high']:
                        logger.info(f"Generated alert for {product_name}: risk={risk_level}, shelf_life={shelf_life}d, days_passed={days_since_purchase}d")
                        alerts.append(alert)
                        
                except Exception as e:
                    logger.error(f"Failed to generate waste alert for '{transaction.get('description', 'N/A')}': {str(e)}")
                    continue
                    
        except Exception as e:
            logger.error(f"Failed to generate waste prevention alerts: {str(e)}")
            
        return alerts

    async def generate_anomaly_alerts(self, user_id: str, supabase_client=None) -> List[CategoryAnomalyAlert]:
        """Generate category-based anomaly alerts"""
        alerts = []
        
        if not self._model_available:
            logger.info("LLM not available, skipping anomaly alerts")
            return alerts
        
        try:
            # Get user's spending analysis by category
            category_spending = await self._get_category_spending_analysis(user_id, supabase_client)
            
            for category_data in category_spending:
                if category_data['is_anomaly']:
                    try:
                        prompt = self._generate_anomaly_alert_prompt(
                            category_data['category'],
                            category_data['current_spending'],
                            category_data['average_spending']
                        )
                        
                        llm_response = await self._call_llm_with_schema(prompt)
                        
                        # Validate LLM response
                        validated_response = LLMAnomalyResponse(**llm_response)
                        
                        alert = CategoryAnomalyAlert(
                            category=category_data['category'],
                            current_month_spending=category_data['current_spending'],
                            average_spending=category_data['average_spending'],
                            anomaly_percentage=validated_response.anomaly_percentage,
                            severity=validated_response.severity,
                            alert_message=validated_response.alert_message,
                            suggested_action=validated_response.suggested_action
                        )
                        
                        alerts.append(alert)
                        
                    except Exception as e:
                        logger.error(f"Failed to generate anomaly alert for {category_data['category']}: {str(e)}")
                        continue
                        
        except Exception as e:
            logger.error(f"Failed to generate anomaly alerts: {str(e)}")
            
        return alerts

    async def generate_pattern_insights(self, user_id: str, supabase_client=None) -> List[SpendingPatternInsight]:
        """Generate spending pattern insights"""
        insights = []
        
        if not self._model_available:
            logger.info("LLM not available, skipping pattern insights")
            return insights
        
        try:
            # Get spending patterns for different categories
            pattern_data = await self._get_spending_patterns(user_id, supabase_client)
            
            for category_pattern in pattern_data:
                try:
                    prompt = self._generate_pattern_insight_prompt(
                        category_pattern['category'],
                        category_pattern['spending_data']
                    )
                    
                    llm_response = await self._call_llm_with_schema(prompt)
                    
                    # Validate LLM response
                    validated_response = LLMPatternResponse(**llm_response)
                    
                    insight = SpendingPatternInsight(
                        pattern_type=validated_response.pattern_type,
                        category=category_pattern['category'],
                        insight_message=validated_response.insight_message,
                        recommendation=validated_response.recommendation,
                        potential_savings=validated_response.potential_savings
                    )
                    
                    insights.append(insight)
                    
                except Exception as e:
                    logger.error(f"Failed to generate pattern insight for {category_pattern['category']}: {str(e)}")
                    continue
                    
        except Exception as e:
            logger.error(f"Failed to generate pattern insights: {str(e)}")
            
        return insights

    def _generate_waste_prevention_prompt(self, product_name: str) -> str:
        """Generate a robust, simple prompt for waste prevention shelf life estimation."""
        
        prompt = f"""You are a precise Food Safety AI. Your only goal is to estimate the shelf life of a food item in days.

**Analyze the following item:**
- Product Name: {product_name}

**Your Task:**
- Identify the type of product (e.g., dairy, fruit, meat, processed snack).
- Based on its category, estimate a **reasonable, specific shelf life in days**.
- Use the following as a general guide, but your estimate should be specific to the `{product_name}`.
  - **Dairy (milk, yogurt):** ~7-14 days
  - **Fresh Produce (apples, lettuce):** ~5-30 days
  - **Bakery (fresh bread):** ~3-7 days
  - **Raw Meat/Poultry:** ~2-5 days
  - **Processed Snacks (chips, cola):** ~90-365 days
  - **Non-food items (e.g., cleaning supplies):** 365 days.

**Required JSON Output Format:**
{{
  "estimated_shelf_life_days": <integer>
}}

Now, provide the JSON for the product: **"{product_name}"**. Respond ONLY with the JSON object.
"""
        return prompt

    def _generate_anomaly_alert_prompt(self, category: str, current_spending: float, average_spending: float) -> str:
        """Generate structured prompt for anomaly detection"""
        
        # Handle division by zero for new spending categories
        if average_spending == 0:
            # New spending category - use a large percentage to indicate "new spending"
            prompt = f"""You are an expert financial coach specializing in Turkish consumer habits. Analyze this new spending category for a user.

SPENDING DATA:
- Category: {category}
- Current Month Spending: {current_spending:.2f} TRY
- Average Monthly Spending: 0.00 TRY (New category - first time spending)
- Context: This is a completely new spending area for this user

YOUR ROLE AS FINANCIAL COACH:
1. Determine severity based on amount (mild/moderate/severe)
2. Create a user-friendly alert message about this new spending
3. Generate a CREATIVE, CATEGORY-SPECIFIC savings tip that directly relates to "{category}"

COACHING GUIDELINES:
- Think about what "{category}" typically includes and how people can save money in that specific area
- Be practical and actionable - give concrete steps, not generic advice
- Consider Turkish market conditions and consumer behavior
- Make it personal and engaging, not robotic

REQUIRED JSON FORMAT:
{{
    "anomaly_percentage": 999.0,
    "severity": "moderate",
    "alert_message": "Yeni harcama alanı tespit edildi: {category} kategorisinde bu ay {current_spending:.0f} TRY harcadınız.",
    "suggested_action": "[Generate a creative, specific tip for {category} category]"
}}

EXAMPLES OF GOOD CATEGORY-SPECIFIC TIPS:
- For "Groceries": "Market alışverişinde tasarruf için haftalık menü planlayıp liste yaparak gereksiz alımları önleyebilirsiniz."
- For "Transportation": "Ulaşım masraflarını azaltmak için toplu taşıma aylık kartı veya bisiklet kullanımını değerlendirebilirsiniz."
- For "Shopping": "Alışveriş harcamalarını kontrol etmek için 24 saat kuralını uygulayın - beğendiğiniz ürünü hemen almayın, bir gün bekleyin."

RULES:
- anomaly_percentage: always 999.0 for new categories
- severity: "mild" (<500 TRY), "moderate" (500-2000 TRY), "severe" (>2000 TRY)
- alert_message: mention it's a new category in Turkish (10-200 characters)
- suggested_action: Generate a creative, specific savings tip for this exact category (10-200 characters)
- Be creative but practical - think like a financial advisor who knows Turkish consumer habits
- Respond ONLY with JSON"""
        else:
            # Existing category with percentage calculation
            anomaly_percentage = ((current_spending - average_spending) / average_spending) * 100
            
            prompt = f"""You are an expert financial coach specializing in Turkish consumer habits. Analyze this spending anomaly for a user.

SPENDING DATA:
- Category: {category}
- Current Month Spending: {current_spending:.2f} TRY
- Average Monthly Spending: {average_spending:.2f} TRY
- Increase Rate: {anomaly_percentage:.1f}%
- Context: User normally spends {average_spending:.0f} TRY but this month spent {current_spending:.0f} TRY

YOUR ROLE AS FINANCIAL COACH:
1. Determine anomaly severity (mild/moderate/severe)
2. Create a user-friendly alert message about the spending increase
3. Generate a CREATIVE, CATEGORY-SPECIFIC savings tip that directly relates to "{category}"

COACHING GUIDELINES:
- Think about what "{category}" typically includes and how people can reduce costs in that specific area
- Be practical and actionable - give concrete steps, not generic advice
- Consider the spending increase amount and suggest proportional solutions
- Consider Turkish market conditions and consumer behavior
- Make it personal and engaging, not robotic

REQUIRED JSON FORMAT:
{{
    "anomaly_percentage": {anomaly_percentage:.1f},
    "severity": "moderate",
    "alert_message": "{category} harcamalarınız bu ay %{anomaly_percentage:.0f} artarak {current_spending:.0f} TRY'ye ulaştı.",
    "suggested_action": "[Generate a creative, specific tip for {category} category]"
}}

EXAMPLES OF GOOD CATEGORY-SPECIFIC TIPS:
- For "Restaurants": "Dışarıda yeme masraflarını dengelemek için öğle menülerini tercih edin veya haftada bir gün 'evde yemek' günü belirleyin."
- For "Entertainment": "Eğlence harcamalarını optimize etmek için ücretsiz etkinlikleri araştırın veya grup indirimlerinden yararlanın."
- For "Personal Care": "Kişisel bakım masraflarında tasarruf için toplu alım fırsatlarını değerlendirin veya ev yapımı alternatifler deneyin."

RULES:
- anomaly_percentage: exact percentage as calculated
- severity: "mild" (50-100% increase), "moderate" (100-200% increase), "severe" (>200% increase)
- alert_message: clear explanation of the anomaly in Turkish (10-200 characters)
- suggested_action: Generate a creative, specific savings tip for this exact category (10-200 characters)
- Be creative but practical - think like a financial advisor who knows Turkish consumer habits
- Do NOT use generic advice like "review your budget" - be category-specific
- Respond ONLY with JSON"""

        return prompt

    def _generate_pattern_insight_prompt(self, category: str, spending_data: List[Dict]) -> str:
        """Generate structured prompt for spending pattern analysis"""
        
        data_summary = ", ".join([f"{item['month']}: {item['amount']:.0f} TRY" for item in spending_data[-6:]])
        
        prompt = f"""You are a financial analyst. Identify spending patterns and provide insights.

SPENDING DATA (Last 6 months):
- Category: {category}
- Monthly Spending: {data_summary}

YOUR TASK:
1. Identify any spending patterns (seasonal, weekly, monthly, recurring)
2. Provide actionable insights
3. Estimate potential savings if applicable

REQUIRED JSON FORMAT:
{{
    "pattern_type": "monthly",
    "insight_message": "Your grocery spending tends to spike at month-end.",
    "recommendation": "Consider bulk shopping at month-start to spread costs evenly.",
    "potential_savings": 150.0
}}

RULES:
- pattern_type: only "seasonal", "weekly", "monthly", or "recurring"
- insight_message: clear observation about the pattern (10-200 characters)
- recommendation: specific, actionable advice (10-200 characters)
- potential_savings: estimated monthly savings in TRY (or null if not applicable)
- Respond ONLY with JSON"""

        return prompt

    async def _call_llm_with_schema(self, prompt: str) -> Dict[str, Any]:
        """Call LLM with structured prompt"""
        try:
            response = self.client.chat(
                model=self.model_name,
                messages=[
                    {
                        'role': 'system',
                        'content': 'You are a financial assistant. You respond only in valid JSON format.'
                    },
                    {
                        'role': 'user',
                        'content': prompt
                    }
                ],
                format="json",
                options={
                    'temperature': 0.1,  # Low for consistency
                    'top_p': 0.8,
                    'num_predict': 150,
                    'stop': ['\n\n', '```', 'Explanation:', 'Note:']
                }
            )
            
            ai_response = response['message']['content'].strip()
            
            # Extract JSON from response
            json_start = ai_response.find('{')
            json_end = ai_response.rfind('}') + 1
            
            if json_start >= 0 and json_end > json_start:
                json_str = ai_response[json_start:json_end]
                return json.loads(json_str)
            else:
                raise ValueError("No valid JSON found in response")
                
        except Exception as e:
            logger.error(f"LLM schema call failed: {str(e)}")
            raise

    async def _get_grocery_transactions(self, user_id: str, supabase_client=None) -> List[Dict]:
        """Get grocery transactions using Supabase client (like analytics API)"""
        logger.info(f"Fetching real grocery data for user {user_id}")
        grocery_categories = ['Groceries']
        start_date = (datetime.now() - timedelta(days=30))
        logger.info(f"Looking for grocery categories: {grocery_categories} since {start_date}")
        
        try:
            # Use provided client or fallback to default
            client = supabase_client if supabase_client else self.supabase
            
            # Get expenses for the last 30 days (similar to analytics API pattern)
            query = client.table("expenses").select("""
                id, expense_date,
                expense_items(amount, description, categories(name))
            """).eq("user_id", user_id).gte("expense_date", start_date.isoformat())
            
            result = await asyncio.to_thread(query.execute)
            
            transactions = []
            if result.data:
                for expense in result.data:
                    expense_items = expense.get("expense_items", [])
                    expense_date_str = expense.get("expense_date")
                    
                    if not expense_date_str:
                        logger.warning(f"Expense with ID {expense.get('id')} has a null or empty expense_date.")
                        continue

                    purchase_date = parse_date_safely(expense_date_str)
                    logger.debug(f"Parsed expense_date '{expense_date_str}' to {purchase_date}")

                    for item in expense_items:
                        # Check if item belongs to grocery category
                        category_name = "Other"
                        if item.get("categories"):
                            category_name = item["categories"].get("name", "Other")
                        
                        if category_name in grocery_categories:
                            transactions.append({
                                "description": item.get("description", "Unknown Item"),
                                "date": purchase_date,
                                "amount": float(item.get("amount", 0.0))
                            })
            
            logger.info(f"Found {len(transactions)} grocery transactions for user {user_id}")
            return transactions
            
        except Exception as e:
            logger.error(f"Error fetching grocery transactions for user {user_id}: {e}")
            return []

    async def _get_category_spending_analysis(self, user_id: str, supabase_client=None) -> List[Dict]:
        """Get category spending analysis using a dynamic, user-centric threshold."""
        logger.info(f"Fetching real monthly spending data for user {user_id}")
        today = date.today()
        
        try:
            client = supabase_client if supabase_client else self.supabase
            
            current_month = datetime.now().month
            current_year = datetime.now().year
            
            monthly_spending = defaultdict(lambda: defaultdict(float))
            
            # Get last 4 months for a stable average (current + 3 previous)
            for i in range(4):
                if current_month - i <= 0:
                    month = current_month - i + 12
                    year = current_year - 1
                else:
                    month = current_month - i
                    year = current_year
                
                month_start = date(year, month, 1)
                if month == 12:
                    month_end = date(year + 1, 1, 1) - timedelta(days=1)
                else:
                    month_end = date(year, month + 1, 1) - timedelta(days=1)
                
                query = client.table("expenses").select("expense_items(amount, categories(name))") \
                    .eq("user_id", user_id) \
                    .gte("expense_date", month_start.isoformat()) \
                    .lte("expense_date", month_end.isoformat())
                
                result = await asyncio.to_thread(query.execute)
                month_key = month_start.strftime("%Y-%m")
                
                if result.data:
                    for expense in result.data:
                        for item in expense.get("expense_items", []):
                            category_name = item.get("categories", {}).get("name", "Other") if item.get("categories") else "Other"
                            monthly_spending[category_name][month_key] += float(item.get("amount", 0))

            # Calculate user's general financial scale for dynamic thresholds
            all_months = set()
            total_spending = 0
            for category_data in monthly_spending.values():
                for month, amount in category_data.items():
                    all_months.add(month)
                    total_spending += amount
            
            num_months = len(all_months)
            general_monthly_average = total_spending / num_months if num_months > 0 else 0
            
            logger.debug(f"User's general monthly average spending: {general_monthly_average:.2f} TRY over {num_months} months.")

            # Analyze for anomalies using dynamic thresholds
            analysis = []
            current_month_key = today.strftime("%Y-%m")

            for category, spending_by_month in monthly_spending.items():
                current_month_spending = spending_by_month.get(current_month_key, 0.0)
                
                past_spending = [amount for month, amount in spending_by_month.items() if month != current_month_key]
                has_past_data = bool(past_spending)
                average_spending = sum(past_spending) / len(past_spending) if has_past_data else 0.0

                is_anomaly = False
                
                # Dynamic thresholds based on general spending habits.
                # These have minimum fallbacks to handle low-spending users correctly.
                new_spending_threshold = max(general_monthly_average * 0.05, 250)
                increase_threshold = max(general_monthly_average * 0.025, 100)

                # Case 1: Significant spending in a new or infrequent category.
                if not has_past_data:
                    if current_month_spending > new_spending_threshold:
                        is_anomaly = True
                # Case 2: Significant increase over an existing average.
                else:
                    if current_month_spending > average_spending * 1.5 and \
                       (current_month_spending - average_spending) > increase_threshold:
                        is_anomaly = True
                
                if is_anomaly or current_month_spending > 0 or average_spending > 0:
                    logger.debug(
                        f"Analysis for '{category}': "
                        f"Current={current_month_spending:.2f}, "
                        f"PastAvg={average_spending:.2f}, "
                        f"IsAnomaly={is_anomaly} | "
                        f"Thresholds: New > {new_spending_threshold:.2f}, "
                        f"Increase > {increase_threshold:.2f}"
                    )
                    analysis.append({
                        'category': category,
                        'current_spending': current_month_spending,
                        'average_spending': average_spending,
                        'is_anomaly': is_anomaly
                    })
            
            logger.info(f"Found spending data for {len(analysis)} categories for user {user_id}")
            return analysis
                
        except Exception as e:
            logger.error(f"Error fetching category spending analysis for user {user_id}: {e}")
            return []

    async def _get_spending_patterns(self, user_id: str, supabase_client=None) -> List[Dict]:
        """Get spending patterns using Supabase client, aggregating from expense items."""
        logger.info(f"Fetching real spending history for user {user_id}")
        start_date = (datetime.now() - timedelta(days=180))
        
        try:
            # Use provided client or fallback to default
            client = supabase_client if supabase_client else self.supabase
            
            # Get expenses and their items for the last 180 days.
            # We only need item-level data for accurate category aggregation.
            query = client.table("expenses").select("""
                expense_date,
                expense_items(amount, categories(name))
            """).eq("user_id", user_id).gte("expense_date", start_date.isoformat()).order("expense_date", desc=True)
            
            result = await asyncio.to_thread(query.execute)
            logger.info(f"User {user_id}: Found {len(result.data)} expenses in the last 180 days.")

            # Group spending by category and month from expense items
            category_monthly = defaultdict(lambda: defaultdict(float))
            if result.data:
                for expense in result.data:
                    expense_date_obj = parse_date_safely(expense["expense_date"])
                    month_key = expense_date_obj.strftime("%Y-%m")
                    
                    expense_items = expense.get("expense_items", [])
                    
                    # Since every expense has items, we aggregate directly from them
                    for item in expense_items:
                        category_name = "Other"
                        if item.get("categories"):  # Check if relation exists
                            category_name = item["categories"].get("name", "Other")
                        
                        amount = float(item.get("amount", 0))
                        category_monthly[category_name][month_key] += amount
            
            logger.info(f"User {user_id}: Aggregated monthly spending: {json.dumps(dict(category_monthly), indent=2, ensure_ascii=False)}")

            patterns = []
            for category, monthly_data in category_monthly.items():
                logger.info(f"User {user_id}: Checking category '{category}'. Found data for {len(monthly_data)} months.")
                # We need at least 3 months of data to identify a meaningful pattern
                if len(monthly_data) >= 3:
                    logger.info(f"User {user_id}: Found a potential pattern for category '{category}' with {len(monthly_data)} months of data.")
                    spending_data = [
                        {'month': month, 'amount': amount}
                        for month, amount in sorted(monthly_data.items())
                    ]
                    patterns.append({
                        'category': category,
                        'spending_data': spending_data
                    })
            
            logger.info(f"Found spending patterns for {len(patterns)} categories for user {user_id}")
            return patterns
            
        except Exception as e:
            logger.error(f"Error fetching spending patterns for user {user_id}: {e}")
            return []

# Create singleton instance
recommendation_service = RecommendationService() 