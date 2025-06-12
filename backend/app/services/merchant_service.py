import secrets
import hashlib
import logging
from typing import Optional, List, Dict, Any, Tuple
from uuid import UUID
from datetime import datetime, timedelta
from supabase import Client

from app.schemas.merchant import (
    MerchantCreate,
    MerchantUpdate,
    MerchantResponse,
    CustomerMatchResult,
    WebhookTransactionData,
    WebhookProcessingResult
)

logger = logging.getLogger(__name__)


class MerchantService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    def generate_api_key(self, merchant_name: str) -> str:
        """Generate a secure API key for merchant"""
        # Create a unique identifier combining timestamp and random data
        timestamp = str(int(datetime.now().timestamp()))
        random_part = secrets.token_urlsafe(32)
        
        # Create a hash of merchant name + timestamp + random data
        combined = f"{merchant_name}_{timestamp}_{random_part}"
        api_key = hashlib.sha256(combined.encode()).hexdigest()[:32]
        
        # Add prefix for identification
        return f"mk_{api_key}"

    async def create_merchant(self, merchant_data: MerchantCreate) -> MerchantResponse:
        """Create a new merchant partner"""
        try:
            # Generate API key
            api_key = self.generate_api_key(merchant_data.name)
            
            # Prepare data for insertion
            insert_data = {
                "name": merchant_data.name,
                "business_type": merchant_data.business_type.value if merchant_data.business_type else None,
                "api_key": api_key,
                "webhook_url": merchant_data.webhook_url,
                "contact_email": merchant_data.contact_email,
                "contact_phone": merchant_data.contact_phone,
                "address": merchant_data.address,
                "tax_number": merchant_data.tax_number,
                "settings": merchant_data.settings or {},
                "is_active": True
            }
            
            # Insert merchant
            result = self.supabase.table("merchants").insert(insert_data).execute()
            
            if not result.data:
                raise Exception("Failed to create merchant")
            
            merchant_record = result.data[0]
            logger.info(f"Created merchant: {merchant_record['id']} - {merchant_record['name']}")
            
            return MerchantResponse(**merchant_record)
            
        except Exception as e:
            logger.error(f"Error creating merchant: {str(e)}")
            raise

    async def get_merchant_by_id(self, merchant_id: UUID) -> Optional[MerchantResponse]:
        """Get merchant by ID"""
        try:
            result = self.supabase.table("merchants").select("*").eq("id", str(merchant_id)).execute()
            
            if not result.data:
                return None
            
            return MerchantResponse(**result.data[0])
            
        except Exception as e:
            logger.error(f"Error fetching merchant {merchant_id}: {str(e)}")
            raise

    async def get_merchant_by_api_key(self, api_key: str) -> Optional[MerchantResponse]:
        """Get merchant by API key"""
        try:
            result = self.supabase.table("merchants").select("*").eq("api_key", api_key).eq("is_active", True).execute()
            
            if not result.data:
                return None
            
            return MerchantResponse(**result.data[0])
            
        except Exception as e:
            logger.error(f"Error fetching merchant by API key: {str(e)}")
            raise

    async def list_merchants(self, page: int = 1, size: int = 20, is_active: Optional[bool] = None) -> Tuple[List[MerchantResponse], int]:
        """List merchants with pagination"""
        try:
            # Build query
            query = self.supabase.table("merchants").select("*", count="exact")
            
            if is_active is not None:
                query = query.eq("is_active", is_active)
            
            # Apply pagination
            offset = (page - 1) * size
            query = query.range(offset, offset + size - 1).order("created_at", desc=True)
            
            result = query.execute()
            
            merchants = [MerchantResponse(**merchant) for merchant in result.data]
            total = result.count if result.count else 0
            
            return merchants, total
            
        except Exception as e:
            logger.error(f"Error listing merchants: {str(e)}")
            raise

    async def update_merchant(self, merchant_id: UUID, merchant_data: MerchantUpdate) -> Optional[MerchantResponse]:
        """Update merchant information"""
        try:
            # Prepare update data (only include non-None values)
            update_data = {}
            
            if merchant_data.name is not None:
                update_data["name"] = merchant_data.name
            if merchant_data.business_type is not None:
                update_data["business_type"] = merchant_data.business_type.value
            if merchant_data.contact_email is not None:
                update_data["contact_email"] = merchant_data.contact_email
            if merchant_data.contact_phone is not None:
                update_data["contact_phone"] = merchant_data.contact_phone
            if merchant_data.address is not None:
                update_data["address"] = merchant_data.address
            if merchant_data.tax_number is not None:
                update_data["tax_number"] = merchant_data.tax_number
            if merchant_data.webhook_url is not None:
                update_data["webhook_url"] = merchant_data.webhook_url
            if merchant_data.is_active is not None:
                update_data["is_active"] = merchant_data.is_active
            if merchant_data.settings is not None:
                update_data["settings"] = merchant_data.settings
            
            if not update_data:
                # No data to update
                return await self.get_merchant_by_id(merchant_id)
            
            update_data["updated_at"] = datetime.now().isoformat()
            
            result = self.supabase.table("merchants").update(update_data).eq("id", str(merchant_id)).execute()
            
            if not result.data:
                return None
            
            logger.info(f"Updated merchant: {merchant_id}")
            return MerchantResponse(**result.data[0])
            
        except Exception as e:
            logger.error(f"Error updating merchant {merchant_id}: {str(e)}")
            raise

    async def deactivate_merchant(self, merchant_id: UUID) -> bool:
        """Deactivate merchant partnership"""
        try:
            result = self.supabase.table("merchants").update({
                "is_active": False,
                "updated_at": datetime.now().isoformat()
            }).eq("id", str(merchant_id)).execute()
            
            success = bool(result.data)
            if success:
                logger.info(f"Deactivated merchant: {merchant_id}")
            
            return success
            
        except Exception as e:
            logger.error(f"Error deactivating merchant {merchant_id}: {str(e)}")
            raise

    async def validate_api_key(self, api_key: str) -> bool:
        """Validate merchant API key"""
        try:
            merchant = await self.get_merchant_by_api_key(api_key)
            return merchant is not None and merchant.is_active
            
        except Exception as e:
            logger.error(f"Error validating API key: {str(e)}")
            return False

    async def regenerate_api_key(self, merchant_id: UUID) -> Optional[str]:
        """Regenerate API key for merchant"""
        try:
            # Get merchant first
            merchant = await self.get_merchant_by_id(merchant_id)
            if not merchant:
                return None
            
            # Generate new API key
            new_api_key = self.generate_api_key(merchant.name)
            
            # Update merchant with new API key
            result = self.supabase.table("merchants").update({
                "api_key": new_api_key,
                "updated_at": datetime.now().isoformat()
            }).eq("id", str(merchant_id)).execute()
            
            if not result.data:
                return None
            
            logger.info(f"Regenerated API key for merchant: {merchant_id}")
            return new_api_key
            
        except Exception as e:
            logger.error(f"Error regenerating API key for merchant {merchant_id}: {str(e)}")
            raise


class CustomerMatchingService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client

    def hash_card_number(self, card_number: str) -> str:
        """Hash card number for secure storage and matching"""
        # Remove spaces and dashes
        clean_card = card_number.replace(' ', '').replace('-', '')
        # Hash the card number
        return hashlib.sha256(clean_card.encode()).hexdigest()

    async def match_customer(self, customer_info) -> CustomerMatchResult:
        """Match customer information with existing users"""
        try:
            matched_user_id = None
            match_method = None
            confidence = 0.0
            
            # Try email matching first (highest confidence)
            if customer_info.email:
                result = self.supabase.table("users").select("id").eq("email", customer_info.email).execute()
                if result.data:
                    matched_user_id = UUID(result.data[0]["id"])
                    match_method = "email"
                    confidence = 1.0
            
            # Try card hash matching if no email match
            if not matched_user_id and customer_info.card_hash:
                result = self.supabase.table("user_payment_methods").select("user_id").eq("card_hash", customer_info.card_hash).eq("is_active", True).execute()
                if result.data:
                    matched_user_id = UUID(result.data[0]["user_id"])
                    match_method = "card_hash"
                    confidence = 0.9
            
            # Try phone matching (lowest confidence due to potential duplicates)
            if not matched_user_id and customer_info.phone:
                # Note: This would require a phone field in users table
                # For now, we'll skip phone matching as it's not in the current schema
                pass
            
            return CustomerMatchResult(
                matched=matched_user_id is not None,
                user_id=matched_user_id,
                match_method=match_method,
                confidence=confidence
            )
            
        except Exception as e:
            logger.error(f"Error matching customer: {str(e)}")
            return CustomerMatchResult(matched=False, confidence=0.0)

    async def store_payment_method(self, user_id: UUID, card_hash: str, card_last_four: str, card_type: Optional[str] = None) -> bool:
        """Store user payment method for future matching"""
        try:
            # Check if payment method already exists
            existing = self.supabase.table("user_payment_methods").select("id").eq("user_id", str(user_id)).eq("card_hash", card_hash).execute()
            
            if existing.data:
                # Payment method already exists
                return True
            
            # Insert new payment method
            insert_data = {
                "user_id": str(user_id),
                "card_hash": card_hash,
                "card_last_four": card_last_four,
                "card_type": card_type,
                "is_primary": False,
                "is_active": True
            }
            
            result = self.supabase.table("user_payment_methods").insert(insert_data).execute()
            
            success = bool(result.data)
            if success:
                logger.info(f"Stored payment method for user: {user_id}")
            
            return success
            
        except Exception as e:
            logger.error(f"Error storing payment method for user {user_id}: {str(e)}")
            return False 