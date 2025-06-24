import logging
import time
import json
from typing import Optional, List, Dict, Any, Tuple
from uuid import UUID, uuid4
from datetime import datetime, timedelta
from supabase import Client

from app.schemas.merchant import (
    WebhookTransactionData,
    WebhookProcessingResult,
    WebhookLogResponse,
    CustomerMatchResult,
    WebhookStatus
)
from app.services.merchant_service import CustomerMatchingService
from app.services.data_processor import DataProcessor
from app.services.qr_generator import QRGenerator
from app.services.loyalty_service import LoyaltyService

logger = logging.getLogger(__name__)


class WebhookService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client
        self.customer_matcher = CustomerMatchingService(supabase_client)
        self.data_processor = DataProcessor()
        self.qr_generator = QRGenerator()
        self.loyalty_service = LoyaltyService()

    async def process_merchant_transaction(
        self, 
        merchant_id: UUID, 
        transaction_data: WebhookTransactionData,
        test_mode: bool = False
    ) -> WebhookProcessingResult:
        """Process incoming merchant transaction webhook"""
        start_time = time.time()
        
        try:
            # Log webhook attempt
            log_id = await self._log_webhook_attempt(
                merchant_id, 
                transaction_data.transaction_id, 
                transaction_data.model_dump()
            )
            
            # Get merchant info once at the beginning
            merchant_result = self.supabase.table("merchants").select("name").eq("id", str(merchant_id)).execute()
            merchant_name = merchant_result.data[0]["name"] if merchant_result.data else "Unknown Merchant"
            
            # Check if customer information was provided to attempt a match
            customer_info_provided = (
                transaction_data.customer_info and
                any([
                    transaction_data.customer_info.phone,
                    transaction_data.customer_info.email,
                    transaction_data.customer_info.card_hash
                ])
            )
            
            if customer_info_provided:
                # SCENARIO A: Identified customer flow. Try to match the customer.
                logger.info(f"Customer info provided for tx {transaction_data.transaction_id}, attempting match.")
                match_result = await self.customer_matcher.match_customer(transaction_data.customer_info)
                
                if not match_result.matched:
                    # Customer info provided but no match found - create public receipt
                    logger.info(f"Customer info provided but no match found for tx {transaction_data.transaction_id}. Creating public receipt.")
                    receipt_id = await self._create_public_receipt_from_webhook(
                        merchant_id,
                        merchant_name,
                        transaction_data,
                        test_mode
                    )
                    
                    if not receipt_id:
                        error_msg = "Customer not found and failed to create public receipt record"
                        await self._update_webhook_log(log_id, WebhookStatus.FAILED, error_message=error_msg)
                        return WebhookProcessingResult(
                            success=False,
                            message=error_msg,
                            transaction_id=transaction_data.transaction_id,
                            processing_time_ms=int((time.time() - start_time) * 1000),
                            errors=[error_msg]
                        )
                    
                    # Update webhook log as successful for public receipt
                    processing_time = int((time.time() - start_time) * 1000)
                    public_url = f"https://ecotrack.com/api/v1/receipts/public/{receipt_id}"
                    
                    # Update receipt with the generated QR data (URL)
                    self.supabase.table("receipts").update({"raw_qr_data": public_url}).eq("id", str(receipt_id)).execute()
                    
                    await self._update_webhook_log(
                        log_id, 
                        WebhookStatus.SUCCESS, 
                        processing_time_ms=processing_time
                    )
                    
                    logger.info(f"Successfully created public receipt {receipt_id} for unmatched customer in transaction {transaction_data.transaction_id}")
                    
                    return WebhookProcessingResult(
                        success=True,
                        message="Customer not found, public receipt created successfully.",
                        transaction_id=transaction_data.transaction_id,
                        matched_user_id=None,  # No user matched
                        created_receipt_id=receipt_id,
                        created_expense_id=None,  # No expense for public receipts
                        processing_time_ms=processing_time,
                        is_public_receipt=True,
                        public_url=public_url
                    )
                
                # Customer matched, proceed to create a private receipt for the user.
                logger.info(f"Customer matched for user {match_result.user_id}. Creating private receipt.")
                receipt_id = await self._create_receipt_from_webhook(
                    match_result.user_id,
                    merchant_id,
                    merchant_name,
                    transaction_data,
                    test_mode
                )
                
                if not receipt_id:
                    error_msg = "Failed to create receipt record"
                    await self._update_webhook_log(log_id, WebhookStatus.FAILED, error_message=error_msg)
                    return WebhookProcessingResult(
                        success=False,
                        message=error_msg,
                        transaction_id=transaction_data.transaction_id,
                        processing_time_ms=int((time.time() - start_time) * 1000),
                        errors=[error_msg]
                    )
                
                # Create expense and expense items for the matched user
                expense_id, loyalty_result = await self._create_expense_from_webhook(
                    match_result.user_id,
                    receipt_id,
                    transaction_data,
                    merchant_name
                )
                
                if not expense_id:
                    # Note: This is a partial failure. Receipt was created but expense failed.
                    error_msg = "Receipt created, but failed to create associated expense record."
                    await self._update_webhook_log(log_id, WebhookStatus.FAILED, error_message=error_msg)
                    return WebhookProcessingResult(
                        success=False,
                        message=error_msg,
                        transaction_id=transaction_data.transaction_id,
                        created_receipt_id=receipt_id,
                        processing_time_ms=int((time.time() - start_time) * 1000),
                        errors=[error_msg]
                    )
                
                # Note: Automatic payment method storage is disabled
                # Users must manually add payment methods through the app
                
                # Update webhook log as successful
                processing_time = int((time.time() - start_time) * 1000)
                await self._update_webhook_log(
                    log_id, 
                    WebhookStatus.SUCCESS, 
                    processing_time_ms=processing_time
                )
                
                logger.info(f"Successfully processed webhook transaction {transaction_data.transaction_id} for user {match_result.user_id}")
                
                # Extract loyalty information for response
                loyalty_points_awarded = None
                loyalty_transaction_id = None
                if loyalty_result and loyalty_result.get("success"):
                    loyalty_points_awarded = loyalty_result.get("points_awarded")
                    loyalty_transaction_id = loyalty_result.get("transaction_id")
                    if loyalty_transaction_id:
                        try:
                            loyalty_transaction_id = UUID(loyalty_transaction_id)
                        except (ValueError, TypeError):
                            loyalty_transaction_id = None
                
                return WebhookProcessingResult(
                    success=True,
                    message="Transaction processed successfully and receipt created for user.",
                    transaction_id=transaction_data.transaction_id,
                    matched_user_id=match_result.user_id,
                    created_receipt_id=receipt_id,
                    created_expense_id=expense_id,
                    processing_time_ms=processing_time,
                    loyalty_points_awarded=loyalty_points_awarded,
                    loyalty_transaction_id=loyalty_transaction_id
                )
            
            else:
                # SCENARIO B: No customer info. Create a public, claimable receipt.
                logger.info(f"No customer info for tx {transaction_data.transaction_id}. Creating public receipt.")
                receipt_id = await self._create_public_receipt_from_webhook(
                    merchant_id,
                    merchant_name,
                    transaction_data,
                    test_mode
                )
                
                if not receipt_id:
                    error_msg = "Failed to create public receipt record"
                    await self._update_webhook_log(log_id, WebhookStatus.FAILED, error_message=error_msg)
                    return WebhookProcessingResult(
                        success=False,
                        message=error_msg,
                        transaction_id=transaction_data.transaction_id,
                        processing_time_ms=int((time.time() - start_time) * 1000),
                        errors=[error_msg]
                    )
                
                # Update webhook log as successful for public receipt
                processing_time = int((time.time() - start_time) * 1000)
                public_url = f"https://ecotrack.com/api/v1/receipts/public/{receipt_id}"
                
                # Update receipt with the generated QR data (URL)
                self.supabase.table("receipts").update({"raw_qr_data": public_url}).eq("id", str(receipt_id)).execute()
                
                await self._update_webhook_log(
                    log_id, 
                    WebhookStatus.SUCCESS, 
                    processing_time_ms=processing_time
                )
                
                logger.info(f"Successfully created public receipt {receipt_id} for transaction {transaction_data.transaction_id}")
                
                return WebhookProcessingResult(
                    success=True,
                    message="Public receipt created successfully.",
                    transaction_id=transaction_data.transaction_id,
                    matched_user_id=None,  # No user matched
                    created_receipt_id=receipt_id,
                    created_expense_id=None,  # No expense for public receipts
                    processing_time_ms=processing_time,
                    is_public_receipt=True,
                    public_url=public_url
                )
            
        except Exception as e:
            error_msg = f"Error processing webhook: {str(e)}"
            logger.error(error_msg, exc_info=True)
            
            processing_time = int((time.time() - start_time) * 1000)
            
            # Try to update log if we have log_id
            if 'log_id' in locals():
                try:
                    await self._update_webhook_log(
                        log_id, 
                        WebhookStatus.FAILED, 
                        error_message=error_msg,
                        processing_time_ms=processing_time
                    )
                except:
                    pass  # Don't fail the main error handling
            
            return WebhookProcessingResult(
                success=False,
                message=error_msg,
                transaction_id=transaction_data.transaction_id if transaction_data else "unknown",
                processing_time_ms=processing_time,
                errors=[error_msg]
            )

    async def _create_receipt_from_webhook(
        self, 
        user_id: UUID, 
        merchant_id: UUID, 
        merchant_name: str,
        transaction_data: WebhookTransactionData,
        test_mode: bool = False
    ) -> Optional[UUID]:
        """Create receipt record from webhook transaction data"""
        try:
            
            # Prepare receipt data
            receipt_data = {
                "user_id": str(user_id),
                "merchant_id": str(merchant_id),
                "raw_qr_data": None,  # No QR data for webhook transactions
                "merchant_name": merchant_name,
                "transaction_date": transaction_data.transaction_date.isoformat(),
                "total_amount": transaction_data.total_amount,
                "currency": transaction_data.currency,
                "source": "webhook" if not test_mode else "webhook_test",
                "parsed_receipt_data": {
                    "merchant_transaction_id": transaction_data.merchant_transaction_id,
                    "receipt_number": transaction_data.receipt_number,
                    "cashier_id": transaction_data.cashier_id,
                    "store_location": transaction_data.store_location,
                    "payment_method": transaction_data.payment_method,
                    "items": [item.model_dump() for item in transaction_data.items],
                    "additional_data": transaction_data.additional_data
                }
            }
            
            result = self.supabase.table("receipts").insert(receipt_data).execute()
            
            if result.data:
                return UUID(result.data[0]["id"])
            
            return None
            
        except Exception as e:
            logger.error(f"Error creating receipt from webhook: {str(e)}")
            return None

    async def _create_public_receipt_from_webhook(
        self, 
        merchant_id: UUID, 
        merchant_name: str,
        transaction_data: WebhookTransactionData,
        test_mode: bool = False
    ) -> Optional[UUID]:
        """Create public receipt record for unregistered customers - viewable on web"""
        try:
            
            # Calculate expiration time (48 hours from now)
            expires_at = (datetime.now() + timedelta(hours=48)).isoformat()
            
            # Prepare public receipt data (no user_id, no customer_info needed)
            receipt_data = {
                "user_id": None,  # Public receipt - no user assigned
                "merchant_id": str(merchant_id),
                "raw_qr_data": None,  # No QR data for webhook transactions
                "merchant_name": merchant_name,
                "transaction_date": transaction_data.transaction_date.isoformat(),
                "total_amount": transaction_data.total_amount,
                "currency": transaction_data.currency,
                "source": "webhook_public" if not test_mode else "webhook_test_public",
                "is_public": True,  # Mark as public receipt for web viewing
                "expires_at": expires_at,  # Set expiration time for cleanup
                "parsed_receipt_data": {
                    "merchant_transaction_id": transaction_data.merchant_transaction_id,
                    "receipt_number": transaction_data.receipt_number,
                    "cashier_id": transaction_data.cashier_id,
                    "store_location": transaction_data.store_location,
                    "payment_method": transaction_data.payment_method,
                    "items": [item.model_dump() for item in transaction_data.items],
                    "additional_data": transaction_data.additional_data
                }
            }
            
            result = self.supabase.table("receipts").insert(receipt_data).execute()
            
            if result.data:
                receipt_id = UUID(result.data[0]["id"])
                
                # Create expense and expense items for public receipt (without user_id initially)
                # This will be claimed later by a user
                try:
                    expense_data = {
                        "receipt_id": str(receipt_id),
                        "user_id": None,  # Will be assigned when receipt is claimed
                        "total_amount": transaction_data.total_amount,
                        "expense_date": transaction_data.transaction_date.isoformat(),
                        "notes": f"Auto-created from merchant webhook (public) - Transaction ID: {transaction_data.transaction_id}"
                    }
                    
                    expense_result = self.supabase.table("expenses").insert(expense_data).execute()
                    
                    if expense_result.data:
                        expense_id = UUID(expense_result.data[0]["id"])
                        
                        # Create expense items for public receipt
                        for item in transaction_data.items:
                            item_data = {
                                "expense_id": str(expense_id),
                                "user_id": None,  # Will be assigned when receipt is claimed
                                "category_id": None,  # Will be categorized when claimed
                                "description": item.description,
                                "amount": item.total_price,
                                "quantity": item.quantity,
                                "unit_price": item.unit_price,
                                "kdv_rate": 20.0,
                                "notes": f"Category: {item.category}" if item.category else None
                            }
                            
                            self.supabase.table("expense_items").insert(item_data).execute()
                        
                        logger.info(f"Created public expense {expense_id} for receipt {receipt_id}")
                    else:
                        logger.warning(f"Failed to create expense for public receipt {receipt_id}")
                        
                except Exception as e:
                    logger.error(f"Error creating expense for public receipt: {str(e)}")
                    # Don't fail receipt creation if expense creation fails
                
                return receipt_id
            
            return None
            
        except Exception as e:
            logger.error(f"Error creating public receipt from webhook: {str(e)}")
            return None

    async def _create_expense_from_webhook(
        self, 
        user_id: UUID, 
        receipt_id: UUID, 
        transaction_data: WebhookTransactionData,
        merchant_name: str = None
    ) -> Tuple[Optional[UUID], Optional[Dict[str, Any]]]:
        """Create expense and expense items from webhook transaction data"""
        try:
            # Create main expense record
            expense_data = {
                "receipt_id": str(receipt_id),
                "user_id": str(user_id),
                "total_amount": transaction_data.total_amount,
                "expense_date": transaction_data.transaction_date.isoformat(),
                "notes": f"Auto-created from merchant webhook - Transaction ID: {transaction_data.transaction_id}"
            }
            
            expense_result = self.supabase.table("expenses").insert(expense_data).execute()
            
            if not expense_result.data:
                return None
            
            expense_id = UUID(expense_result.data[0]["id"])
            
            # Create expense items and track primary category for loyalty points
            primary_category = None
            for item in transaction_data.items:
                # Try to categorize the item using AI
                category_id = None
                category_name = None
                try:
                    categorization_result = await self.data_processor.ai_categorizer.categorize_expense(
                        description=item.description,
                        merchant_name=merchant_name,
                        amount=item.total_price
                    )
                    
                    # Only assign category if confidence is above threshold (0.3)
                    if categorization_result.get("confidence", 0) > 0.3:
                        # Get category_id from categories table using the category name
                        category_name = categorization_result.get("category_name")
                        if category_name:
                            category_result = self.supabase.table("categories").select("id").eq("name", category_name).execute()
                            if category_result.data:
                                category_id = category_result.data[0]["id"]
                                # Set primary category as the first categorized item or highest value item
                                if not primary_category:
                                    primary_category = category_name
                except Exception as e:
                    logger.warning(f"Failed to categorize item '{item.description}': {str(e)}")
                
                # Create expense item
                item_data = {
                    "expense_id": str(expense_id),
                    "user_id": str(user_id),
                    "category_id": category_id,
                    "description": item.description,
                    "amount": item.total_price,
                    "quantity": item.quantity,
                    "unit_price": item.unit_price,
                    "kdv_rate": 20.0,  # Default KDV rate, could be enhanced with item-specific logic
                    "notes": f"Category: {item.category}" if item.category else None
                }
                
                self.supabase.table("expense_items").insert(item_data).execute()
            
            # Award loyalty points for the expense
            loyalty_result = None
            try:
                loyalty_result = await self.loyalty_service.award_points_for_expense(
                    user_id=str(user_id),
                    expense_id=str(expense_id),
                    amount=transaction_data.total_amount,
                    category=primary_category,
                    merchant_name=merchant_name
                )
                
                if loyalty_result["success"]:
                    logger.info(f"Webhook loyalty points awarded: {loyalty_result['points_awarded']} points for user {user_id}, expense {expense_id}")
                else:
                    logger.warning(f"Failed to award loyalty points for webhook expense {expense_id}")
                    
            except Exception as loyalty_error:
                # Don't fail the expense creation if loyalty points fail
                logger.error(f"Loyalty points error in webhook for expense {expense_id}: {str(loyalty_error)}")
            
            return expense_id, loyalty_result
            
        except Exception as e:
            logger.error(f"Error creating expense from webhook: {str(e)}")
            return None, None

    async def _log_webhook_attempt(
        self, 
        merchant_id: UUID, 
        transaction_id: str, 
        payload: Dict[str, Any]
    ) -> UUID:
        """Log webhook processing attempt"""
        try:
            # Convert datetime objects to ISO strings for JSON serialization
            serializable_payload = json.loads(json.dumps(payload, default=str))
            
            log_data = {
                "merchant_id": str(merchant_id),
                "transaction_id": transaction_id,
                "payload": serializable_payload,
                "status": WebhookStatus.PENDING.value,
                "retry_count": 0
            }
            
            result = self.supabase.table("webhook_logs").insert(log_data).execute()
            
            if result.data:
                return UUID(result.data[0]["id"])
            
            # Fallback to generate UUID if insert fails
            return uuid4()
            
        except Exception as e:
            logger.error(f"Error logging webhook attempt: {str(e)}")
            return uuid4()

    async def _update_webhook_log(
        self, 
        log_id: UUID, 
        status: WebhookStatus, 
        response_code: Optional[int] = None,
        error_message: Optional[str] = None,
        processing_time_ms: Optional[int] = None
    ):
        """Update webhook log with processing result"""
        try:
            update_data = {
                "status": status.value
            }
            
            if response_code is not None:
                update_data["response_code"] = response_code
            if error_message is not None:
                update_data["error_message"] = error_message
            if processing_time_ms is not None:
                update_data["processing_time_ms"] = processing_time_ms
            
            self.supabase.table("webhook_logs").update(update_data).eq("id", str(log_id)).execute()
            
        except Exception as e:
            logger.error(f"Error updating webhook log: {str(e)}")

    async def get_webhook_logs(
        self, 
        merchant_id: UUID, 
        page: int = 1, 
        size: int = 20,
        status: Optional[WebhookStatus] = None
    ) -> Tuple[List[WebhookLogResponse], int]:
        """Get webhook logs for a merchant"""
        try:
            query = self.supabase.table("webhook_logs").select("*", count="exact").eq("merchant_id", str(merchant_id))
            
            if status:
                query = query.eq("status", status.value)
            
            # Apply pagination
            offset = (page - 1) * size
            query = query.range(offset, offset + size - 1).order("created_at", desc=True)
            
            result = query.execute()
            
            logs = [WebhookLogResponse(**log) for log in result.data]
            total = result.count if result.count else 0
            
            return logs, total
            
        except Exception as e:
            logger.error(f"Error fetching webhook logs: {str(e)}")
            return [], 0

    async def retry_failed_webhook(self, log_id: UUID) -> bool:
        """Retry a failed webhook processing"""
        try:
            # Get the webhook log
            log_result = self.supabase.table("webhook_logs").select("*").eq("id", str(log_id)).execute()
            
            if not log_result.data:
                return False
            
            log_data = log_result.data[0]
            
            # Check if it's eligible for retry (failed status and retry count < max)
            if log_data["status"] != WebhookStatus.FAILED.value or log_data["retry_count"] >= 3:
                return False
            
            # Update retry count and status
            self.supabase.table("webhook_logs").update({
                "status": WebhookStatus.RETRY.value,
                "retry_count": log_data["retry_count"] + 1
            }).eq("id", str(log_id)).execute()
            
            # Reconstruct transaction data and retry processing
            transaction_data = WebhookTransactionData(**log_data["payload"])
            merchant_id = UUID(log_data["merchant_id"])
            
            result = await self.process_merchant_transaction(merchant_id, transaction_data)
            
            return result.success
            
        except Exception as e:
            logger.error(f"Error retrying webhook {log_id}: {str(e)}")
            return False

 