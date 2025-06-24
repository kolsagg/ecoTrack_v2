"""
AI categorization service using Ollama with qwen2.5:3b for automatic expense categorization.
Provides intelligent category suggestions based on expense descriptions and merchant names.
"""

import logging
import json
import asyncio
from typing import Dict, Any, List, Optional
from datetime import datetime

try:
    import ollama
    OLLAMA_AVAILABLE = True
except ImportError:
    ollama = None
    OLLAMA_AVAILABLE = False

logger = logging.getLogger(__name__)

class AICategorizer:
    """Service for AI-powered expense categorization using Ollama qwen2.5:3b"""
    
    def __init__(self):
        self.model_name = "qwen2.5:3b"
        self.client = ollama.Client() if OLLAMA_AVAILABLE else None
        
        # Predefined categories with Turkish and English keywords
        self.categories = {
            'groceries': {
                'name': 'Groceries',
                'keywords': ['market', 'grocery', 'gıda', 'manav', 'kasap', 'süpermarket'],
                'merchants': ['migros', 'carrefour', 'bim', 'a101', 'şok', 'istegelsin', 'getir', 'yemeksepeti market']
            },
            'dining_out': {
                'name': 'Dining Out',
                'keywords': ['restaurant', 'cafe', 'yemek', 'restoran', 'kafe', 'lokanta', 'fast food'],
                'merchants': ['mcdonalds', 'burger king', 'starbucks', 'yemeksepeti', 'getir yemek', 'nevrest']
            },
            'transportation': {
                'name': 'Transportation',
                'keywords': ['gas', 'fuel', 'petrol', 'benzin', 'bus', 'metro', 'taxi', 'uber', 'otobüs', 'taksi'],
                'merchants': ['shell', 'bp', 'opet', 'petrol ofisi', 'uber', 'bitaksi']
            },
            'shopping': {
                'name': 'Shopping',
                'keywords': ['clothing', 'shoes', 'electronics', 'giyim', 'ayakkabı', 'elektronik', 'alışveriş'],
                'merchants': ['zara', 'h&m', 'lcw', 'teknosa', 'vatan', 'media markt']
            },
            'health_medical': {
                'name': 'Healthcare',
                'keywords': ['pharmacy', 'hospital', 'doctor', 'medicine', 'eczane', 'hastane', 'doktor', 'ilaç'],
                'merchants': ['eczane', 'pharmacy', 'hospital', 'hastane']
            },
            'entertainment': {
                'name': 'Entertainment',
                'keywords': ['cinema', 'movie', 'theater', 'concert', 'sinema', 'film', 'tiyatro', 'konser'],
                'merchants': ['cinemaximum', 'cineworld', 'spotify', 'netflix']
            },
            'utilities': {
                'name': 'Utilities',
                'keywords': ['electric', 'water', 'gas', 'internet', 'phone', 'elektrik', 'su', 'gaz', 'internet', 'telefon'],
                'merchants': ['türk telekom', 'vodafone', 'turkcell']
            },
            'education': {
                'name': 'Education',
                'keywords': ['book', 'school', 'course', 'university', 'kitap', 'okul', 'kurs', 'üniversite'],
                'merchants': ['d&r', 'kitapyurdu', 'udemy']
            },
            'personal_care': {
                'name': 'Personal Care',
                'keywords': ['cosmetic', 'beauty', 'hair', 'spa', 'kozmetik', 'güzellik', 'saç', 'berber'],
                'merchants': ['sephora', 'gratis', 'watsons']
            },
            'travel': {
                'name': 'Travel',
                'keywords': ['hotel', 'flight', 'vacation', 'trip', 'otel', 'uçak', 'tatil', 'seyahat'],
                'merchants': ['booking', 'hotels.com', 'turkish airlines', 'pegasus']
            },
            'other': {
                'name': 'Other',
                'keywords': [],
                'merchants': []
            }
        }
        
        # Initialize model check
        self._model_available = False
        self._check_model_availability()

    def _check_model_availability(self):
        """Check if qwen2.5:3b model is available"""
        if not OLLAMA_AVAILABLE or not self.client:
            self._model_available = False
            logger.info("Ollama not available - AI categorization disabled, using rule-based only")
            return
            
        try:
            # Test connection with timeout
            import socket
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(2)  # 2 second timeout
            
            # Parse host and port from OLLAMA_HOST
            from app.core.config import settings
            host_url = settings.OLLAMA_HOST
            if "://" in host_url:
                host_url = host_url.split("://")[1]
            if ":" in host_url:
                host, port = host_url.split(":")
                port = int(port)
            else:
                host = host_url
                port = 11434
            
            result = sock.connect_ex((host, port))
            sock.close()
            
            if result != 0:
                logger.info("Ollama server not reachable - AI categorization disabled, using rule-based only")
                self._model_available = False
                return
            
            # If connection successful, check models
            models_response = self.client.list()
            # Handle new Ollama API response format
            if hasattr(models_response, 'models'):
                # New format: ListResponse object with models attribute
                available_models = [model.model for model in models_response.models]
            elif isinstance(models_response, dict) and 'models' in models_response:
                # Old format: dict with models key
                available_models = [model['name'] for model in models_response['models']]
            else:
                # Fallback: assume it's a list
                available_models = [str(model) for model in models_response]
            
            self._model_available = self.model_name in available_models
            
            if not self._model_available:
                logger.info(f"Model {self.model_name} not found. Available models: {available_models}")
                logger.info("AI categorization will use rule-based fallback")
            else:
                logger.info(f"Model {self.model_name} is available - AI categorization enabled")
                
        except Exception as e:
            logger.info(f"Ollama connection failed: {str(e)} - AI categorization disabled, using rule-based only")
            self._model_available = False

    async def categorize_expense(self, description: str, merchant_name: str = None, amount: float = None) -> Dict[str, Any]:
        """
        Categorize an expense using both AI and rule-based approaches
        
        Args:
            description: Expense description
            merchant_name: Merchant name (optional)
            amount: Expense amount (optional)
            
        Returns:
            Dictionary containing category suggestion and confidence
        """
        try:
            logger.info(f"Categorizing expense: {description}")
            
            # Always get rule-based result
            rule_based_result = self._rule_based_categorization(description, merchant_name)
            logger.info(f"Rule-based result: {rule_based_result['category']} (confidence: {rule_based_result['confidence']})")
            
            # Always try AI categorization if model is available
            ai_result = None
            if self._model_available:
                try:
                    ai_result = await self._ai_categorization(description, merchant_name, amount)
                    logger.info(f"AI result: {ai_result['category']} (confidence: {ai_result['confidence']})")
                except Exception as e:
                    logger.warning(f"AI categorization failed: {str(e)}")
            else:
                logger.info("AI model not available, using rule-based only")
            
            # Always combine results (AI gets priority if available)
            final_result = self._combine_categorization_results(rule_based_result, ai_result)
            
            logger.info(f"Final categorization: {final_result['category']} (confidence: {final_result['confidence']}, method: {final_result['method']})")
            return final_result
            
        except Exception as e:
            logger.error(f"Expense categorization failed: {str(e)}")
            return {
                'category': 'other',
                'category_name': 'Other',
                'confidence': 0.1,
                'method': 'fallback',
                'reasoning': f"Categorization failed: {str(e)}"
            }

    def _rule_based_categorization(self, description: str, merchant_name: str = None) -> Dict[str, Any]:
        """Rule-based categorization using keywords and merchant patterns"""
        description_lower = description.lower() if description else ""
        merchant_lower = merchant_name.lower() if merchant_name else ""
        
        category_scores = {}
        
        # Score based on keywords in description
        for category_id, category_info in self.categories.items():
            score = 0
            keyword_matches = []
            
            # Check description keywords
            for keyword in category_info['keywords']:
                if keyword in description_lower:
                    score += 1
                    keyword_matches.append(keyword)
            
            # Check merchant patterns
            for merchant_pattern in category_info['merchants']:
                if merchant_pattern in merchant_lower:
                    score += 2  # Merchant matches are weighted higher
                    keyword_matches.append(f"merchant:{merchant_pattern}")
            
            if score > 0:
                category_scores[category_id] = {
                    'score': score,
                    'matches': keyword_matches
                }
        
        # Find best category
        if category_scores:
            best_category = max(category_scores.keys(), key=lambda k: category_scores[k]['score'])
            best_score = category_scores[best_category]['score']
            
            # Calculate confidence based on score and number of categories matched
            max_possible_score = len(self.categories[best_category]['keywords']) + len(self.categories[best_category]['merchants']) * 2
            
            # Base confidence calculation
            if max_possible_score > 0:
                confidence = min(best_score / max_possible_score, 1.0)
            else:
                confidence = 0.5
            
            # Boost confidence for merchant matches (they are more reliable)
            merchant_matches = [m for m in category_scores[best_category]['matches'] if m.startswith('merchant:')]
            if merchant_matches:
                confidence = min(confidence + 0.3, 1.0)  # Boost by 30% for merchant match
            
            # Boost confidence if only one category matched
            if len(category_scores) == 1:
                confidence = min(confidence * 1.2, 1.0)
            
            # Ensure minimum confidence for good matches
            if best_score >= 2:  # At least one merchant match or two keyword matches
                confidence = max(confidence, 0.7)
            
            return {
                'category': best_category,
                'category_name': self.categories[best_category]['name'],
                'confidence': confidence,
                'method': 'rule_based',
                'reasoning': f"Matched keywords/merchants: {category_scores[best_category]['matches']}"
            }
        
        # Default to 'other' if no matches
        return {
            'category': 'other',
            'category_name': 'Other',
            'confidence': 0.1,
            'method': 'rule_based',
            'reasoning': "No keyword or merchant matches found"
        }

    async def _ai_categorization(self, description: str, merchant_name: str = None, amount: float = None) -> Dict[str, Any]:
        """AI-powered categorization using Ollama Qwen2.5:3B"""
        try:
            # Prepare context for AI
            context_parts = []
            if description:
                context_parts.append(f"Description: {description}")
            if merchant_name:
                context_parts.append(f"Merchant: {merchant_name}")
            if amount:
                context_parts.append(f"Amount: {amount} TRY")
            
            context = "\n".join(context_parts)
            
            # Create improved prompt for Qwen2.5:3B
            categories_list = "\n".join([f"- {cat_id}: {cat_info['name']}" for cat_id, cat_info in self.categories.items()])
            
            prompt = f"""You are an expense categorization expert. Categorize the following expense into one of these categories:

CATEGORIES:
{categories_list}

EXPENSE INFORMATION:
{context}

IMPORTANT RULES:
1. Respond ONLY in valid JSON format
2. Do not provide any explanation outside JSON
3. Select category IDs from the list above
4. Confidence score must be between 0.0 and 1.0
5. You can understand both Turkish and English inputs

REQUIRED JSON FORMAT:
{{"category": "category_id", "confidence": 0.85, "reasoning": "brief explanation"}}

Now categorize:"""

            # Call Ollama API with optimized settings for Qwen2.5:3B
            response = self.client.chat(
                model=self.model_name,
                messages=[
                    {
                        'role': 'system',
                        'content': 'You are an expense categorization expert. You respond only in valid JSON format.'
                    },
                    {
                        'role': 'user',
                        'content': prompt
                    }
                ],
                format="json",  # Force JSON format
                options={
                    'temperature': 0.1,  # Very low temperature for consistent results
                    'top_p': 0.8,
                    'num_predict': 120,  # Optimized for Qwen2.5
                    'stop': ['\n\n', '```', 'Explanation:']  # Stop tokens
                }
            )
            
            # Parse AI response
            ai_response = response['message']['content'].strip()
            
            # Try to extract JSON from response
            try:
                # Clean response first
                cleaned_response = ai_response.strip()
                if cleaned_response.startswith('Response:'):
                    cleaned_response = cleaned_response[9:].strip()
                
                # Find JSON in response
                json_start = cleaned_response.find('{')
                json_end = cleaned_response.find('}') + 1  # Use first closing brace
                
                if json_start >= 0 and json_end > json_start:
                    json_str = cleaned_response[json_start:json_end]
                    ai_result = json.loads(json_str)
                    
                    # Validate AI result
                    category = ai_result.get('category', 'other')
                    if category not in self.categories:
                        category = 'other'
                    
                    confidence = float(ai_result.get('confidence', 0.5))
                    confidence = max(0.0, min(1.0, confidence))  # Clamp between 0 and 1
                    
                    return {
                        'category': category,
                        'category_name': self.categories[category]['name'],
                        'confidence': confidence,
                        'method': 'ai',
                        'reasoning': ai_result.get('reasoning', 'AI categorization')
                    }
                else:
                    raise ValueError("No valid JSON found in AI response")
                    
            except (json.JSONDecodeError, ValueError) as e:
                logger.warning(f"Failed to parse AI response: {ai_response}. Error: {str(e)}")
                
                # Fallback: try to extract category name from response
                for category_id, category_info in self.categories.items():
                    if category_id in ai_response.lower() or category_info['name'].lower() in ai_response.lower():
                        return {
                            'category': category_id,
                            'category_name': category_info['name'],
                            'confidence': 0.6,
                            'method': 'ai_fallback',
                            'reasoning': 'Extracted from AI response text'
                        }
                
                # Ultimate fallback
                return {
                    'category': 'other',
                    'category_name': 'Other',
                    'confidence': 0.3,
                    'method': 'ai_fallback',
                    'reasoning': 'Could not parse AI response'
                }
                
        except Exception as e:
            logger.error(f"AI categorization error: {str(e)}")
            raise

    def _combine_categorization_results(self, rule_result: Dict[str, Any], ai_result: Optional[Dict[str, Any]]) -> Dict[str, Any]:
        """Combine rule-based and AI categorization results with AI priority"""
        if not ai_result:
            rule_result['method'] = 'rule_based_only'
            return rule_result
        
        # If both methods agree, boost confidence significantly
        if rule_result['category'] == ai_result['category']:
            # Give more weight to AI when they agree
            combined_confidence = min((ai_result['confidence'] * 0.7 + rule_result['confidence'] * 0.3) * 1.2, 1.0)
            return {
                'category': ai_result['category'],
                'category_name': ai_result['category_name'],
                'confidence': combined_confidence,
                'method': 'ai_and_rule_agree',
                'reasoning': f"AI: {ai_result['reasoning']}; Rule-based also agrees: {rule_result['reasoning']}"
            }
        
        # If they disagree, prioritize AI unless it has very low confidence
        if ai_result['confidence'] >= 0.3:  # Lower threshold to prefer AI
            ai_result['method'] = 'ai_preferred'
            ai_result['reasoning'] = f"AI: {ai_result['reasoning']} (Rule-based suggested: {rule_result['category']})"
            return ai_result
        else:
            # Only use rule-based if AI has very low confidence
            rule_result['method'] = 'rule_preferred_low_ai_confidence'
            rule_result['reasoning'] = f"Rule-based: {rule_result['reasoning']} (AI had low confidence: {ai_result['confidence']:.2f})"
            return rule_result

    async def categorize_bulk_expenses(self, expenses: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Categorize multiple expenses in bulk
        
        Args:
            expenses: List of expense dictionaries with 'description', 'merchant_name', 'amount'
            
        Returns:
            List of categorization results
        """
        results = []
        
        for i, expense in enumerate(expenses):
            try:
                description = expense.get('description', '')
                merchant_name = expense.get('merchant_name')
                amount = expense.get('amount')
                
                result = await self.categorize_expense(description, merchant_name, amount)
                results.append(result)
                
                # Add small delay to avoid overwhelming the AI model
                if i % 5 == 0 and i > 0:
                    await asyncio.sleep(0.1)
                    
            except Exception as e:
                logger.error(f"Failed to categorize expense {i}: {str(e)}")
                results.append({
                    'category': 'other',
                    'category_name': 'Other',
                    'confidence': 0.1,
                    'method': 'error',
                    'reasoning': f"Categorization failed: {str(e)}"
                })
        
        return results

    def get_category_suggestions(self, partial_description: str) -> List[Dict[str, Any]]:
        """
        Get category suggestions based on partial description
        
        Args:
            partial_description: Partial expense description
            
        Returns:
            List of suggested categories with confidence scores
        """
        if not partial_description or len(partial_description) < 2:
            return []
        
        description_lower = partial_description.lower()
        suggestions = []
        
        for category_id, category_info in self.categories.items():
            if category_id == 'other':
                continue
                
            score = 0
            matched_keywords = []
            
            # Check keyword matches
            for keyword in category_info['keywords']:
                if keyword in description_lower:
                    score += 1
                    matched_keywords.append(keyword)
                elif description_lower in keyword:
                    score += 0.5
                    matched_keywords.append(keyword)
            
            if score > 0:
                suggestions.append({
                    'category': category_id,
                    'category_name': category_info['name'],
                    'confidence': min(score / len(category_info['keywords']), 1.0) if category_info['keywords'] else 0.5,
                    'matched_keywords': matched_keywords
                })
        
        # Sort by confidence
        suggestions.sort(key=lambda x: x['confidence'], reverse=True)
        
        return suggestions[:5]  # Return top 5 suggestions

# Create singleton instance
ai_categorizer = AICategorizer() 