import logging
import time
import json
from typing import Optional, List, Dict, Any, Tuple
from uuid import UUID, uuid4
from datetime import datetime
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

logger = logging.getLogger(__name__)


class WebhookService:
    def __init__(self, supabase_client: Client):
        self.supabase = supabase_client
        self.customer_matcher = CustomerMatchingService(supabase_client)
        self.data_processor = DataProcessor()
        self.qr_generator = QRGenerator()

    async def process_merchant_transaction(
        self, 
        merchant_id: UUID, 
        transaction_data: WebhookTransactionData,
        test_mode: bool = False
    ) -> WebhookProcessingResult:
        """Process incoming merchant transaction webhook"""
        start_time = time.time()
        errors = []
        
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
            
            # Step 1: Match customer
            match_result = await self.customer_matcher.match_customer(transaction_data.customer_info)
            
            if not match_result.matched:
                # Create public receipt for unregistered customers
                logger.info(f"Customer not found for transaction {transaction_data.transaction_id}, creating public receipt")
                
                # Create public receipt (no user_id, no expense)
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
                await self._update_webhook_log(
                    log_id, 
                    WebhookStatus.SUCCESS, 
                    processing_time_ms=processing_time
                )
                
                # Generate QR code for public receipt
                qr_code = self.qr_generator.generate_receipt_qr(
                    receipt_id=str(receipt_id),
                    merchant_name=merchant_name,
                    total_amount=transaction_data.total_amount,
                    currency=transaction_data.currency,
                    transaction_date=transaction_data.transaction_date
                )
                
                logger.info(f"Successfully created public receipt {receipt_id} for transaction {transaction_data.transaction_id}")
                
                return WebhookProcessingResult(
                    success=True,
                    message=f"Public receipt created successfully - viewable at: https://ecotrack.com/receipt/{receipt_id}",
                    transaction_id=transaction_data.transaction_id,
                    matched_user_id=None,  # No user matched
                    created_receipt_id=receipt_id,
                    created_expense_id=None,  # No expense for public receipts
                    processing_time_ms=processing_time,
                    is_public_receipt=True,
                    qr_code=qr_code,
                    public_url=f"https://ecotrack.com/receipt/{receipt_id}"
                )
            
            # Step 2: Create receipt record for registered user
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
            
            # Step 3: Create expense and expense items
            expense_id = await self._create_expense_from_webhook(
                match_result.user_id,
                receipt_id,
                transaction_data
            )
            
            if not expense_id:
                error_msg = "Failed to create expense record"
                await self._update_webhook_log(log_id, WebhookStatus.FAILED, error_message=error_msg)
                return WebhookProcessingResult(
                    success=False,
                    message=error_msg,
                    transaction_id=transaction_data.transaction_id,
                    processing_time_ms=int((time.time() - start_time) * 1000),
                    errors=[error_msg]
                )
            
            # Step 4: Store payment method if provided
            if transaction_data.customer_info.card_hash and transaction_data.customer_info.card_last_four:
                await self.customer_matcher.store_payment_method(
                    match_result.user_id,
                    transaction_data.customer_info.card_hash,
                    transaction_data.customer_info.card_last_four,
                    transaction_data.customer_info.card_type
                )
            
            # Step 5: Generate QR code for user receipt
            qr_code = self.qr_generator.generate_receipt_qr(
                receipt_id=str(receipt_id),
                merchant_name=merchant_name,
                total_amount=transaction_data.total_amount,
                currency=transaction_data.currency,
                transaction_date=transaction_data.transaction_date
            )
            
            # Step 6: Update webhook log as successful
            processing_time = int((time.time() - start_time) * 1000)
            await self._update_webhook_log(
                log_id, 
                WebhookStatus.SUCCESS, 
                processing_time_ms=processing_time
            )
            
            logger.info(f"Successfully processed webhook transaction {transaction_data.transaction_id} for user {match_result.user_id}")
            
            return WebhookProcessingResult(
                success=True,
                message="Transaction processed successfully",
                transaction_id=transaction_data.transaction_id,
                matched_user_id=match_result.user_id,
                created_receipt_id=receipt_id,
                created_expense_id=expense_id,
                processing_time_ms=processing_time,
                qr_code=qr_code
            )
            
        except Exception as e:
            error_msg = f"Error processing webhook: {str(e)}"
            logger.error(error_msg)
            
            processing_time = int((time.time() - start_time) * 1000)
            
            # Try to update log if we have log_id
            try:
                if 'log_id' in locals():
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
                transaction_id=transaction_data.transaction_id,
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
            logger.error(f"Error creating public receipt from webhook: {str(e)}")
            return None

    async def _create_expense_from_webhook(
        self, 
        user_id: UUID, 
        receipt_id: UUID, 
        transaction_data: WebhookTransactionData
    ) -> Optional[UUID]:
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
            
            # Create expense items
            for item in transaction_data.items:
                # Try to categorize the item using AI
                category_id = None
                try:
                    category_suggestion = await self.data_processor.ai_categorizer.suggest_category(
                        item.description, str(user_id)
                    )
                    if category_suggestion and category_suggestion.suggestions:
                        # Use the first (highest confidence) suggestion
                        category_name = category_suggestion.suggestions[0].category_name
                        category_result = self.supabase.table("categories").select("id").eq("name", category_name).execute()
                        if category_result.data:
                            category_id = category_result.data[0]["id"]
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
            
            return expense_id
            
        except Exception as e:
            logger.error(f"Error creating expense from webhook: {str(e)}")
            return None

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

 