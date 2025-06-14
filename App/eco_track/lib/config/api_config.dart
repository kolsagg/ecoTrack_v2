class ApiConfig {
  // Base URLs for different environments
  static const String _developmentBaseUrl = 'http://localhost:8000';
  static const String _productionBaseUrl =
      'https://api.ecotrack.app'; // Will be updated when deployed

  // Current environment
  static const bool _isDevelopment = true; // Change to false for production

  // API Configuration
  static String get baseUrl =>
      _isDevelopment ? _developmentBaseUrl : _productionBaseUrl;
  static const String apiVersion = '/api/v1';
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Auth header key
  static const String authHeaderKey = 'Authorization';
  static String authHeaderValue(String token) => 'Bearer $token';

  // Rate limiting
  static const int maxRequestsPerMinute = 100;

  // Health check endpoints
  static const String healthEndpoint = '/health';
  static const String healthDetailedEndpoint = '/health/detailed';
  static const String healthDatabaseEndpoint = '/health/database';
  static const String healthMetricsEndpoint = '/health/metrics';
  static const String healthReadyEndpoint = '/health/ready';
  static const String healthLiveEndpoint = '/health/live';

  // Auth endpoints
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String registerEndpoint = '/api/v1/auth/register';
  static const String resetPasswordEndpoint = '/api/v1/auth/reset-password';
  static const String resetPasswordConfirmEndpoint =
      '/api/v1/auth/reset-password/confirm';
  static const String mfaStatusEndpoint = '/api/v1/auth/mfa/status';
  static const String mfaTotpCreateEndpoint = '/api/v1/auth/mfa/totp/create';
  static const String mfaTotpVerifyEndpoint = '/api/v1/auth/mfa/totp/verify';
  static const String deleteAccountEndpoint = '/api/v1/auth/account';

  // Receipt endpoints
  static const String receiptScanEndpoint = '/api/v1/receipts/scan';
  static const String receiptsEndpoint = '/api/v1/receipts';

  // Expense endpoints
  static const String expensesEndpoint = '/api/v1/expenses';

  // Category endpoints
  static const String categoriesEndpoint = '/api/v1/categories';

  // Reports endpoints
  static const String reportsHealthEndpoint = '/api/v1/reports/health';
  static const String categoryDistributionEndpoint =
      '/api/v1/reports/category-distribution';
  static const String budgetVsActualEndpoint = '/api/v1/reports/budget-vs-actual';
  static const String spendingTrendsEndpoint = '/api/v1/reports/spending-trends';
  static const String exportReportsEndpoint = '/api/v1/reports/export';

  // Loyalty endpoints
  static const String loyaltyStatusEndpoint = '/api/v1/loyalty/status';
  static const String loyaltyCalculatePointsEndpoint =
      '/api/v1/loyalty/calculate-points';
  static const String loyaltyHistoryEndpoint = '/api/v1/loyalty/history';
  static const String loyaltyLevelsEndpoint = '/api/v1/loyalty/levels';

  // Device endpoints
  static const String deviceRegisterEndpoint = '/api/v1/devices/register';
  static const String devicesEndpoint = '/api/v1/devices';

  // Budget endpoints
  static const String budgetEndpoint = '/api/v1/budget';
  static const String budgetCategoriesEndpoint = '/api/v1/budget/categories';
  static const String budgetSummaryEndpoint = '/api/v1/budget/summary';
  static const String budgetApplyAllocationEndpoint =
      '/api/v1/budget/apply-allocation';
  static const String budgetHealthEndpoint = '/api/v1/budget/health';

  // Environment check
  static bool get isDevelopment => _isDevelopment;
  static bool get isProduction => !_isDevelopment;
}
