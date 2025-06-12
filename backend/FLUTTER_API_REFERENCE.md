# EcoTrack API Endpoints - Flutter Integration Reference

## 📋 Available Endpoints

The backend contains a total of **45+ endpoints**. Here's the list grouped by categories:

## 🏥 Health Check Endpoints

### 1. Basic Health Check
**Request:**
- Method: `GET`
- URL: `/health`
- Headers: None required
- Body: None

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0"
}
```

### 2. Detailed Health Check
**Request:**
- Method: `GET`
- URL: `/health/detailed`
- Headers: None required
- Body: None

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00Z",
  "version": "1.0.0",
  "database": {
    "status": "connected",
    "response_time_ms": 15
  },
  "services": {
    "ai_service": "operational",
    "notification_service": "operational"
  }
}
```

### 3. Database Health Check
**Request:**
- Method: `GET`
- URL: `/health/database`
- Headers: None required
- Body: None

**Response:**
```json
{
  "database": {
    "status": "connected",
    "response_time_ms": 12,
    "connection_pool": {
      "active": 5,
      "idle": 10,
      "max": 20
    }
  }
}
```

### 4. AI Service Health Check
**Request:**
- Method: `GET`
- URL: `/health/ai`
- Headers: None required
- Body: None

**Response:**
```json
{
  "ai_service": {
    "status": "operational",
    "ollama_enabled": true,
    "models_available": ["llama2", "mistral"],
    "response_time_ms": 250
  }
}
```

### 5. System Metrics
**Request:**
- Method: `GET`
- URL: `/health/metrics`
- Headers: None required
- Body: None

**Response:**
```json
{
  "system": {
    "cpu_usage": 45.2,
    "memory_usage": 67.8,
    "disk_usage": 23.1,
    "uptime_seconds": 86400
  },
  "api": {
    "total_requests": 15420,
    "requests_per_minute": 125,
    "average_response_time_ms": 89
  }
}
```

### 6. Readiness Check
**Request:**
- Method: `GET`
- URL: `/health/ready`
- Headers: None required
- Body: None

**Response:**
```json
{
  "ready": true,
  "services": {
    "database": "ready",
    "ai_service": "ready"
  }
}
```

### 7. Liveness Check
**Request:**
- Method: `GET`
- URL: `/health/live`
- Headers: None required
- Body: None

**Response:**
```json
{
  "alive": true,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## 🔐 Authentication Endpoints

### 1. Login
**Request:**
- Method: `POST`
- URL: `/api/v1/auth/login`
- Headers: `Content-Type: application/json`
- Body:
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
  "expires_in": 3600,
  "user": {
    "id": "user_123",
    "email": "user@example.com",
    "created_at": "2024-01-01T00:00:00Z",
    "is_verified": true
  }
}
```

**Error Response (401):**
```json
{
  "detail": "Invalid email or password"
}
```

### 2. Register
**Request:**
- Method: `POST`
- URL: `/api/v1/auth/register`
- Headers: `Content-Type: application/json`
- Body:
```json
{
  "email": "newuser@example.com",
  "password": "securepassword123"
}
```

**Success Response (201):**
```json
{
  "message": "User registered successfully",
  "user": {
    "id": "user_456",
    "email": "newuser@example.com",
    "created_at": "2024-01-15T10:30:00Z",
    "is_verified": false
  }
}
```

**Error Response (400):**
```json
{
  "detail": "Email already registered"
}
```

### 3. Password Reset
**Request:**
- Method: `POST`
- URL: `/api/v1/auth/reset-password`
- Headers: `Content-Type: application/json`
- Body:
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

### 4. MFA Status
**Request:**
- Method: `GET`
- URL: `/api/v1/auth/mfa/status`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "mfa_enabled": false,
  "available_methods": ["totp", "sms"],
  "backup_codes_count": 0
}
```

### 5. Create TOTP MFA
**Request:**
- Method: `POST`
- URL: `/api/v1/auth/mfa/totp/create`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "secret": "JBSWY3DPEHPK3PXP",
  "qr_code": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "backup_codes": ["12345678", "87654321", "..."]
}
```

## 🧾 Receipt Endpoints

### 1. QR Code Scan
**Request:**
- Method: `POST`
- URL: `/api/v1/receipts/scan`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "qr_data": "https://efatura.gov.tr/qr?p=..."
}
```

**Success Response (200):**
```json
{
  "receipt": {
    "id": "receipt_123",
    "merchant_name": "Migros",
    "date": "2024-01-15T14:30:00Z",
    "total_amount": 125.50,
    "tax_amount": 22.59,
    "receipt_number": "FIS001234"
  },
  "items": [
    {
      "name": "Bread",
      "quantity": 2,
      "unit_price": 3.50,
      "total_price": 7.00,
      "category": "Food"
    },
    {
      "name": "Milk",
      "quantity": 1,
      "unit_price": 8.50,
      "total_price": 8.50,
      "category": "Dairy"
    }
  ]
}
```

**Error Response (400):**
```json
{
  "detail": "Invalid QR code format"
}
```

### 2. List Receipts
**Request:**
- Method: `GET`
- URL: `/api/v1/receipts?limit=20&offset=0`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Query Parameters:**
- `limit` (optional): Number of receipts to return (default: 50)
- `offset` (optional): Number of receipts to skip (default: 0)
- `start_date` (optional): Filter by date (YYYY-MM-DD)
- `end_date` (optional): Filter by date (YYYY-MM-DD)

**Response:**
```json
{
  "receipts": [
    {
      "id": "receipt_123",
      "merchant_name": "Migros",
      "date": "2024-01-15T14:30:00Z",
      "total_amount": 125.50,
      "items_count": 8
    }
  ],
  "total": 45,
  "limit": 20,
  "offset": 0
}
```

### 3. Receipt Detail
**Request:**
- Method: `GET`
- URL: `/api/v1/receipts/{receipt_id}`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "id": "receipt_123",
  "merchant_name": "Migros",
  "date": "2024-01-15T14:30:00Z",
  "total_amount": 125.50,
  "tax_amount": 22.59,
  "receipt_number": "FIS001234",
  "items": [
    {
      "name": "Bread",
      "quantity": 2,
      "unit_price": 3.50,
      "total_price": 7.00,
      "category": "Food"
    }
  ],
  "metadata": {
    "scan_date": "2024-01-15T14:35:00Z",
    "processing_time_ms": 1250
  }
}
```

## 💰 Expense Endpoints

### 1. Create Expense
**Request:**
- Method: `POST`
- URL: `/api/v1/expenses`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "description": "Grocery shopping",
  "amount": 125.50,
  "category_id": "cat_food_123",
  "merchant_id": "merchant_migros_456",
  "receipt_id": "receipt_789",
  "metadata": {
    "payment_method": "credit_card",
    "notes": "Weekly groceries"
  }
}
```

**Success Response (201):**
```json
{
  "id": "expense_123",
  "description": "Grocery shopping",
  "amount": 125.50,
  "category_id": "cat_food_123",
  "merchant_id": "merchant_migros_456",
  "receipt_id": "receipt_789",
  "created_at": "2024-01-15T14:30:00Z",
  "updated_at": "2024-01-15T14:30:00Z",
  "metadata": {
    "payment_method": "credit_card",
    "notes": "Weekly groceries"
  }
}
```

**Error Response (400):**
```json
{
  "detail": "Invalid category_id"
}
```

### 2. List Expenses
**Request:**
- Method: `GET`
- URL: `/api/v1/expenses?limit=20&offset=0&category=food&start_date=2024-01-01&end_date=2024-01-31`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Query Parameters:**
- `limit` (optional): Number of expenses to return
- `offset` (optional): Number of expenses to skip
- `category` (optional): Filter by category name
- `start_date` (optional): Filter by date (YYYY-MM-DD)
- `end_date` (optional): Filter by date (YYYY-MM-DD)
- `min_amount` (optional): Minimum amount filter
- `max_amount` (optional): Maximum amount filter

**Response:**
```json
{
  "expenses": [
    {
      "id": "expense_123",
      "description": "Grocery shopping",
      "amount": 125.50,
      "category": {
        "id": "cat_food_123",
        "name": "Food",
        "color": "#FF5722"
      },
      "merchant": {
        "id": "merchant_migros_456",
        "name": "Migros"
      },
      "created_at": "2024-01-15T14:30:00Z"
    }
  ],
  "total": 156,
  "limit": 20,
  "offset": 0,
  "summary": {
    "total_amount": 2450.75,
    "average_amount": 15.71
  }
}
```

### 3. Update Expense
**Request:**
- Method: `PUT`
- URL: `/api/v1/expenses/{expense_id}`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "description": "Updated grocery shopping",
  "amount": 135.75,
  "category_id": "cat_food_123"
}
```

**Success Response (200):**
```json
{
  "id": "expense_123",
  "description": "Updated grocery shopping",
  "amount": 135.75,
  "category_id": "cat_food_123",
  "updated_at": "2024-01-15T15:00:00Z"
}
```

### 4. Delete Expense
**Request:**
- Method: `DELETE`
- URL: `/api/v1/expenses/{expense_id}`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Success Response (204):**
No content

**Error Response (404):**
```json
{
  "detail": "Expense not found"
}
```

## 📂 Category Endpoints

### 1. List Categories
**Request:**
- Method: `GET`
- URL: `/api/v1/categories`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "categories": [
    {
      "id": "cat_food_123",
      "name": "Food",
      "description": "Food and groceries",
      "color": "#FF5722",
      "icon": "restaurant",
      "expense_count": 45,
      "total_amount": 1250.75
    },
    {
      "id": "cat_transport_456",
      "name": "Transportation",
      "description": "Public transport, fuel, etc.",
      "color": "#2196F3",
      "icon": "directions_car",
      "expense_count": 23,
      "total_amount": 890.50
    }
  ]
}
```

### 2. Create Category
**Request:**
- Method: `POST`
- URL: `/api/v1/categories`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "name": "Entertainment",
  "description": "Movies, games, etc.",
  "color": "#9C27B0",
  "icon": "movie"
}
```

**Success Response (201):**
```json
{
  "id": "cat_entertainment_789",
  "name": "Entertainment",
  "description": "Movies, games, etc.",
  "color": "#9C27B0",
  "icon": "movie",
  "created_at": "2024-01-15T14:30:00Z"
}
```

### 3. Update Category
**Request:**
- Method: `PUT`
- URL: `/api/v1/categories/{category_id}`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "name": "Entertainment & Fun",
  "color": "#E91E63"
}
```

**Success Response (200):**
```json
{
  "id": "cat_entertainment_789",
  "name": "Entertainment & Fun",
  "description": "Movies, games, etc.",
  "color": "#E91E63",
  "icon": "movie",
  "updated_at": "2024-01-15T15:00:00Z"
}
```

### 4. Delete Category
**Request:**
- Method: `DELETE`
- URL: `/api/v1/categories/{category_id}`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Success Response (204):**
No content

**Error Response (400):**
```json
{
  "detail": "Cannot delete category with existing expenses"
}
```

## 🤖 AI Analysis Endpoints

### 1. Spending Summary
**Request:**
- Method: `GET`
- URL: `/api/v1/api/ai/analytics/summary?period=month`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Query Parameters:**
- `period`: "week", "month", "quarter", "year" (default: "month")

**Response:**
```json
{
  "period": "month",
  "total_spent": 2450.75,
  "transaction_count": 156,
  "average_per_transaction": 15.71,
  "category_breakdown": [
    {
      "category": "Food",
      "amount": 1250.75,
      "percentage": 51.0,
      "transaction_count": 45
    },
    {
      "category": "Transportation",
      "amount": 890.50,
      "percentage": 36.3,
      "transaction_count": 23
    }
  ],
  "trends": {
    "vs_previous_period": {
      "amount_change": 125.50,
      "percentage_change": 5.4,
      "trend": "increasing"
    }
  },
  "insights": [
    "Your food spending increased by 15% this month",
    "You saved 8% on transportation costs"
  ]
}
```

### 2. Saving Suggestions
**Request:**
- Method: `GET`
- URL: `/api/v1/api/ai/suggestions/savings`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "suggestions": [
    {
      "id": "suggestion_1",
      "type": "category_optimization",
      "category": "Food",
      "title": "Reduce food expenses",
      "description": "You're spending 20% more on food than similar users",
      "potential_savings": 250.00,
      "confidence": 0.85,
      "actionable_tips": [
        "Plan meals in advance",
        "Buy generic brands",
        "Cook at home more often"
      ]
    },
    {
      "id": "suggestion_2",
      "type": "merchant_optimization",
      "title": "Switch grocery stores",
      "description": "You could save by shopping at different stores",
      "potential_savings": 75.00,
      "confidence": 0.72,
      "recommended_merchants": [
        "BIM",
        "A101"
      ]
    }
  ],
  "total_potential_savings": 325.00
}
```

### 3. Budget Suggestions
**Request:**
- Method: `GET`
- URL: `/api/v1/api/ai/suggestions/budget`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "recommended_budget": {
    "total_monthly": 2200.00,
    "categories": [
      {
        "category": "Food",
        "suggested_amount": 1000.00,
        "current_average": 1250.75,
        "adjustment": -250.75
      },
      {
        "category": "Transportation",
        "suggested_amount": 800.00,
        "current_average": 890.50,
        "adjustment": -90.50
      }
    ]
  },
  "rationale": "Based on your income and spending patterns, this budget allows for 15% savings",
  "confidence": 0.78
}
```

### 4. Spending Pattern Analysis
**Request:**
- Method: `POST`
- URL: `/api/v1/api/ai/analysis/spending-patterns`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "period": "month",
  "analysis_type": "detailed"
}
```

**Response:**
```json
{
  "patterns": {
    "weekly_distribution": {
      "monday": 12.5,
      "tuesday": 8.3,
      "wednesday": 15.7,
      "thursday": 18.2,
      "friday": 22.1,
      "saturday": 15.8,
      "sunday": 7.4
    },
    "time_of_day": {
      "morning": 25.3,
      "afternoon": 45.2,
      "evening": 29.5
    },
    "seasonal_trends": [
      {
        "period": "January",
        "spending_index": 0.85,
        "note": "Lower spending after holidays"
      }
    ]
  },
  "anomalies": [
    {
      "date": "2024-01-10",
      "amount": 450.00,
      "expected_range": "50-150",
      "category": "Food",
      "note": "Unusually high food spending"
    }
  ],
  "recommendations": [
    "Consider setting spending limits for Fridays",
    "Your evening spending is higher than average"
  ]
}
```

## 📊 Reports Endpoints

### 1. Dashboard Data
**Request:**
- Method: `GET`
- URL: `/api/v1/reports/dashboard?period=month`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Query Parameters:**
- `period`: "week", "month", "quarter", "year"

**Response:**
```json
{
  "summary": {
    "total_expenses": 2450.75,
    "transaction_count": 156,
    "average_per_day": 79.06,
    "budget_usage": 0.78
  },
  "top_categories": [
    {
      "category": "Food",
      "amount": 1250.75,
      "percentage": 51.0
    },
    {
      "category": "Transportation",
      "amount": 890.50,
      "percentage": 36.3
    }
  ],
  "monthly_trend": [
    {
      "month": "2024-01",
      "amount": 2450.75
    },
    {
      "month": "2023-12",
      "amount": 2325.25
    }
  ],
  "recent_transactions": [
    {
      "id": "expense_123",
      "description": "Grocery shopping",
      "amount": 125.50,
      "category": "Food",
      "date": "2024-01-15T14:30:00Z"
    }
  ]
}
```

### 2. Spending Distribution
**Request:**
- Method: `GET`
- URL: `/api/v1/reports/spending-distribution?group_by=category&start_date=2024-01-01&end_date=2024-01-31`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Query Parameters:**
- `group_by`: "category", "merchant", "day", "month"
- `start_date`: Start date (YYYY-MM-DD)
- `end_date`: End date (YYYY-MM-DD)

**Response:**
```json
{
  "distribution": [
    {
      "label": "Food",
      "amount": 1250.75,
      "percentage": 51.0,
      "transaction_count": 45
    },
    {
      "label": "Transportation",
      "amount": 890.50,
      "percentage": 36.3,
      "transaction_count": 23
    }
  ],
  "total_amount": 2450.75,
  "period": {
    "start_date": "2024-01-01",
    "end_date": "2024-01-31"
  }
}
```

### 3. Spending Trends
**Request:**
- Method: `GET`
- URL: `/api/v1/reports/spending-trends?period=month&months=6`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Query Parameters:**
- `period`: "day", "week", "month"
- `months`: Number of months to include (default: 6)

**Response:**
```json
{
  "trends": [
    {
      "period": "2024-01",
      "amount": 2450.75,
      "transaction_count": 156,
      "change_from_previous": 5.4
    },
    {
      "period": "2023-12",
      "amount": 2325.25,
      "transaction_count": 142,
      "change_from_previous": -2.1
    }
  ],
  "overall_trend": "increasing",
  "average_monthly": 2287.50,
  "projection": {
    "next_month": 2580.00,
    "confidence": 0.72
  }
}
```

## 🏆 Loyalty Program Endpoints

### 1. Loyalty Status
**Request:**
- Method: `GET`
- URL: `/api/v1/loyalty/status`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "current_points": 1250,
  "level": "Silver",
  "next_level": "Gold",
  "points_to_next_level": 750,
  "level_benefits": [
    "5% cashback on groceries",
    "Free monthly report"
  ],
  "next_level_benefits": [
    "8% cashback on groceries",
    "Priority customer support",
    "Advanced analytics"
  ],
  "points_history": [
    {
      "date": "2024-01-15",
      "points": 25,
      "reason": "Receipt scan",
      "expense_id": "expense_123"
    }
  ]
}
```

### 2. Calculate Points
**Request:**
- Method: `GET`
- URL: `/api/v1/loyalty/calculate-points`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "total_points": 1250,
  "breakdown": {
    "receipt_scans": 450,
    "expense_tracking": 600,
    "monthly_goals": 200
  },
  "pending_points": 75,
  "next_calculation": "2024-02-01T00:00:00Z"
}
```

## 📱 Device Management Endpoints

### 1. Register Device
**Request:**
- Method: `POST`
- URL: `/api/v1/devices/register`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "device_id": "android_device_123",
  "device_type": "android",
  "fcm_token": "fcm_token_xyz789",
  "metadata": {
    "app_version": "1.0.0",
    "os_version": "Android 13",
    "device_model": "Samsung Galaxy S23"
  }
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

### 2. Update FCM Token
**Request:**
- Method: `PUT`
- URL: `/api/v1/devices/{device_id}/fcm-token`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "fcm_token": "new_fcm_token_abc123"
}
```

**Success Response (200):**
```json
{
  "device_id": "android_device_123",
  "fcm_token": "new_fcm_token_abc123",
  "updated_at": "2024-01-15T15:00:00Z"
}
```

## 🏪 Merchant Endpoints

### 1. List Merchants
**Request:**
- Method: `GET`
- URL: `/api/v1/merchants/`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "merchants": [
    {
      "id": "merchant_migros_123",
      "name": "Migros",
      "category": "Grocery",
      "logo_url": "https://example.com/logos/migros.png",
      "rating": 4.2,
      "review_count": 1250,
      "locations": [
        {
          "address": "Kadıköy, Istanbul",
          "coordinates": {
            "lat": 40.9923,
            "lng": 29.0244
          }
        }
      ]
    }
  ]
}
```

### 2. Merchant Detail
**Request:**
- Method: `GET`
- URL: `/api/v1/merchants/{merchant_id}`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "id": "merchant_migros_123",
  "name": "Migros",
  "category": "Grocery",
  "description": "Leading grocery chain in Turkey",
  "logo_url": "https://example.com/logos/migros.png",
  "rating": 4.2,
  "review_count": 1250,
  "locations": [
    {
      "id": "location_123",
      "address": "Kadıköy, Istanbul",
      "coordinates": {
        "lat": 40.9923,
        "lng": 29.0244
      },
      "phone": "+90 216 123 4567",
      "hours": {
        "monday": "08:00-22:00",
        "tuesday": "08:00-22:00"
      }
    }
  ],
  "user_stats": {
    "total_visits": 45,
    "total_spent": 1250.75,
    "last_visit": "2024-01-15T14:30:00Z"
  }
}
```

## ⭐ Review Endpoints

### 1. Submit Merchant Review
**Request:**
- Method: `POST`
- URL: `/api/v1/reviews/merchants/{merchant_id}/reviews`
- Headers: `Authorization: Bearer {token}`, `Content-Type: application/json`
- Body:
```json
{
  "rating": 4,
  "comment": "Great service and good prices",
  "visit_date": "2024-01-15"
}
```

**Success Response (201):**
```json
{
  "id": "review_123",
  "rating": 4,
  "comment": "Great service and good prices",
  "visit_date": "2024-01-15",
  "created_at": "2024-01-15T15:00:00Z",
  "merchant": {
    "id": "merchant_migros_123",
    "name": "Migros"
  }
}
```

### 2. Get Merchant Reviews
**Request:**
- Method: `GET`
- URL: `/api/v1/reviews/merchants/{merchant_id}/reviews?limit=10&offset=0`
- Headers: `Authorization: Bearer {token}`
- Body: None

**Response:**
```json
{
  "reviews": [
    {
      "id": "review_123",
      "rating": 4,
      "comment": "Great service and good prices",
      "visit_date": "2024-01-15",
      "created_at": "2024-01-15T15:00:00Z",
      "user": {
        "id": "user_456",
        "name": "Anonymous"
      }
    }
  ],
  "total": 1250,
  "average_rating": 4.2,
  "rating_distribution": {
    "5": 625,
    "4": 375,
    "3": 150,
    "2": 75,
    "1": 25
  }
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
  "limit": 20,
  "offset": 0,
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
- **Token Expiry**: 1 hour (3600 seconds)
- **Refresh**: Re-login required when token expires

## 🌐 Base Configuration

- **Base URL**: `http://localhost:8000`
- **API Version**: `/api/v1`
- **Content Type**: `application/json`
- **Timeout**: 30 seconds recommended
- **Rate Limiting**: 100 requests per minute per user

This reference provides all the request/response formats needed to integrate EcoTrack backend with Flutter frontend. Use this alongside the integration guide for complete implementation details. 