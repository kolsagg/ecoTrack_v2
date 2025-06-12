# EcoTrack Backend - Flutter Frontend Integration Guide

Bu rehber, EcoTrack backend API'sini Flutter uygulamasında nasıl entegre edeceğinizi gösterir.

## 📋 Genel Bakış

EcoTrack backend'i **45+ endpoint** içerir ve aşağıdaki ana kategorilerde gruplandırılmıştır:

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

## 📋 Table of Contents
1. [Backend Setup](#backend-setup)
2. [Flutter Project Structure](#flutter-project-structure)
3. [Required Packages](#required-packages)
4. [Authentication System](#authentication-system)
5. [API Integration](#api-integration)
6. [State Management](#state-management)
7. [Error Handling](#error-handling)

## 🚀 Backend Setup

### Starting the Backend
```bash
cd /Users/emrekolunsag/dev/PROJECTS/EcoTrack/backend
source venv/bin/activate
python main.py
```

The backend will run on `http://localhost:8000`.

### API Documentation
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **Health Check**: `http://localhost:8000/health`

## 📱 Flutter Project Structure

Recommended directory structure:

```
lib/
├── main.dart
├── config/
│   ├── api_config.dart          # API URL and settings
│   └── app_config.dart          # Application configuration
├── core/
│   ├── constants/               # Constants
│   ├── errors/                  # Error classes
│   └── utils/                   # Helper functions
├── data/
│   ├── models/                  # Data models
│   └── repositories/            # Data access layer
├── services/
│   ├── api_service.dart         # HTTP client service
│   ├── auth_service.dart        # Authentication
│   ├── expense_service.dart     # Expense operations
│   ├── receipt_service.dart     # Receipt operations
│   └── storage_service.dart     # Local storage
├── presentation/
│   ├── pages/                   # Page widgets
│   ├── widgets/                 # Common widgets
│   └── providers/               # State management
└── routes/
    └── app_routes.dart          # Navigation
```

## 📦 Required Packages

### pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP Client
  http: ^1.1.0
  dio: ^5.3.2  # Alternative HTTP client
  
  # Data Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # State Management
  provider: ^6.1.1
  # or bloc: ^8.1.2 / riverpod: ^2.4.0
  
  # JSON Processing
  json_annotation: ^4.8.1
  
  # QR Code Scanner
  qr_code_scanner: ^1.0.1
  mobile_scanner: ^3.5.2  # Alternative
  
  # Charts and UI
  fl_chart: ^0.64.0
  cupertino_icons: ^1.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
  flutter_lints: ^2.0.0
```

## 🔐 Authentication System

### Token Management
- **JWT Token**: Access token received from backend
- **Secure Storage**: Store token securely
- **Auto Refresh**: Token renewal mechanism
- **Logout**: Clear token and redirect to login

### Auth Flow
1. **Login**: Login with email/password
2. **Token Storage**: Save to secure storage
3. **Auto Login**: Check token on app startup
4. **API Calls**: Add token header to each request
5. **Token Expiry**: Logout on 401 error

## 🌐 API Integration

### Base Configuration
- **Base URL**: `http://localhost:8000`
- **API Version**: `/api/v1`
- **Headers**: `Content-Type: application/json`
- **Auth Header**: `Authorization: Bearer {token}`

### HTTP Client Setup
- **Timeout**: 30 seconds
- **Error Handling**: Status code checking
- **Interceptors**: Token addition, error catching
- **Retry Logic**: Retry on network errors

### Main Services

#### 1. AuthService
- Login/Register operations
- Token management
- Password reset
- MFA operations

#### 2. ExpenseService
- Expense CRUD operations
- Filtering and pagination
- Category-based listing

#### 3. ReceiptService
- QR code scanning
- Receipt listing and detail
- Receipt data parsing

#### 4. ReportService
- Dashboard data
- Expense analytics
- Chart data

#### 5. AIService
- Spending summaries
- Saving suggestions
- Pattern analysis

## 🔄 State Management

### Provider Pattern (Recommended)

#### AuthProvider
- Authentication state
- User information
- Login/logout operations

#### ExpenseProvider
- Expense list
- CRUD operations
- Loading states

#### ReceiptProvider
- Receipt list
- QR scan results
- Receipt details

#### ReportProvider
- Dashboard data
- Chart data
- Analysis results

### State Structure
```dart
class ApiState<T> {
  final bool isLoading;
  final T? data;
  final String? error;
  
  // loading(), success(), failure() methods
}
```

## 🚨 Error Handling

### Exception Types
- **ApiException**: API error (400, 500, etc.)
- **NetworkException**: Internet connection
- **AuthException**: Authentication (401, 403)
- **ValidationException**: Data validation

### Error Handling Strategy
1. **Network Errors**: Retry mechanism
2. **Auth Errors**: Logout and redirect to login
3. **Validation Errors**: Show form errors
4. **Server Errors**: General error message

### User Feedback
- **Loading States**: CircularProgressIndicator
- **Error Messages**: SnackBar or Dialog
- **Success Messages**: Toast notifications
- **Empty States**: Empty list states

## 📱 UI/UX Considerations

### Responsive Design
- **Mobile First**: Phone screen priority
- **Tablet Support**: Layout for large screens
- **Orientation**: Portrait/landscape mode support

### Performance
- **Lazy Loading**: Data loading with pagination
- **Image Caching**: Image caching
- **Memory Management**: Widget dispose operations

### Accessibility
- **Screen Reader**: Semantics widgets
- **High Contrast**: Color contrast
- **Font Scaling**: Text size settings

## 🧪 Test Strategy

### Unit Tests
- Service classes
- Provider logic
- Utility functions

### Widget Tests
- UI components
- User interactions
- State changes

### Integration Tests
- API integration
- End-to-end flows
- Performance tests

## 🔧 Development Tips

### Debug Mode
- HTTP request/response logging
- Error stack traces
- Performance monitoring

### Production Build
- Code obfuscation
- Asset optimization
- Crash reporting

### CI/CD
- Automated testing
- Build automation
- App store deployment

## 📚 Resources

- **API Reference**: `FLUTTER_API_REFERENCE.md`
- **Quick Start**: `FLUTTER_QUICK_START.md`
- **Backend Docs**: `http://localhost:8000/docs`
- **Flutter Docs**: https://docs.flutter.dev/

This guide contains all the essential information needed to integrate EcoTrack backend with Flutter. For detailed request/response formats, refer to the `FLUTTER_API_REFERENCE.md` file. 