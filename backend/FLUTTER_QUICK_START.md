# EcoTrack Flutter Frontend - Quick Start Checklist

Bu rehber, EcoTrack backend API'sini Flutter uygulamasında hızlıca kullanmaya başlamanız için hazırlanmıştır.

## 📋 API Özeti

Backend'de toplam **45+ endpoint** bulunmaktadır:

- 🏥 **Health Check** (7 endpoint)
- 🔐 **Authentication** (8 endpoint)  
- 🧾 **Receipt Management** (5 endpoint)
- 💰 **Expense Management** (8 endpoint)
- 📂 **Category Management** (3 endpoint)
- 🏪 **Merchant Management** (6 endpoint)
- ⭐ **Review System** (7 endpoint)
- 🤖 **AI Analysis** (9 endpoint)
- 📊 **Financial Reporting** (9 endpoint)
- 🏆 **Loyalty Program** (4 endpoint)
- 📱 **Device Management** (4 endpoint)
- 🔗 **Webhooks** (5 endpoint)

## ✅ Prerequisites

### 1. Backend Preparation
- [ ] Check if backend is running: `http://localhost:8000`
- [ ] Access API documentation: `http://localhost:8000/docs`
- [ ] Test health check endpoint: `http://localhost:8000/health`

### 2. Flutter Setup
- [ ] Check if Flutter SDK is installed: `flutter doctor`
- [ ] Android Studio/VS Code installed
- [ ] Android emulator or physical device ready

## 🚀 Project Setup

### 1. Create Flutter Project
```bash
flutter create ecotrack_app
cd ecotrack_app
```

### 2. Add Dependencies to pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP Client
  http: ^1.1.0
  dio: ^5.3.2  # Alternative
  
  # Data Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # State Management
  provider: ^6.1.1
  # or
  # bloc: ^8.1.2
  # flutter_bloc: ^8.1.3
  
  # JSON Serialization
  json_annotation: ^4.8.1
  
  # QR Code Scanner
  qr_code_scanner: ^1.0.1
  
  # Charts (for Reports)
  fl_chart: ^0.64.0
  
  # UI Components
  cupertino_icons: ^1.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
  flutter_lints: ^2.0.0
```

### 3. Install Dependencies
```bash
flutter pub get
```

## 📁 Create Project Structure

### 1. Create Directory Structure
```
lib/
├── main.dart
├── config/
│   ├── api_config.dart          # API URL and settings
│   └── app_config.dart          # Application configuration
├── core/
│   ├── constants/               # Constants
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── errors/                  # Error classes
│   │   ├── exceptions.dart
│   │   └── error_handler.dart
│   └── utils/                   # Helper functions
│       ├── date_utils.dart
│       └── format_utils.dart
├── data/
│   ├── models/                  # Data models
│   │   ├── user_model.dart
│   │   ├── expense_model.dart
│   │   ├── receipt_model.dart
│   │   └── category_model.dart
│   └── repositories/            # Data access layer
│       ├── auth_repository.dart
│       ├── expense_repository.dart
│       └── receipt_repository.dart
├── services/
│   ├── api_service.dart         # HTTP client service
│   ├── auth_service.dart        # Authentication
│   ├── expense_service.dart     # Expense operations
│   ├── receipt_service.dart     # Receipt operations
│   └── storage_service.dart     # Local storage
├── presentation/
│   ├── pages/                   # Page widgets
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── dashboard_page.dart
│   │   ├── expenses/
│   │   │   ├── expense_list_page.dart
│   │   │   └── add_expense_page.dart
│   │   ├── receipts/
│   │   │   ├── receipt_list_page.dart
│   │   │   └── qr_scanner_page.dart
│   │   └── reports/
│   │       └── reports_page.dart
│   ├── widgets/                 # Common widgets
│   │   ├── common/
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   └── charts/
│   │       └── expense_chart.dart
│   └── providers/               # State management
│       ├── auth_provider.dart
│       ├── expense_provider.dart
│       └── receipt_provider.dart
└── routes/
    └── app_routes.dart          # Navigation
```

## 🔧 Create Basic Files

### 1. API Configuration (lib/config/api_config.dart)
- Base URL: `http://localhost:8000`
- API Version: `/api/v1`
- Default headers: Content-Type, Accept
- Auth headers: Authorization Bearer token
- Timeout settings: 30 seconds

### 2. Auth Service (lib/services/auth_service.dart)
- Login/Register methods
- Token storage (FlutterSecureStorage)
- Token validation
- Logout operation
- Auto-login check

### 3. Main App (lib/main.dart)
- MultiProvider setup
- AuthWrapper widget
- Theme configuration
- Route management
- Initial authentication check

## 🔐 Authentication Implementation

### 1. Auth Provider (lib/presentation/providers/auth_provider.dart)
**State Variables:**
- `isAuthenticated`: bool
- `isLoading`: bool
- `userData`: Map<String, dynamic>?
- `error`: String?

**Methods:**
- `checkAuthStatus()`: Token check
- `login(email, password)`: Login operation
- `logout()`: Logout operation

### 2. Login Page (lib/presentation/pages/auth/login_page.dart)
**UI Elements:**
- Email TextFormField
- Password TextFormField
- Login Button
- Loading indicator
- Error messages
- Form validation

**Functionality:**
- Form validation
- Auth provider integration
- Navigation after login
- Error handling

## 📱 Testing

### 1. Start Backend
```bash
cd /Users/emrekolunsag/dev/PROJECTS/EcoTrack/backend
source venv/bin/activate
python main.py
```

### 2. Run Flutter App
```bash
cd ecotrack_app
flutter run
```

### 3. Test Scenarios
- [ ] Login page opens?
- [ ] Backend connection established?
- [ ] Login operation works?
- [ ] Token is saved?
- [ ] Navigation to home page works?

## 🔍 Debug Tips

### 1. Network Permissions (Android)
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 2. HTTP Traffic Monitoring
Log HTTP requests in debug mode:
- Request method and URL
- Headers
- Request/Response body
- Status codes

### 3. Common Errors and Solutions
- **Connection refused**: Check if backend is running
- **CORS error**: Are backend CORS settings correct?
- **401 Unauthorized**: Is token sent correctly?
- **JSON decode error**: Is response format correct?

## 📄 Required Pages/Screens

### 1. Authentication Pages
- [ ] **Login Page** (`lib/presentation/pages/auth/login_page.dart`)
  - Email/password input fields
  - Login button with loading state
  - "Forgot Password" link
  - "Register" navigation link
  - Form validation and error display

- [ ] **Register Page** (`lib/presentation/pages/auth/register_page.dart`)
  - Email/password input fields
  - Confirm password field
  - Register button with loading state
  - Terms & conditions checkbox
  - "Already have account" login link

- [ ] **Forgot Password Page** (`lib/presentation/pages/auth/forgot_password_page.dart`)
  - Email input field
  - Send reset email button
  - Success/error message display
  - Back to login navigation

### 2. Main Navigation Pages
- [ ] **Home/Dashboard Page** (`lib/presentation/pages/home/dashboard_page.dart`)
  - Monthly spending summary
  - Recent transactions list
  - Quick action buttons (Add Expense, Scan Receipt)
  - Spending charts/graphs
  - Category breakdown

- [ ] **Expenses Page** (`lib/presentation/pages/expenses/expense_list_page.dart`)
  - Filterable expense list
  - Search functionality
  - Date range picker
  - Category filter dropdown
  - Expense item cards with edit/delete options

- [ ] **Receipts Page** (`lib/presentation/pages/receipts/receipt_list_page.dart`)
  - Receipt list with thumbnails
  - QR scan button (floating action button)
  - Receipt details navigation
  - Date filtering options

- [ ] **Reports Page** (`lib/presentation/pages/reports/reports_page.dart`)
  - Interactive charts (pie, bar, line)
  - Spending trends analysis
  - Category-wise breakdown
  - Monthly/yearly comparisons
  - Export functionality

- [ ] **Profile/Settings Page** (`lib/presentation/pages/profile/profile_page.dart`)
  - User information display
  - App settings (theme, notifications)
  - Account management options
  - Logout functionality

### 3. Secondary Pages
- [ ] **Add/Edit Expense Page** (`lib/presentation/pages/expenses/add_expense_page.dart`)
  - Amount input field
  - Description text field
  - Category selection dropdown
  - Merchant selection (optional)
  - Date picker
  - Save/Update buttons

- [ ] **QR Scanner Page** (`lib/presentation/pages/receipts/qr_scanner_page.dart`)
  - Camera view for QR scanning
  - Scan result processing
  - Manual entry option
  - Flash toggle button
  - Gallery selection option

- [ ] **Receipt Detail Page** (`lib/presentation/pages/receipts/receipt_detail_page.dart`)
  - Receipt information display
  - Item list with details
  - Total amount breakdown
  - Add to expenses button
  - Share/export options

- [ ] **Category Management Page** (`lib/presentation/pages/categories/category_page.dart`)
  - Category list with icons/colors
  - Add new category button
  - Edit/delete category options
  - Category usage statistics

- [ ] **Expense Detail Page** (`lib/presentation/pages/expenses/expense_detail_page.dart`)
  - Full expense information
  - Associated receipt (if any)
  - Edit/delete buttons
  - Category and merchant details

### 4. AI & Analytics Pages
- [ ] **AI Insights Page** (`lib/presentation/pages/ai/insights_page.dart`)
  - Spending pattern analysis
  - Saving suggestions
  - Budget recommendations
  - Spending alerts/warnings

- [ ] **Budget Page** (`lib/presentation/pages/budget/budget_page.dart`)
  - Monthly budget setup
  - Category-wise budget allocation
  - Budget vs actual spending
  - Progress indicators

### 5. Additional Features Pages
- [ ] **Loyalty Status Page** (`lib/presentation/pages/loyalty/loyalty_page.dart`)
  - Current points display
  - Level information
  - Benefits overview
  - Points history

- [ ] **Merchant Reviews Page** (`lib/presentation/pages/merchants/merchant_page.dart`)
  - Merchant list
  - Review submission
  - Rating display
  - Location information

- [ ] **Notifications Page** (`lib/presentation/pages/notifications/notifications_page.dart`)
  - Notification list
  - Mark as read functionality
  - Notification settings
  - Clear all option

### 6. Utility Pages
- [ ] **Splash Screen** (`lib/presentation/pages/splash/splash_page.dart`)
  - App logo display
  - Loading animation
  - Auto-login check
  - Navigation to appropriate page

- [ ] **Onboarding Pages** (`lib/presentation/pages/onboarding/onboarding_page.dart`)
  - App feature introduction
  - Tutorial slides
  - Skip/Next navigation
  - Get started button

- [ ] **Error Page** (`lib/presentation/pages/error/error_page.dart`)
  - Error message display
  - Retry button
  - Home navigation option
  - Error reporting functionality

### 7. Settings Sub-Pages
- [ ] **Account Settings** (`lib/presentation/pages/settings/account_settings_page.dart`)
  - Change password
  - Email verification
  - Account deletion
  - Data export

- [ ] **App Preferences** (`lib/presentation/pages/settings/preferences_page.dart`)
  - Theme selection (light/dark)
  - Language settings
  - Currency preferences
  - Notification preferences

- [ ] **Privacy & Security** (`lib/presentation/pages/settings/privacy_page.dart`)
  - Biometric authentication toggle
  - Data sharing preferences
  - Privacy policy
  - Terms of service

## 📱 Navigation Structure

### Bottom Navigation Bar (Main Tabs)
1. **Home** - Dashboard with overview
2. **Expenses** - Expense list and management
3. **Receipts** - Receipt scanning and history
4. **Reports** - Analytics and insights
5. **Profile** - User settings and account

### Floating Action Buttons
- **Add Expense** (on Expenses tab)
- **Scan Receipt** (on Receipts tab)
- **Quick Add** (on Home tab)

### App Bar Actions
- **Search** (on list pages)
- **Filter** (on list pages)
- **Settings** (on main pages)
- **Notifications** (on home page)

## 📚 Next Steps

### 1. Basic Features
- [ ] Implement authentication flow
- [ ] Create main navigation structure
- [ ] Add QR code scanner functionality
- [ ] Build expense CRUD operations
- [ ] Implement basic reporting

### 2. Advanced Features
- [ ] Add AI insights integration
- [ ] Implement offline support
- [ ] Add push notifications
- [ ] Include biometric authentication
- [ ] Create dark mode theme

### 3. Testing and Optimization
- [ ] Unit tests for services
- [ ] Widget tests for UI components
- [ ] Integration tests for user flows
- [ ] Performance optimization
- [ ] Error handling improvements

## 🌐 API Integration

### Request/Response Formats
For detailed API endpoints and formats, refer to `FLUTTER_API_REFERENCE.md` file.

### Main Endpoint Categories:
- **Authentication**: Login, Register, Password Reset
- **Receipts**: QR Scan, List, Detail
- **Expenses**: CRUD operations, Filtering
- **Categories**: List, Create, Update
- **AI Analysis**: Spending Summary, Suggestions
- **Reports**: Dashboard, Trends, Distribution
- **Loyalty**: Status, Points calculation
- **Merchants**: List, Reviews
- **Device Management**: Registration, FCM tokens

### HTTP Status Codes:
- **200**: Success
- **201**: Created
- **204**: No Content (Delete)
- **400**: Bad Request
- **401**: Unauthorized
- **404**: Not Found
- **500**: Internal Server Error

## 🆘 Help Resources

- **Backend API Documentation**: `http://localhost:8000/docs`
- **API Reference**: `FLUTTER_API_REFERENCE.md`
- **Integration Guide**: `FLUTTER_INTEGRATION_GUIDE.md`
- **Flutter Documentation**: https://docs.flutter.dev/
- **Provider Package**: https://pub.dev/packages/provider
- **HTTP Package**: https://pub.dev/packages/http

By following this checklist, you can quickly set up and integrate EcoTrack Flutter frontend with the backend! 