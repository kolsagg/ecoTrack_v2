# Loyalty Program System Documentation

## Overview

EcoTrack uygulamasının loyalty program sistemi, kullanıcıların harcamalarına göre puan kazanmalarını ve seviye ilerlemelerini sağlar. Bu sistem, kullanıcı engagement'ını artırmak ve sürekli kullanımı teşvik etmek için tasarlanmıştır.

## Features

### 1. **Loyalty Levels (Sadakat Seviyeleri)**

| Level | Points Required | Multiplier | Benefits |
|-------|----------------|------------|----------|
| **Bronze** | 0 | 1.0x | Base points earning, Standard support |
| **Silver** | 1,000 | 1.2x | 20% bonus points, Priority support, Monthly reports |
| **Gold** | 5,000 | 1.5x | 50% bonus points, Premium support, Advanced analytics, Category bonuses |
| **Platinum** | 15,000 | 2.0x | 100% bonus points, VIP support, Custom reports, Maximum category bonuses, Early feature access |

### 2. **Points Calculation System**

#### Base Points
- **1 point per 1 TRY** spent (base rate)

#### Level Multipliers
- Bronze: 1.0x (no bonus)
- Silver: 1.2x (20% bonus)
- Gold: 1.5x (50% bonus)
- Platinum: 2.0x (100% bonus)

#### Category Bonuses
- **Food**: 1.5x (50% bonus)
- **Grocery**: 1.3x (30% bonus)
- **Fuel**: 1.2x (20% bonus)
- **Restaurant**: 1.4x (40% bonus)

#### Calculation Formula
```
Total Points = Base Points + Level Bonus + Category Bonus

Where:
- Base Points = Amount × 1
- Level Bonus = Base Points × (Level Multiplier - 1.0)
- Category Bonus = Base Points × (Category Multiplier - 1.0)
```

#### Example Calculations

**Bronze Level User - 100 TRY Food Purchase:**
- Base Points: 100 × 1 = 100 points
- Level Bonus: 100 × (1.0 - 1.0) = 0 points
- Category Bonus: 100 × (1.5 - 1.0) = 50 points
- **Total: 150 points**

**Gold Level User - 100 TRY Food Purchase:**
- Base Points: 100 × 1 = 100 points
- Level Bonus: 100 × (1.5 - 1.0) = 50 points
- Category Bonus: 100 × (1.5 - 1.0) = 50 points
- **Total: 200 points**

## API Endpoints

### 1. Get Loyalty Status
```http
GET /api/v1/loyalty/status
Authorization: Bearer {token}
```

**Response:**
```json
{
  "user_id": "uuid",
  "points": 1250,
  "level": "silver",
  "points_to_next_level": 3750,
  "next_level": "gold",
  "last_updated": "2024-01-15T10:30:00Z"
}
```

### 2. Calculate Points
```http
GET /api/v1/loyalty/calculate-points?amount=100&category=food&merchant_name=Restaurant
Authorization: Bearer {token}
```

**Response:**
```json
{
  "base_points": 100,
  "bonus_points": 50,
  "total_points": 150,
  "calculation_details": {
    "amount": 100.0,
    "base_points_per_lira": 1,
    "base_points": 100,
    "current_level": "bronze",
    "level_multiplier": 1.0,
    "level_bonus": 0,
    "category": "food",
    "category_bonus": 50,
    "merchant_name": "Restaurant"
  }
}
```

### 3. Get Loyalty History
```http
GET /api/v1/loyalty/history?limit=10
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "count": 5,
  "history": [
    {
      "expense_id": "uuid",
      "amount": 150.0,
      "estimated_points": 150,
      "merchant_name": "Test Restaurant",
      "date": "2024-01-15T10:30:00Z",
      "notes": "Lunch expense"
    }
  ]
}
```

### 4. Get Loyalty Levels Information
```http
GET /api/v1/loyalty/levels
Authorization: Bearer {token}
```

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

## Database Schema

### loyalty_status Table
```sql
CREATE TABLE loyalty_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    points INTEGER NOT NULL DEFAULT 0,
    level TEXT,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now(),
    UNIQUE(user_id)
);
```

## Implementation Details

### 1. **Automatic Points Awarding**
- Points are automatically awarded when expenses are created
- Integration with expense creation endpoint (`POST /api/v1/expenses`)
- Uses the highest amount expense item's category for bonus calculation
- Fails gracefully - expense creation continues even if loyalty points fail

### 2. **Level Progression**
- Automatic level calculation based on total points
- Level changes are detected and logged
- Users are notified of level changes (future feature)

### 3. **Error Handling**
- Graceful degradation if loyalty service fails
- Comprehensive logging for debugging
- Fallback to Bronze level if calculation fails

### 4. **Performance Considerations**
- Efficient point calculation without complex database queries
- Cached level thresholds and multipliers
- Minimal database calls for status updates

## Usage Examples

### Creating an Expense with Loyalty Points
```python
# When user creates an expense, loyalty points are automatically calculated and awarded
expense_data = {
    "merchant_name": "Migros",
    "items": [
        {"description": "Bread", "amount": 15.0, "category": "grocery"},
        {"description": "Milk", "amount": 8.0, "category": "grocery"}
    ]
}

# Points calculation:
# Total amount: 23 TRY
# Category: grocery (1.3x bonus)
# Bronze level (1.0x multiplier)
# Points earned: 23 + (23 * 0.3) = 30 points
```

### Level Progression Example
```python
# User starts at Bronze (0 points)
# After 1000 TRY spending: 1000 points → Silver level
# After 5000 TRY spending: 5000 points → Gold level
# After 15000 TRY spending: 15000 points → Platinum level
```

## Testing

### Test Coverage
- Points calculation accuracy
- Level progression logic
- API endpoint functionality
- Database integration
- Error handling scenarios

### Test Script
```bash
python test_loyalty_system.py
```

## Future Enhancements

### 1. **Rewards Redemption**
- Point redemption for discounts
- Partner merchant rewards
- Gift card exchanges

### 2. **Advanced Features**
- Seasonal bonus campaigns
- Referral bonuses
- Achievement badges
- Leaderboards

### 3. **Analytics**
- Loyalty engagement metrics
- Point earning patterns
- Level distribution analysis
- ROI tracking

## Configuration

### Environment Variables
```env
# Loyalty system configuration
LOYALTY_BASE_POINTS_PER_LIRA=1
LOYALTY_SILVER_THRESHOLD=1000
LOYALTY_GOLD_THRESHOLD=5000
LOYALTY_PLATINUM_THRESHOLD=15000
```

### Customization
- Point calculation rules can be modified in `LoyaltyService`
- Level thresholds are configurable
- Category bonuses can be adjusted
- Multipliers can be fine-tuned

## Monitoring and Maintenance

### Key Metrics
- Total points awarded daily/monthly
- Level distribution among users
- Category bonus utilization
- Average points per transaction

### Maintenance Tasks
- Regular point balance audits
- Level progression verification
- Performance monitoring
- Database cleanup for old transactions

## Security Considerations

### Data Protection
- User loyalty data is protected by RLS policies
- Points cannot be manually manipulated via API
- Audit trail for all point transactions
- Secure calculation algorithms

### Fraud Prevention
- Point calculation validation
- Expense verification before awarding points
- Rate limiting on point-earning activities
- Monitoring for unusual patterns 