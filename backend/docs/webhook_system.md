# EcoTrack Webhook System

## What are Webhooks?

Webhooks are HTTP callbacks used by one application to send real-time data to another application. In EcoTrack, webhooks are used for automatic receipt delivery from merchant POS systems.

## System Architecture

```
[Merchant POS] → [Webhook] → [EcoTrack API] → [Auto Receipt/Expense]
```

### Workflow:
1. **Customer Makes Purchase**: Payment is completed at the store
2. **POS System Sends Webhook**: Transaction data is sent to EcoTrack
3. **Customer Matching**: Customer is matched using email/phone/card information
4. **Automatic Recording**: Receipt and expense records are automatically created
5. **Loyalty Points**: Points are automatically calculated and awarded

## Webhook Endpoints

### 1. Transaction Webhook (Main Endpoint)
```
POST /api/v1/webhooks/merchant/{merchant_id}/transaction
```

**Headers:**
```
X-API-Key: {merchant_api_key}
Content-Type: application/json
```

**Request Body:**
```json
{
  "transaction_id": "TXN-123456",
  "total_amount": 150.75,
  "currency": "TRY",
  "transaction_date": "2024-01-15T14:30:00Z",
  "customer_info": {
    "email": "customer@email.com",
    "phone": "+905551234567",
    "card_last_four": "1234",
    "card_type": "visa"
  },
  "items": [
    {
      "description": "Americano Coffee",
      "quantity": 2,
      "unit_price": 18.50,
      "total_price": 37.00,
      "category": "beverages"
    }
  ],
  "payment_method": "credit_card",
  "receipt_number": "RCP-789",
  "store_location": "Istanbul Central"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Transaction processed successfully",
  "transaction_id": "TXN-123456",
  "matched_user_id": "user-uuid",
  "created_receipt_id": "receipt-uuid",
  "created_expense_id": "expense-uuid",
  "processing_time_ms": 150
}
```

### 2. Test Transaction Endpoint
```
POST /api/v1/webhooks/merchant/{merchant_id}/test-transaction
```
- Admin only endpoint
- For testing purposes
- Does not require API key

### 3. Webhook Logs
```
GET /api/v1/webhooks/merchant/{merchant_id}/logs
```
- View webhook history
- Track success/failure status
- Pagination support

### 4. Webhook Statistics
```
GET /api/v1/webhooks/merchant/{merchant_id}/stats
```
- Success rates
- Average processing times
- Total transaction counts

### 5. Webhook Retry
```
POST /api/v1/webhooks/logs/{log_id}/retry
```
- Retry failed webhooks
- Maximum 3 retry attempts

## Customer Matching

The system uses the following methods to identify customers:

### 1. Email Matching
- Most reliable method
- Direct email address matching

### 2. Phone Matching
- Phone number matching
- Turkish formats supported (+90...)

### 3. Card Hash Matching
- Card number hash matching
- Hash used for security
- Last 4 digits verification

## Security

### API Key Authentication
- Each merchant has a unique API key
- Sent as `X-API-Key` in headers
- Key regeneration feature available

### Data Validation
- All incoming data validated with Pydantic
- Invalid data is rejected
- SQL injection protection

### Rate Limiting
- Webhook endpoints are rate limited
- Spam protection in place

## Error Handling

### Webhook Statuses:
- `pending`: Processing started
- `success`: Successfully completed
- `failed`: Error occurred
- `retry`: Retrying

### Retry Mechanism:
- Failed webhooks are automatically retried
- Maximum 3 attempts
- Exponential backoff strategy

### Error Logging:
- All errors are logged in detail
- Processing time tracking
- Error message records

## Demo and Testing

### Local Development:
```bash
# Start the server
uvicorn app.main:app --reload

# Run demo script
python demo_webhook_simulation.py
```

### Manual Testing:
```bash
# Create merchant
curl -X POST "http://localhost:8000/api/v1/merchants" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Store",
    "business_type": "restaurant"
  }'

# Send webhook
curl -X POST "http://localhost:8000/api/v1/webhooks/merchant/{merchant_id}/transaction" \
  -H "X-API-Key: {api_key}" \
  -H "Content-Type: application/json" \
  -d '{...transaction_data...}'
```

## Real-World Integration

### Merchant POS System Integration:
1. **Merchant Registration**: Store registers with EcoTrack
2. **API Key Acquisition**: Unique API key is provided
3. **POS Configuration**: POS system is configured with webhook URL
4. **Test Phase**: Test transactions are sent
5. **Production**: Live transactions begin

### Supported POS Systems:
- Olivetti POS
- Ingenico POS
- Verifone POS
- All systems with custom REST API

## Monitoring and Analytics

### Webhook Metrics:
- Success rate tracking
- Processing time monitoring
- Error rate analysis
- Volume tracking

### Alerting:
- High error rate alerts
- Slow processing alerts
- Volume anomaly detection

## Future Enhancements

### Planned Features:
- [ ] Webhook signature verification
- [ ] Batch transaction processing
- [ ] Real-time notifications
- [ ] Advanced retry strategies
- [ ] Webhook transformation rules
- [ ] Multi-currency support enhancement

## Troubleshooting

### Common Issues:

**1. "Invalid API Key" Error:**
- Verify the API key is correct
- Confirm the merchant is active

**2. "Customer not matched" Error:**
- Check email/phone/card information
- Verify the customer is registered in the system

**3. "Processing timeout" Error:**
- Check webhook payload size
- Test network connectivity

### Debug Commands:
```bash
# Check webhook logs
curl -X GET "http://localhost:8000/api/v1/webhooks/merchant/{id}/logs" \
  -H "Authorization: Bearer {token}"

# Check webhook stats
curl -X GET "http://localhost:8000/api/v1/webhooks/merchant/{id}/stats" \
  -H "Authorization: Bearer {token}"
```

## Conclusion

The EcoTrack webhook system provides seamless integration with merchant POS systems, offering customers an automatic receipt delivery experience. It features a secure, scalable, and reliable architecture. 