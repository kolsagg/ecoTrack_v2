# EcoTrack API Endpoints - Flutter Integration Reference (Güncel)

Bu dokümanda EcoTrack backend'inin tüm güncel endpoint'leri, request/response şemaları ve Flutter entegrasyonu için gerekli bilgiler yer almaktadır.

## 📋 Endpoint Özeti

Backend'de toplam **50+ endpoint** bulunmaktadır:

- 🏥 **Health Check** (6 endpoint)
- 🔐 **Authentication** (8 endpoint)  
- 🧾 **Receipt Management** (5 endpoint)
- 💰 **Expense Management** (9 endpoint)
- 📂 **Category Management** (3 endpoint)
- 🏪 **Merchant Management** (6 endpoint)
- ⭐ **Review System** (7 endpoint)
- 📊 **Financial Reporting** (8 endpoint)
- 🏆 **Loyalty Program** (4 endpoint)
- 📱 **Device Management** (4 endpoint)
- 🔗 **Webhooks** (5 endpoint)
- 💰 **Budget Management** (9 endpoint)

## 🏥 Health Check Endpoints

### 1. Basic Health Check
**Endpoint:** `GET /health`
**Headers:** None required
**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "environment": "development"
}
```

### 2. Detailed Health Check
**Endpoint:** `GET /health/detailed`
**Headers:** None required
**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "environment": "development",
  "checks": {
    "supabase": {
      "status": "healthy",
      "response_time_ms": 15.2,
      "message": "Connection successful"
    }
  }
}
```

### 3. Database Health Check
**Endpoint:** `GET /health/database`
**Headers:** None required
**Response:**
```json
{
  "status": "healthy",
  "connection_time_ms": 12.5,
  "query_time_ms": 8.3,
  "tables": {
    "users": 150,
    "categories": 25,
    "receipts": 1250,
    "expenses": 3400,
    "merchants": 45
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### 4. System Metrics (Auth Required)
**Endpoint:** `GET /health/metrics`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "totals": {
    "users": 150,
    "expenses": 3400,
    "receipts": 1250,
    "merchants": 45
  },
  "last_24h": {
    "new_expenses": 45,
    "new_receipts": 23
  },
  "system": {
    "environment": "development",
    "version": "1.0.0"
  }
}
```

### 5. Readiness Check
**Endpoint:** `GET /health/ready`
**Headers:** None required
**Response:**
```json
{
  "status": "ready"
}
```

### 6. Liveness Check
**Endpoint:** `GET /health/live`
**Headers:** None required
**Response:**
```json
{
  "status": "alive"
}
```

## 🔐 Authentication Endpoints

### 1. Login
**Endpoint:** `POST /api/v1/auth/login`
**Headers:** `Content-Type: application/json`
**Request Schema:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```
**Success Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

### 2. Register
**Endpoint:** `POST /api/v1/auth/register`
**Headers:** `Content-Type: application/json`
**Request Schema:**
```json
{
  "email": "newuser@example.com",
  "password": "securepassword123",
  "first_name": "John",
  "last_name": "Doe"
}
```
**Success Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": "user_456",
    "email": "newuser@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

### 3. Password Reset
**Endpoint:** `POST /api/v1/auth/reset-password`
**Headers:** `Content-Type: application/json`
**Request Schema:**
```json
{
  "email": "user@example.com"
}
```
**Success Response (200):**
```json
{
  "message": "Password reset email sent"
}
```

### 4. Confirm Password Reset
**Endpoint:** `POST /api/v1/auth/reset-password/confirm`
**Headers:** `Content-Type: application/json`
**Request Schema:**
```json
{
  "token": "reset_token_here",
  "new_password": "newpassword123"
}
```
**Success Response (200):**
```json
{
  "message": "Password reset successful"
}
```

### 5. MFA Status
**Endpoint:** `GET /api/v1/auth/mfa/status`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "is_enabled": false,
  "factors": ["totp"],
  "preferred_factor": null
}
```

### 6. Create TOTP MFA
**Endpoint:** `POST /api/v1/auth/mfa/totp/create`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "id": "factor_123",
  "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "secret": "JBSWY3DPEHPK3PXP",
  "uri": "otpauth://totp/EcoTrack:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=EcoTrack"
}
```

### 7. Verify TOTP
**Endpoint:** `POST /api/v1/auth/mfa/totp/verify`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "factor_id": "factor_123",
  "code": "123456"
}
```
**Success Response (200):**
```json
{
  "message": "TOTP verified successfully"
}
```

### 8. Delete Account
**Endpoint:** `DELETE /api/v1/auth/account`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "password": "currentpassword123"
}
```
**Success Response (200):**
```json
{
  "message": "Account deleted successfully"
}
```

## 🧾 Receipt Endpoints

### 1. QR Code Scan
**Endpoint:** `POST /api/v1/receipts/scan`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "qr_data": "https://efatura.gov.tr/qr?p=..."
}
```
**Success Response (200):**
```json
{
  "success": true,
  "message": "Receipt processed successfully",
  "receipt_id": "receipt_123",
  "merchant_name": "Migros",
  "total_amount": 125.50,
  "currency": "TRY",
  "expenses_count": 8,
  "processing_confidence": 0.95,
  "public_url": "https://ecotrack.app/receipt/receipt_123"
}
```

### 2. List Receipts
**Endpoint:** `GET /api/v1/receipts`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `page` (int): Page number (default: 1)
- `limit` (int): Items per page (default: 20, max: 100)
- `merchant` (string): Filter by merchant name
- `date_from` (datetime): Filter from date
- `date_to` (datetime): Filter to date
- `min_amount` (float): Minimum amount filter
- `max_amount` (float): Maximum amount filter
- `sort_by` (string): Sort field (default: "transaction_date")
- `sort_order` (string): Sort order "asc" or "desc" (default: "desc")

**Response:**
```json
{
  "receipts": [
    {
      "id": "receipt_123",
      "merchant_name": "Migros",
      "transaction_date": "2024-01-15T14:30:00Z",
      "total_amount": 125.50,
      "currency": "TRY",
      "source": "qr_scan",
      "created_at": "2024-01-15T14:35:00Z"
    }
  ],
  "total": 45,
  "page": 1,
  "limit": 20,
  "has_next": true
}
```

### 3. Receipt Detail
**Endpoint:** `GET /api/v1/receipts/{receipt_id}`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "id": "receipt_123",
  "merchant_name": "Migros",
  "transaction_date": "2024-01-15T14:30:00Z",
  "total_amount": 125.50,
  "currency": "TRY",
  "source": "qr_scan",
  "raw_qr_data": "https://efatura.gov.tr/qr?p=...",
  "parsed_receipt_data": {
    "tax_number": "1234567890",
    "receipt_number": "FIS001234"
  },
  "expenses": [
    {
      "id": "expense_456",
      "total_amount": 125.50,
      "items_count": 8
    }
  ],
  "created_at": "2024-01-15T14:35:00Z",
  "updated_at": "2024-01-15T14:35:00Z"
}
```

### 4. Public Receipt View
**Endpoint:** `GET /api/v1/receipts/public/{receipt_id}`
**Headers:** None required
**Response:** HTML page for public receipt viewing

### 5. Receipt HTML View
**Endpoint:** `GET /api/v1/receipts/receipt/{receipt_id}`
**Headers:** None required
**Response:** HTML formatted receipt view

## 💰 Expense Endpoints

### 1. Create Manual Expense
**Endpoint:** `POST /api/v1/expenses`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "merchant_name": "Local Market",
  "expense_date": "2024-01-15T14:30:00Z",
  "notes": "Weekly groceries",
  "currency": "TRY",
  "items": [
    {
      "category_id": "cat_food_123",
      "item_name": "Bread",
      "amount": 7.00,
      "quantity": 2,
      "unit_price": 3.50,
      "kdv_rate": 10.0,
      "notes": "Whole wheat bread"
    }
  ]
}
```
**Success Response (201):**
```json
{
  "id": "expense_123",
  "receipt_id": "receipt_456",
  "total_amount": 7.00,
  "expense_date": "2024-01-15T14:30:00Z",
  "notes": "Weekly groceries",
  "merchant_name": "Local Market",
  "items": [
    {
      "id": "item_789",
      "expense_id": "expense_123",
      "category_id": "cat_food_123",
      "category_name": "Food",
      "item_name": "Bread",
      "amount": 7.00,
      "quantity": 2,
      "unit_price": 3.50,
      "kdv_rate": 10.0,
      "amount_without_kdv": 6.36,
      "notes": "Whole wheat bread",
      "created_at": "2024-01-15T14:30:00Z",
      "updated_at": "2024-01-15T14:30:00Z"
    }
  ],
  "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "created_at": "2024-01-15T14:30:00Z",
  "updated_at": "2024-01-15T14:30:00Z"
}
```

### 2. List Expenses
**Endpoint:** `GET /api/v1/expenses`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:** Same as receipts list
**Response:**
```json
{
  "expenses": [
    {
      "id": "expense_123",
      "receipt_id": "receipt_456",
      "total_amount": 125.50,
      "expense_date": "2024-01-15T14:30:00Z",
      "notes": "Weekly groceries",
      "items_count": 8,
      "merchant_name": "Migros",
      "source": "qr_scan",
      "created_at": "2024-01-15T14:30:00Z"
    }
  ],
  "total": 156,
  "page": 1,
  "limit": 20,
  "has_next": true
}
```

### 3. Get Expense Detail
**Endpoint:** `GET /api/v1/expenses/{expense_id}`
**Headers:** `Authorization: Bearer {token}`
**Response:** Same as Create Manual Expense response

### 4. Update Expense
**Endpoint:** `PUT /api/v1/expenses/{expense_id}`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "expense_date": "2024-01-16T14:30:00Z",
  "notes": "Updated notes",
  "merchant_name": "Updated Merchant Name"
}
```
**Success Response (200):** Same as Get Expense Detail response

### 5. Delete Expense
**Endpoint:** `DELETE /api/v1/expenses/{expense_id}`
**Headers:** `Authorization: Bearer {token}`
**Success Response (204):** No content

### 6. Create Expense Item
**Endpoint:** `POST /api/v1/expenses/{expense_id}/items`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "category_id": "cat_food_123",
  "item_name": "Milk",
  "amount": 8.50,
  "quantity": 1,
  "unit_price": 8.50,
  "kdv_rate": 10.0,
  "notes": "Organic milk"
}
```
**Success Response (201):** ExpenseItemResponse

### 7. Update Expense Item
**Endpoint:** `PUT /api/v1/expenses/{expense_id}/items/{item_id}`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "category_id": "cat_food_123",
  "item_name": "Updated Milk",
  "amount": 9.00,
  "quantity": 1,
  "kdv_rate": 10.0,
  "unit_price": 9.00,
  "notes": "Updated notes"
}
```
**Success Response (200):** ExpenseItemResponse

### 8. Delete Expense Item
**Endpoint:** `DELETE /api/v1/expenses/{expense_id}/items/{item_id}`
**Headers:** `Authorization: Bearer {token}`
**Success Response (204):** No content

### 9. List Expense Items
**Endpoint:** `GET /api/v1/expenses/{expense_id}/items`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "items": [
    {
      "id": "item_789",
      "expense_id": "expense_123",
      "category_id": "cat_food_123",
      "category_name": "Food",
      "item_name": "Bread",
      "amount": 7.00,
      "quantity": 2,
      "unit_price": 3.50,
      "kdv_rate": 10.0,
      "amount_without_kdv": 6.36,
      "notes": "Whole wheat bread",
      "created_at": "2024-01-15T14:30:00Z",
      "updated_at": "2024-01-15T14:30:00Z"
    }
  ]
}
```

## 📂 Category Endpoints

### 1. List Categories
**Endpoint:** `GET /api/v1/categories`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "categories": [
    {
      "id": "cat_food_123",
      "name": "Food",
      "user_id": null,
      "is_system": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    },
    {
      "id": "cat_custom_456",
      "name": "My Custom Category",
      "user_id": "user_123",
      "is_system": false,
      "created_at": "2024-01-15T14:30:00Z",
      "updated_at": "2024-01-15T14:30:00Z"
    }
  ]
}
```

### 2. Create Category
**Endpoint:** `POST /api/v1/categories`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "name": "My New Category"
}
```
**Success Response (201):** CategoryResponse

### 3. Update Category
**Endpoint:** `PUT /api/v1/categories/{category_id}`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "name": "Updated Category Name"
}
```
**Success Response (200):** CategoryResponse

### 4. Delete Category
**Endpoint:** `DELETE /api/v1/categories/{category_id}`
**Headers:** `Authorization: Bearer {token}`
**Success Response (204):** No content

## 🏪 Merchant Endpoints (Admin Only)

### 1. Create Merchant
**Endpoint:** `POST /api/v1/merchants`
**Headers:** `Authorization: Bearer {admin_token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "name": "New Merchant",
  "business_type": "grocery",
  "contact_email": "contact@merchant.com",
  "contact_phone": "+90 212 123 4567",
  "address": "Istanbul, Turkey",
  "tax_number": "1234567890",
  "webhook_url": "https://merchant.com/webhook",
  "settings": {
    "auto_process": true
  }
}
```
**Success Response (201):** MerchantResponse

### 2. List Merchants
**Endpoint:** `GET /api/v1/merchants`
**Headers:** `Authorization: Bearer {admin_token}`
**Response:** MerchantListResponse

### 3. Get Merchant Detail
**Endpoint:** `GET /api/v1/merchants/{merchant_id}`
**Headers:** `Authorization: Bearer {admin_token}`
**Response:** MerchantResponse

### 4. Update Merchant
**Endpoint:** `PUT /api/v1/merchants/{merchant_id}`
**Headers:** `Authorization: Bearer {admin_token}`, `Content-Type: application/json`
**Request Schema:** MerchantUpdate schema
**Success Response (200):** MerchantResponse

### 5. Delete Merchant
**Endpoint:** `DELETE /api/v1/merchants/{merchant_id}`
**Headers:** `Authorization: Bearer {admin_token}`
**Success Response (204):** No content

### 6. Regenerate API Key
**Endpoint:** `POST /api/v1/merchants/{merchant_id}/regenerate-api-key`
**Headers:** `Authorization: Bearer {admin_token}`
**Response:**
```json
{
  "merchant_id": "merchant_123",
  "new_api_key": "new_api_key_here",
  "generated_at": "2024-01-15T14:30:00Z"
}
```

## ⭐ Review Endpoints

### 1. Create Merchant Review
**Endpoint:** `POST /api/v1/reviews/merchants/{merchant_id}/reviews`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "rating": 4,
  "comment": "Great service and good prices",
  "reviewer_name": "John Doe",
  "reviewer_email": "john@example.com",
  "is_anonymous": false,
  "receipt_id": "receipt_123"
}
```
**Success Response (201):** ReviewResponse

### 2. Get Merchant Reviews
**Endpoint:** `GET /api/v1/reviews/merchants/{merchant_id}/reviews`
**Headers:** `Authorization: Bearer {token}` (optional)
**Query Parameters:**
- `limit` (int): Number of reviews to return
- `offset` (int): Number of reviews to skip

**Response:** MerchantReviewsResponse

### 3. Get Merchant Rating
**Endpoint:** `GET /api/v1/reviews/merchants/{merchant_id}/rating`
**Headers:** None required
**Response:** MerchantRatingResponse

### 4. Update Review
**Endpoint:** `PUT /api/v1/reviews/reviews/{review_id}`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:** ReviewUpdateRequest
**Success Response (200):** ReviewResponse

### 5. Delete Review
**Endpoint:** `DELETE /api/v1/reviews/reviews/{review_id}`
**Headers:** `Authorization: Bearer {token}`
**Success Response (204):** No content

### 6. Create Receipt Review
**Endpoint:** `POST /api/v1/reviews/receipts/{receipt_id}/review`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:** ReviewCreateRequest
**Success Response (201):** ReviewResponse

### 7. Create Anonymous Receipt Review
**Endpoint:** `POST /api/v1/reviews/receipts/{receipt_id}/review/anonymous`
**Headers:** `Content-Type: application/json`
**Request Schema:** ReviewCreateRequest (with is_anonymous: true)
**Success Response (201):** ReviewResponse

## 📊 Financial Reporting Endpoints

### 1. Reporting Health Check
**Endpoint:** `GET /api/v1/reports/health`
**Headers:** None required
**Response:**
```json
{
  "status": "healthy",
  "service": "financial_reporting",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "2.0.0"
}
```

### 2. Category Distribution (Pie/Donut Chart)
**Endpoint:** `GET /api/v1/reports/category-distribution`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `year` (int): Year
- `month` (int): Month (1-12)
- `chart_type` (string): "pie" or "donut"

**Response:**
```json
{
  "reportTitle": "January 2024 Category Distribution",
  "totalAmount": 2450.75,
  "chartType": "pie",
  "data": [
    {
      "label": "Food",
      "value": 1250.75,
      "percentage": 51.0,
      "color": "#FF6384"
    },
    {
      "label": "Transportation",
      "value": 890.50,
      "percentage": 36.3,
      "color": "#36A2EB"
    }
  ]
}
```

### 3. Budget vs Actual (Bar Chart)
**Endpoint:** `GET /api/v1/reports/budget-vs-actual`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `year` (int): Year
- `month` (int): Month (1-12)

**Response:**
```json
{
  "reportTitle": "January 2024 Budget vs Actual",
  "chartType": "bar",
  "labels": ["Food", "Transportation", "Entertainment"],
  "datasets": [
    {
      "label": "Budget",
      "color": "#36A2EB",
      "data": [1000.00, 800.00, 300.00]
    },
    {
      "label": "Actual",
      "color": "#FF6384",
      "data": [1250.75, 890.50, 250.00]
    }
  ]
}
```

### 4. Spending Trends (Line Chart)
**Endpoint:** `GET /api/v1/reports/spending-trends`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `period` (string): "3_months", "6_months", "1_year"

**Response:**
```json
{
  "reportTitle": "6 Months Spending Trends",
  "chartType": "line",
  "xAxisLabels": {
    "1": "Aug 2023",
    "2": "Sep 2023",
    "3": "Oct 2023",
    "4": "Nov 2023",
    "5": "Dec 2023",
    "6": "Jan 2024"
  },
  "datasets": [
    {
      "label": "Total Spending",
      "color": "#FFCE56",
      "data": [
        {"x": 1, "y": 2100.00},
        {"x": 2, "y": 2300.00},
        {"x": 3, "y": 2150.00},
        {"x": 4, "y": 2400.00},
        {"x": 5, "y": 2325.25},
        {"x": 6, "y": 2450.75}
      ]
    }
  ]
}
```

### 5. POST Versions of Reports
**Endpoints:**
- `POST /api/v1/reports/category-distribution`
- `POST /api/v1/reports/budget-vs-actual`
- `POST /api/v1/reports/spending-trends`

**Request Schema (MonthlyReportRequest):**
```json
{
  "year": 2024,
  "month": 1,
  "chart_type": "pie"
}
```

**Request Schema (TrendReportRequest):**
```json
{
  "period": "6_months",
  "chart_type": "line"
}
```

### 6. Export Reports
**Endpoint:** `GET /api/v1/reports/export`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `report_type` (string): "category-distribution", "budget-vs-actual", "spending-trends"
- `format` (string): "json", "csv"
- `year` (int): Year for monthly reports
- `month` (int): Month for monthly reports
- `period` (string): Period for trend reports

**Response:** Report data in requested format

## 🏆 Loyalty Program Endpoints

### 1. Loyalty Status
**Endpoint:** `GET /api/v1/loyalty/status`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "user_id": "user_123",
  "points": 1250,
  "level": "silver",
  "points_to_next_level": 750,
  "next_level": "gold",
  "last_updated": "2024-01-15T14:30:00Z"
}
```

### 2. Calculate Points
**Endpoint:** `GET /api/v1/loyalty/calculate-points`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `amount` (float): Expense amount
- `category` (string): Expense category (optional)
- `merchant_name` (string): Merchant name (optional)

**Response:**
```json
{
  "base_points": 25,
  "bonus_points": 5,
  "total_points": 30,
  "calculation_details": {
    "base_rate": 0.01,
    "category_bonus": 0.002,
    "level_multiplier": 1.2
  }
}
```

### 3. Loyalty History
**Endpoint:** `GET /api/v1/loyalty/history`
**Headers:** `Authorization: Bearer {token}`
**Query Parameters:**
- `limit` (int): Maximum number of records (default: 50, max: 100)

**Response:**
```json
{
  "success": true,
  "count": 25,
  "history": [
    {
      "transaction_id": "trans_123",
      "user_id": "user_123",
      "points_earned": 30,
      "transaction_amount": 125.50,
      "merchant_name": "Migros",
      "calculation_details": {
        "base_points": 25,
        "bonus_points": 5
      },
      "created_at": "2024-01-15T14:30:00Z"
    }
  ]
}
```

### 4. Loyalty Levels
**Endpoint:** `GET /api/v1/loyalty/levels`
**Headers:** None required
**Response:**
```json
{
  "success": true,
  "levels": {
    "bronze": {
      "name": "Bronze",
      "points_required": 0,
      "multiplier": 1.0,
      "benefits": ["Base points earning", "Standard support"]
    },
    "silver": {
      "name": "Silver",
      "points_required": 1000,
      "multiplier": 1.2,
      "benefits": ["20% bonus points", "Priority support", "Monthly reports"]
    },
    "gold": {
      "name": "Gold",
      "points_required": 5000,
      "multiplier": 1.5,
      "benefits": ["50% bonus points", "Premium support", "Advanced analytics", "Category bonuses"]
    },
    "platinum": {
      "name": "Platinum",
      "points_required": 15000,
      "multiplier": 2.0,
      "benefits": ["100% bonus points", "VIP support", "Custom reports", "Maximum category bonuses", "Early feature access"]
    }
  },
  "category_bonuses": {
    "food": "50% bonus",
    "grocery": "30% bonus",
    "fuel": "20% bonus",
    "restaurant": "40% bonus"
  }
}
```

## 📱 Device Management Endpoints

### 1. Register Device
**Endpoint:** `POST /api/v1/devices/register`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "device_id": "android_device_123",
  "fcm_token": "fcm_token_xyz789",
  "device_type": "android",
  "device_name": "Samsung Galaxy S23",
  "app_version": "1.0.0",
  "os_version": "Android 13"
}
```
**Success Response (201):**
```json
{
  "device_id": "android_device_123",
  "registered_at": "2024-01-15T14:30:00Z",
  "status": "active"
}
```

### 2. List User Devices
**Endpoint:** `GET /api/v1/devices`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "devices": [
    {
      "id": "device_123",
      "device_id": "android_device_123",
      "device_type": "android",
      "device_name": "Samsung Galaxy S23",
      "is_active": true,
      "last_seen": "2024-01-15T14:30:00Z",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

### 3. Deactivate Device
**Endpoint:** `PUT /api/v1/devices/{device_id}/deactivate`
**Headers:** `Authorization: Bearer {token}`
**Success Response (200):**
```json
{
  "device_id": "android_device_123",
  "status": "deactivated",
  "deactivated_at": "2024-01-15T14:30:00Z"
}
```

### 4. Delete Device
**Endpoint:** `DELETE /api/v1/devices/{device_id}`
**Headers:** `Authorization: Bearer {token}`
**Success Response (204):** No content

## 🔗 Webhook Endpoints (Merchant Integration)

### 1. Receive Transaction
**Endpoint:** `POST /api/v1/webhooks/merchant/{merchant_id}/transaction`
**Headers:** `X-API-Key: {merchant_api_key}`, `Content-Type: application/json`
**Request Schema:** WebhookTransactionData
**Response:** WebhookProcessingResult

### 2. Test Transaction
**Endpoint:** `POST /api/v1/webhooks/merchant/{merchant_id}/test-transaction`
**Headers:** `X-API-Key: {merchant_api_key}`, `Content-Type: application/json`
**Request Schema:** TestTransactionRequest
**Response:** WebhookProcessingResult

### 3. Get Webhook Logs
**Endpoint:** `GET /api/v1/webhooks/merchant/{merchant_id}/logs`
**Headers:** `X-API-Key: {merchant_api_key}`
**Response:** WebhookLogListResponse

### 4. Retry Failed Webhook
**Endpoint:** `POST /api/v1/webhooks/logs/{log_id}/retry`
**Headers:** `X-API-Key: {merchant_api_key}`
**Response:**
```json
{
  "log_id": "log_123",
  "retry_initiated": true,
  "retry_at": "2024-01-15T14:30:00Z"
}
```

### 5. Webhook Statistics
**Endpoint:** `GET /api/v1/webhooks/merchant/{merchant_id}/stats`
**Headers:** `X-API-Key: {merchant_api_key}`
**Response:**
```json
{
  "total_webhooks": 1250,
  "successful_webhooks": 1200,
  "failed_webhooks": 50,
  "success_rate": 96.0,
  "last_24h": {
    "total": 45,
    "successful": 43,
    "failed": 2
  }
}
```

## 💰 Budget Management Endpoints

### 1. Create User Budget
**Endpoint:** `POST /api/v1/budget`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "total_monthly_budget": 3000.00,
  "currency": "TRY",
  "auto_allocate": true
}
```
**Success Response (201):** UserBudgetResponse

### 2. Get User Budget
**Endpoint:** `GET /api/v1/budget`
**Headers:** `Authorization: Bearer {token}`
**Response:** UserBudgetResponse

### 3. Update User Budget
**Endpoint:** `PUT /api/v1/budget`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:** UserBudgetUpdate
**Success Response (200):** UserBudgetResponse

### 4. Create Category Budget
**Endpoint:** `POST /api/v1/budget/categories`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "category_id": "cat_food_123",
  "monthly_limit": 800.00,
  "is_active": true
}
```
**Success Response (201):** BudgetCategoryResponse

### 5. Get Category Budgets
**Endpoint:** `GET /api/v1/budget/categories`
**Headers:** `Authorization: Bearer {token}`
**Response:**
```json
{
  "category_budgets": [
    {
      "id": "budget_cat_123",
      "user_id": "user_123",
      "category_id": "cat_food_123",
      "category_name": "Food",
      "monthly_limit": 800.00,
      "is_active": true,
      "created_at": "2024-01-15T14:30:00Z",
      "updated_at": "2024-01-15T14:30:00Z"
    }
  ]
}
```

### 6. Get Budget Summary
**Endpoint:** `GET /api/v1/budget/summary`
**Headers:** `Authorization: Bearer {token}`
**Response:** BudgetSummaryResponse

### 7. Apply Budget Allocation
**Endpoint:** `POST /api/v1/budget/apply-allocation`
**Headers:** `Authorization: Bearer {token}`, `Content-Type: application/json`
**Request Schema:**
```json
{
  "total_budget": 3000.00,
  "categories": ["Food", "Transportation", "Entertainment"]
}
```
**Success Response (200):** BudgetAllocationResponse

### 8. Delete Category Budget
**Endpoint:** `DELETE /api/v1/budget/categories/{category_id}`
**Headers:** `Authorization: Bearer {token}`
**Success Response (204):** No content

### 9. Budget Health Check
**Endpoint:** `GET /api/v1/budget/health`
**Headers:** None required
**Response:**
```json
{
  "status": "healthy",
  "service": "budget_management",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

## 🔧 Common Response Formats

### Success Response Structure
```json
{
  "data": { /* response data */ },
  "message": "Operation successful",
  "timestamp": "2024-01-15T14:30:00Z"
}
```

### Error Response Structure
```json
{
  "detail": "Error message",
  "error_code": "VALIDATION_ERROR",
  "timestamp": "2024-01-15T14:30:00Z",
  "path": "/api/v1/expenses"
}
```

### Pagination Response Structure
```json
{
  "data": [ /* array of items */ ],
  "total": 156,
  "page": 1,
  "limit": 20,
  "has_next": true,
  "has_previous": false
}
```

## 📋 HTTP Status Codes

- **200 OK**: Successful GET, PUT requests
- **201 Created**: Successful POST requests
- **204 No Content**: Successful DELETE requests
- **400 Bad Request**: Invalid request data
- **401 Unauthorized**: Authentication required or invalid token
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource not found
- **422 Unprocessable Entity**: Validation errors
- **500 Internal Server Error**: Server error

## 🔐 Authentication Requirements

All endpoints except health checks and auth endpoints require:
- **Header**: `Authorization: Bearer {access_token}`
- **Token Type**: JWT
- **Token Expiry**: Configurable (default: 30 minutes)
- **Refresh**: Re-login required when token expires

## 🌐 Base Configuration

- **Base URL**: `http://localhost:8000`
- **API Version**: `/api/v1`
- **Content Type**: `application/json`
- **Timeout**: 30 seconds recommended
- **Rate Limiting**: 100 requests per minute per user

## 📝 Request/Response Schema Definitions

### Core Data Types

#### UserProfile
```json
{
  "id": "string",
  "email": "string",
  "first_name": "string",
  "last_name": "string"
}
```

#### ExpenseItemCreateRequest
```json
{
  "category_id": "string (optional)",
  "item_name": "string (1-200 chars)",
  "amount": "number (> 0)",
  "quantity": "integer (> 0, default: 1)",
  "unit_price": "number (> 0, optional)",
  "kdv_rate": "number (1.0, 10.0, or 20.0, default: 20.0)",
  "notes": "string (max 500 chars, optional)"
}
```

#### CategoryResponse
```json
{
  "id": "string (nullable for system categories)",
  "name": "string",
  "user_id": "string (nullable for system categories)",
  "is_system": "boolean",
  "created_at": "datetime (nullable)",
  "updated_at": "datetime (nullable)"
}
```

#### LoyaltyStatusResponse
```json
{
  "user_id": "string",
  "points": "integer (>= 0)",
  "level": "string (bronze|silver|gold|platinum, nullable)",
  "points_to_next_level": "integer (nullable)",
  "next_level": "string (nullable)",
  "last_updated": "datetime"
}
```

#### ReviewCreateRequest
```json
{
  "rating": "integer (1-5)",
  "comment": "string (max 500 chars, optional)",
  "reviewer_name": "string (max 100 chars, optional)",
  "reviewer_email": "string (max 255 chars, optional)",
  "is_anonymous": "boolean (default: false)",
  "receipt_id": "string (optional)"
}
```

Bu referans dosyası EcoTrack backend'inin tüm güncel endpoint'lerini, request/response şemalarını ve Flutter entegrasyonu için gerekli tüm bilgileri içermektedir. 