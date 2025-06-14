# EcoTrack API Endpoints - Summary List (Updated)

This file contains a summary list of all current endpoints in the EcoTrack backend.

## 📊 Endpoint Statistics

- **Total Endpoints:** 50+
- **Categories:** 12
- **Authentication Required:** 42 endpoints
- **Public Endpoints:** 8 endpoints

## 🏥 Health Check Endpoints (6)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/health` | ❌ | Basic health check |
| GET | `/health/detailed` | ❌ | Detailed health check |
| GET | `/health/database` | ❌ | Database health check |
| GET | `/health/metrics` | ✅ | System metrics |
| GET | `/health/ready` | ❌ | Readiness check |
| GET | `/health/live` | ❌ | Liveness check |

## 🔐 Authentication Endpoints (8)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/auth/login` | ❌ | User login |
| POST | `/api/v1/auth/register` | ❌ | User registration |
| POST | `/api/v1/auth/reset-password` | ❌ | Password reset |
| POST | `/api/v1/auth/reset-password/confirm` | ❌ | Password reset confirmation |
| GET | `/api/v1/auth/mfa/status` | ✅ | MFA status |
| POST | `/api/v1/auth/mfa/totp/create` | ✅ | Create TOTP MFA |
| POST | `/api/v1/auth/mfa/totp/verify` | ✅ | Verify TOTP |
| DELETE | `/api/v1/auth/account` | ✅ | Account deletion |

## 🧾 Receipt Endpoints (5)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/receipts/scan` | ✅ | QR code scanning |
| GET | `/api/v1/receipts` | ✅ | Receipt list |
| GET | `/api/v1/receipts/{id}` | ✅ | Receipt details |
| GET | `/api/v1/receipts/public/{id}` | ❌ | Public receipt view |
| GET | `/api/v1/receipts/receipt/{id}` | ❌ | HTML receipt view |

## 💰 Expense Endpoints (9)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/expenses` | ✅ | Create manual expense |
| GET | `/api/v1/expenses` | ✅ | Expense list |
| GET | `/api/v1/expenses/{id}` | ✅ | Expense details |
| PUT | `/api/v1/expenses/{id}` | ✅ | Update expense |
| DELETE | `/api/v1/expenses/{id}` | ✅ | Delete expense |
| POST | `/api/v1/expenses/{id}/items` | ✅ | Add expense item |
| PUT | `/api/v1/expenses/{id}/items/{item_id}` | ✅ | Update expense item |
| DELETE | `/api/v1/expenses/{id}/items/{item_id}` | ✅ | Delete expense item |
| GET | `/api/v1/expenses/{id}/items` | ✅ | List expense items |

## 📂 Category Endpoints (4)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/categories` | ✅ | Category list |
| POST | `/api/v1/categories` | ✅ | Create category |
| PUT | `/api/v1/categories/{id}` | ✅ | Update category |
| DELETE | `/api/v1/categories/{id}` | ✅ | Delete category |

## 🏪 Merchant Endpoints (6) - Admin Only

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/merchants` | 👑 | Create merchant |
| GET | `/api/v1/merchants` | 👑 | Merchant list |
| GET | `/api/v1/merchants/{id}` | 👑 | Merchant details |
| PUT | `/api/v1/merchants/{id}` | 👑 | Update merchant |
| DELETE | `/api/v1/merchants/{id}` | 👑 | Delete merchant |
| POST | `/api/v1/merchants/{id}/regenerate-api-key` | 👑 | Regenerate API key |

## ⭐ Review Endpoints (7)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/reviews/merchants/{id}/reviews` | ✅ | Merchant review |
| GET | `/api/v1/reviews/merchants/{id}/reviews` | ❓ | Merchant reviews |
| GET | `/api/v1/reviews/merchants/{id}/rating` | ❌ | Merchant rating |
| PUT | `/api/v1/reviews/reviews/{id}` | ✅ | Update review |
| DELETE | `/api/v1/reviews/reviews/{id}` | ✅ | Delete review |
| POST | `/api/v1/reviews/receipts/{id}/review` | ✅ | Receipt review |
| POST | `/api/v1/reviews/receipts/{id}/review/anonymous` | ❌ | Anonymous receipt review |

## 📊 Financial Reporting Endpoints (8)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/reports/health` | ❌ | Reporting health check |
| GET | `/api/v1/reports/category-distribution` | ✅ | Category distribution |
| GET | `/api/v1/reports/budget-vs-actual` | ✅ | Budget vs actual |
| GET | `/api/v1/reports/spending-trends` | ✅ | Spending trends |
| POST | `/api/v1/reports/category-distribution` | ✅ | Category distribution (POST) |
| POST | `/api/v1/reports/budget-vs-actual` | ✅ | Budget vs actual (POST) |
| POST | `/api/v1/reports/spending-trends` | ✅ | Spending trends (POST) |
| GET | `/api/v1/reports/export` | ✅ | Report export |

## 🏆 Loyalty Program Endpoints (4)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/loyalty/status` | ✅ | Loyalty status |
| GET | `/api/v1/loyalty/calculate-points` | ✅ | Calculate points |
| GET | `/api/v1/loyalty/history` | ✅ | Loyalty history |
| GET | `/api/v1/loyalty/levels` | ❌ | Loyalty levels |

## 📱 Device Management Endpoints (4)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/devices/register` | ✅ | Device registration |
| GET | `/api/v1/devices` | ✅ | User devices |
| PUT | `/api/v1/devices/{id}/deactivate` | ✅ | Deactivate device |
| DELETE | `/api/v1/devices/{id}` | ✅ | Delete device |

## 🔗 Webhook Endpoints (5) - Merchant Integration

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/webhooks/merchant/{id}/transaction` | 🔑 | Transaction webhook |
| POST | `/api/v1/webhooks/merchant/{id}/test-transaction` | 🔑 | Test transaction |
| GET | `/api/v1/webhooks/merchant/{id}/logs` | 🔑 | Webhook logs |
| POST | `/api/v1/webhooks/logs/{id}/retry` | 🔑 | Retry webhook |
| GET | `/api/v1/webhooks/merchant/{id}/stats` | 🔑 | Webhook statistics |

## 💰 Budget Management Endpoints (9)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/v1/budget` | ✅ | Create user budget |
| GET | `/api/v1/budget` | ✅ | User budget |
| PUT | `/api/v1/budget` | ✅ | Update user budget |
| POST | `/api/v1/budget/categories` | ✅ | Create category budget |
| GET | `/api/v1/budget/categories` | ✅ | Category budgets |
| GET | `/api/v1/budget/summary` | ✅ | Budget summary |
| POST | `/api/v1/budget/apply-allocation` | ✅ | Apply budget allocation |
| DELETE | `/api/v1/budget/categories/{id}` | ✅ | Delete category budget |
| GET | `/api/v1/budget/health` | ❌ | Budget health check |

## 🔑 Authentication Types

- ❌ **Public**: No authentication required
- ✅ **User Auth**: Bearer token required
- 👑 **Admin Only**: Admin privileges required
- 🔑 **API Key**: Merchant API key required
- ❓ **Optional**: Optional authentication

## 📋 HTTP Status Codes

- **200 OK**: Successful GET, PUT requests
- **201 Created**: Successful POST requests
- **204 No Content**: Successful DELETE requests
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors
- **500 Internal Server Error**: Server error

## 🌐 Base Configuration

- **Base URL**: `http://localhost:8000`
- **API Version**: `/api/v1`
- **Content Type**: `application/json`
- **Timeout**: 30 seconds recommended
- **Rate Limiting**: 100 requests per minute per user

## 📱 Flutter Integration Priority

### High Priority (Core Features)
1. Authentication endpoints (login, register)
2. Receipt scan endpoint
3. Expense CRUD endpoints
4. Category list endpoint
5. Health check endpoints

### Medium Priority (Main Features)
1. Financial reporting endpoints
2. Loyalty program endpoints
3. Device management endpoints
4. Budget management endpoints

### Low Priority (Advanced Features)
1. Review system endpoints
2. Merchant management (admin)
3. Webhook endpoints (merchant integration)

This summary list helps Flutter developers understand which endpoints they should prioritize for integration. 