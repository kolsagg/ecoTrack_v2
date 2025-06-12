import pytest
import asyncio
from unittest.mock import Mock, AsyncMock, patch
from uuid import uuid4, UUID
from datetime import datetime, timezone
import hashlib
import secrets

# Import the services we're testing
from app.services.merchant_service import MerchantService, CustomerMatchingService
from app.services.webhook_service import WebhookService
from app.schemas.merchant import (
    MerchantCreate,
    MerchantUpdate,
    MerchantResponse,
    BusinessType,
    WebhookTransactionData,
    CustomerInfo,
    TransactionItem,
    WebhookStatus,
    CustomerMatchResult
)


class TestMerchantService:
    """Test MerchantService functionality"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.mock_supabase = Mock()
        self.merchant_service = MerchantService(self.mock_supabase)
    
    def test_generate_api_key(self):
        """Test API key generation"""
        merchant_name = "Test Merchant"
        api_key = self.merchant_service.generate_api_key(merchant_name)
        
        # Check format
        assert api_key.startswith("mk_")
        assert len(api_key) == 35  # mk_ + 32 chars
        
        # Check uniqueness
        api_key2 = self.merchant_service.generate_api_key(merchant_name)
        assert api_key != api_key2
    
    @pytest.mark.asyncio
    async def test_create_merchant_success(self):
        """Test successful merchant creation"""
        # Mock data
        merchant_data = MerchantCreate(
            name="Test Restaurant",
            business_type=BusinessType.RESTAURANT,
            contact_email="test@restaurant.com",
            contact_phone="+905551234567",
            address="Istanbul, Turkey",
            webhook_url="https://restaurant.com/webhook"
        )
        
        # Mock Supabase response
        mock_response = Mock()
        mock_response.data = [{
            "id": str(uuid4()),
            "name": "Test Restaurant",
            "business_type": "restaurant",
            "api_key": "mk_test123",
            "webhook_url": "https://restaurant.com/webhook",
            "is_active": True,
            "contact_email": "test@restaurant.com",
            "contact_phone": "+905551234567",
            "address": "Istanbul, Turkey",
            "tax_number": None,
            "settings": {},
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }]
        
        self.mock_supabase.table.return_value.insert.return_value.execute.return_value = mock_response
        
        # Test
        result = await self.merchant_service.create_merchant(merchant_data)
        
        # Assertions
        assert isinstance(result, MerchantResponse)
        assert result.name == "Test Restaurant"
        assert result.business_type == "restaurant"
        assert result.is_active is True
        
        # Verify Supabase was called correctly
        self.mock_supabase.table.assert_called_with("merchants")
    
    @pytest.mark.asyncio
    async def test_create_merchant_failure(self):
        """Test merchant creation failure"""
        merchant_data = MerchantCreate(name="Test Merchant")
        
        # Mock failed response
        mock_response = Mock()
        mock_response.data = []
        self.mock_supabase.table.return_value.insert.return_value.execute.return_value = mock_response
        
        # Test
        with pytest.raises(Exception, match="Failed to create merchant"):
            await self.merchant_service.create_merchant(merchant_data)
    
    @pytest.mark.asyncio
    async def test_get_merchant_by_id_success(self):
        """Test getting merchant by ID"""
        merchant_id = uuid4()
        
        # Mock response
        mock_response = Mock()
        mock_response.data = [{
            "id": str(merchant_id),
            "name": "Test Merchant",
            "business_type": "retail",
            "api_key": "mk_test123",
            "webhook_url": None,
            "is_active": True,
            "contact_email": None,
            "contact_phone": None,
            "address": None,
            "tax_number": None,
            "settings": {},
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }]
        
        self.mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response
        
        # Test
        result = await self.merchant_service.get_merchant_by_id(merchant_id)
        
        # Assertions
        assert result is not None
        assert result.id == merchant_id
        assert result.name == "Test Merchant"
    
    @pytest.mark.asyncio
    async def test_get_merchant_by_id_not_found(self):
        """Test getting non-existent merchant"""
        merchant_id = uuid4()
        
        # Mock empty response
        mock_response = Mock()
        mock_response.data = []
        self.mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response
        
        # Test
        result = await self.merchant_service.get_merchant_by_id(merchant_id)
        
        # Assertions
        assert result is None
    
    @pytest.mark.asyncio
    async def test_validate_api_key_valid(self):
        """Test API key validation with valid key"""
        api_key = "mk_validkey123"
        
        # Mock get_merchant_by_api_key to return a merchant
        with patch.object(self.merchant_service, 'get_merchant_by_api_key') as mock_get:
            mock_merchant = Mock()
            mock_merchant.is_active = True
            mock_get.return_value = mock_merchant
            
            result = await self.merchant_service.validate_api_key(api_key)
            assert result is True
    
    @pytest.mark.asyncio
    async def test_validate_api_key_invalid(self):
        """Test API key validation with invalid key"""
        api_key = "mk_invalidkey123"
        
        # Mock get_merchant_by_api_key to return None
        with patch.object(self.merchant_service, 'get_merchant_by_api_key') as mock_get:
            mock_get.return_value = None
            
            result = await self.merchant_service.validate_api_key(api_key)
            assert result is False
    
    @pytest.mark.asyncio
    async def test_update_merchant_success(self):
        """Test merchant update"""
        merchant_id = uuid4()
        update_data = MerchantUpdate(
            name="Updated Merchant",
            is_active=False
        )
        
        # Mock response
        mock_response = Mock()
        mock_response.data = [{
            "id": str(merchant_id),
            "name": "Updated Merchant",
            "business_type": "retail",
            "api_key": "mk_test123",
            "webhook_url": None,
            "is_active": False,
            "contact_email": None,
            "contact_phone": None,
            "address": None,
            "tax_number": None,
            "settings": {},
            "created_at": datetime.now(),
            "updated_at": datetime.now()
        }]
        
        self.mock_supabase.table.return_value.update.return_value.eq.return_value.execute.return_value = mock_response
        
        # Test
        result = await self.merchant_service.update_merchant(merchant_id, update_data)
        
        # Assertions
        assert result is not None
        assert result.name == "Updated Merchant"
        assert result.is_active is False


class TestCustomerMatchingService:
    """Test CustomerMatchingService functionality"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.mock_supabase = Mock()
        self.matching_service = CustomerMatchingService(self.mock_supabase)
    
    def test_hash_card_number(self):
        """Test card number hashing"""
        card_number = "1234 5678 9012 3456"
        hashed = self.matching_service.hash_card_number(card_number)
        
        # Check it's a hash
        assert len(hashed) == 64  # SHA256 hex length
        assert hashed != card_number
        
        # Check consistency
        hashed2 = self.matching_service.hash_card_number(card_number)
        assert hashed == hashed2
        
        # Check different cards produce different hashes
        different_card = "9876 5432 1098 7654"
        different_hash = self.matching_service.hash_card_number(different_card)
        assert hashed != different_hash
    
    @pytest.mark.asyncio
    async def test_match_customer_by_email_success(self):
        """Test customer matching by email"""
        customer_info = CustomerInfo(
            email="test@example.com",
            card_hash="abc123",
            card_last_four="1234"
        )
        
        # Mock user found by email
        mock_response = Mock()
        mock_response.data = [{"id": str(uuid4())}]
        self.mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response
        
        # Test
        result = await self.matching_service.match_customer(customer_info)
        
        # Assertions
        assert result.matched is True
        assert result.match_method == "email"
        assert result.confidence == 1.0
        assert result.user_id is not None
    
    @pytest.mark.asyncio
    async def test_match_customer_by_card_hash(self):
        """Test customer matching by card hash"""
        customer_info = CustomerInfo(
            card_hash="abc123hash",
            card_last_four="1234"
        )
        
        user_id = str(uuid4())
        
        # Mock Supabase table calls properly
        def mock_table_call(table_name):
            if table_name == "users":
                # Email lookup - returns empty
                mock_table = Mock()
                mock_select = Mock()
                mock_eq = Mock()
                mock_execute = Mock()
                mock_execute.data = []  # No user found by email
                mock_eq.execute.return_value = mock_execute
                mock_select.eq.return_value = mock_eq
                mock_table.select.return_value = mock_select
                return mock_table
            elif table_name == "user_payment_methods":
                # Card hash lookup - returns user
                mock_table = Mock()
                mock_select = Mock()
                mock_eq1 = Mock()
                mock_eq2 = Mock()
                mock_execute = Mock()
                mock_execute.data = [{"user_id": user_id}]  # User found by card hash
                mock_eq2.execute.return_value = mock_execute
                mock_eq1.eq.return_value = mock_eq2
                mock_select.eq.return_value = mock_eq1
                mock_table.select.return_value = mock_select
                return mock_table
            return Mock()
        
        self.mock_supabase.table.side_effect = mock_table_call
        
        # Test
        result = await self.matching_service.match_customer(customer_info)
        
        # Assertions
        assert result.matched is True
        assert result.match_method == "card_hash"
        assert result.confidence == 0.9
        assert result.user_id == UUID(user_id)
    
    @pytest.mark.asyncio
    async def test_match_customer_no_match(self):
        """Test customer matching when no match found"""
        customer_info = CustomerInfo(
            email="notfound@example.com",
            card_hash="notfound123"
        )
        
        # Mock no matches found
        mock_response = Mock()
        mock_response.data = []
        self.mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_response
        
        # Test
        result = await self.matching_service.match_customer(customer_info)
        
        # Assertions
        assert result.matched is False
        assert result.match_method is None
        assert result.confidence == 0.0
        assert result.user_id is None


class TestWebhookService:
    """Test WebhookService functionality"""
    
    def setup_method(self):
        """Setup for each test method"""
        self.mock_supabase = Mock()
        
        # Mock the dependencies before creating WebhookService
        with patch('app.services.webhook_service.DataProcessor') as mock_data_processor, \
             patch('app.services.webhook_service.CustomerMatchingService') as mock_customer_matcher:
            
            # Setup mock instances
            mock_data_processor_instance = Mock()
            mock_customer_matcher_instance = Mock()
            mock_data_processor.return_value = mock_data_processor_instance
            mock_customer_matcher.return_value = mock_customer_matcher_instance
            
            self.webhook_service = WebhookService(self.mock_supabase)
            
            # Store references to mocked dependencies
            self.webhook_service.customer_matcher = mock_customer_matcher_instance
            self.webhook_service.data_processor = mock_data_processor_instance
    
    def create_sample_transaction_data(self):
        """Create sample transaction data for testing"""
        return WebhookTransactionData(
            transaction_id="TXN-123456",
            merchant_transaction_id="MERCHANT-789",
            total_amount=125.50,
            currency="TRY",
            transaction_date=datetime.now(timezone.utc),
            customer_info=CustomerInfo(
                email="test@example.com",
                card_hash="abc123hash",
                card_last_four="1234",
                card_type="visa"
            ),
            items=[
                TransactionItem(
                    description="Coffee",
                    quantity=2,
                    unit_price=25.00,
                    total_price=50.00,
                    category="Food & Beverage"
                ),
                TransactionItem(
                    description="Sandwich",
                    quantity=1,
                    unit_price=75.50,
                    total_price=75.50,
                    category="Food & Beverage"
                )
            ],
            payment_method="credit_card",
            receipt_number="RCP-001"
        )
    
    @pytest.mark.asyncio
    async def test_process_merchant_transaction_success(self):
        """Test successful webhook transaction processing"""
        merchant_id = uuid4()
        transaction_data = self.create_sample_transaction_data()
        user_id = uuid4()
        receipt_id = uuid4()
        expense_id = uuid4()
        
        # Mock customer matching success
        match_result = CustomerMatchResult(
            matched=True,
            user_id=user_id,
            match_method="email",
            confidence=1.0
        )
        self.webhook_service.customer_matcher.match_customer = AsyncMock(return_value=match_result)
        self.webhook_service.customer_matcher.store_payment_method = AsyncMock(return_value=True)
        
        # Mock successful receipt and expense creation with AsyncMock
        with patch.object(self.webhook_service, '_log_webhook_attempt', new_callable=AsyncMock) as mock_log, \
             patch.object(self.webhook_service, '_create_receipt_from_webhook', new_callable=AsyncMock) as mock_receipt, \
             patch.object(self.webhook_service, '_create_expense_from_webhook', new_callable=AsyncMock) as mock_expense, \
             patch.object(self.webhook_service, '_update_webhook_log', new_callable=AsyncMock) as mock_update_log:
            
            mock_log.return_value = uuid4()
            mock_receipt.return_value = receipt_id
            mock_expense.return_value = expense_id
            
            # Test
            result = await self.webhook_service.process_merchant_transaction(
                merchant_id, transaction_data, test_mode=False
            )
            
            # Assertions
            assert result.success is True
            assert result.matched_user_id == user_id
            assert result.created_receipt_id == receipt_id
            assert result.created_expense_id == expense_id
            assert result.transaction_id == "TXN-123456"
            assert "successfully" in result.message.lower()
    
    @pytest.mark.asyncio
    async def test_process_merchant_transaction_customer_not_matched(self):
        """Test webhook processing when customer is not matched"""
        merchant_id = uuid4()
        transaction_data = self.create_sample_transaction_data()
        
        # Mock customer matching failure
        match_result = CustomerMatchResult(
            matched=False,
            user_id=None,
            match_method=None,
            confidence=0.0
        )
        self.webhook_service.customer_matcher.match_customer = AsyncMock(return_value=match_result)
        
        # Mock logging with AsyncMock
        with patch.object(self.webhook_service, '_log_webhook_attempt', new_callable=AsyncMock) as mock_log, \
             patch.object(self.webhook_service, '_update_webhook_log', new_callable=AsyncMock) as mock_update_log:
            
            mock_log.return_value = uuid4()
            
            # Test
            result = await self.webhook_service.process_merchant_transaction(
                merchant_id, transaction_data, test_mode=False
            )
            
            # Assertions
            assert result.success is False
            assert "Customer not matched" in result.message
            assert result.matched_user_id is None
            assert result.created_receipt_id is None
            assert result.created_expense_id is None
    
    @pytest.mark.asyncio
    async def test_create_receipt_from_webhook(self):
        """Test receipt creation from webhook data"""
        user_id = uuid4()
        merchant_id = uuid4()
        transaction_data = self.create_sample_transaction_data()
        
        # Mock merchant lookup
        mock_merchant_response = Mock()
        mock_merchant_response.data = [{"name": "Test Merchant"}]
        
        # Mock receipt creation
        mock_receipt_response = Mock()
        receipt_id = uuid4()
        mock_receipt_response.data = [{"id": str(receipt_id)}]
        
        self.mock_supabase.table.return_value.select.return_value.eq.return_value.execute.return_value = mock_merchant_response
        self.mock_supabase.table.return_value.insert.return_value.execute.return_value = mock_receipt_response
        
        # Test
        result = await self.webhook_service._create_receipt_from_webhook(
            user_id, merchant_id, transaction_data, test_mode=False
        )
        
        # Assertions
        assert result == receipt_id
    
    @pytest.mark.asyncio
    async def test_webhook_logs_retrieval(self):
        """Test webhook logs retrieval"""
        merchant_id = uuid4()
        
        # Mock logs response
        mock_response = Mock()
        mock_response.data = [
            {
                "id": str(uuid4()),
                "merchant_id": str(merchant_id),
                "transaction_id": "TXN-123",
                "status": "success",
                "response_code": 200,
                "error_message": None,
                "processing_time_ms": 150,
                "retry_count": 0,
                "created_at": datetime.now()
            }
        ]
        mock_response.count = 1
        
        self.mock_supabase.table.return_value.select.return_value.eq.return_value.range.return_value.order.return_value.execute.return_value = mock_response
        
        # Test
        logs, total = await self.webhook_service.get_webhook_logs(merchant_id, page=1, size=20)
        
        # Assertions
        assert len(logs) == 1
        assert total == 1
        assert logs[0].status == WebhookStatus.SUCCESS


class TestMerchantIntegrationValidation:
    """Test data validation and edge cases"""
    
    def test_merchant_create_validation(self):
        """Test merchant creation data validation"""
        # Valid data
        valid_data = MerchantCreate(
            name="Test Merchant",
            business_type=BusinessType.RESTAURANT,
            contact_email="test@example.com",
            contact_phone="+905551234567"
        )
        assert valid_data.name == "Test Merchant"
        assert valid_data.business_type == BusinessType.RESTAURANT
        
        # Invalid email should raise validation error
        with pytest.raises(Exception):
            MerchantCreate(
                name="Test",
                contact_email="invalid-email"
            )
        
        # Invalid phone should raise validation error
        with pytest.raises(Exception):
            MerchantCreate(
                name="Test",
                contact_phone="invalid-phone"
            )
    
    def test_webhook_transaction_validation(self):
        """Test webhook transaction data validation"""
        # Valid transaction
        valid_transaction = WebhookTransactionData(
            transaction_id="TXN-123",
            total_amount=100.0,
            currency="TRY",
            transaction_date=datetime.now(timezone.utc),
            customer_info=CustomerInfo(email="test@example.com"),
            items=[
                TransactionItem(
                    description="Test Item",
                    quantity=1,
                    unit_price=100.0,
                    total_price=100.0
                )
            ]
        )
        assert valid_transaction.transaction_id == "TXN-123"
        assert valid_transaction.currency == "TRY"
        
        # Invalid currency should raise validation error
        with pytest.raises(Exception):
            transaction_with_invalid_currency = WebhookTransactionData(
                transaction_id="TXN-123",
                total_amount=100.0,
                currency="invalid",  # Invalid currency
                transaction_date=datetime.now(timezone.utc),
                customer_info=CustomerInfo(email="test@example.com"),
                items=[
                    TransactionItem(
                        description="Test Item",
                        quantity=1,
                        unit_price=100.0,
                        total_price=100.0
                    )
                ]
            )
    
    def test_customer_info_validation(self):
        """Test customer info validation"""
        # Valid customer info
        valid_customer = CustomerInfo(
            email="test@example.com",
            card_last_four="1234"
        )
        assert valid_customer.email == "test@example.com"
        assert valid_customer.card_last_four == "1234"
        
        # Invalid card_last_four length
        with pytest.raises(Exception):
            CustomerInfo(
                email="test@example.com",
                card_last_four="12345"  # Too long
            )


# Integration test that combines multiple services
class TestMerchantWebhookIntegration:
    """Integration tests for merchant and webhook services working together"""
    
    @pytest.mark.asyncio
    async def test_end_to_end_webhook_processing(self):
        """Test complete webhook processing flow"""
        # This would be a more complex integration test
        # For now, we'll test that the components can work together
        
        mock_supabase = Mock()
        merchant_service = MerchantService(mock_supabase)
        
        # Mock WebhookService creation with proper dependencies
        with patch('app.services.webhook_service.DataProcessor') as mock_data_processor, \
             patch('app.services.webhook_service.CustomerMatchingService') as mock_customer_matcher:
            
            mock_data_processor.return_value = Mock()
            mock_customer_matcher.return_value = Mock()
            webhook_service = WebhookService(mock_supabase)
        
        # Test that services can be instantiated and have expected methods
        assert hasattr(merchant_service, 'create_merchant')
        assert hasattr(merchant_service, 'validate_api_key')
        assert hasattr(webhook_service, 'process_merchant_transaction')
        assert hasattr(webhook_service, 'get_webhook_logs')


if __name__ == "__main__":
    # Run tests if script is executed directly
    pytest.main([__file__, "-v"]) 