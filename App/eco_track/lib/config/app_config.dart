class AppConfig {
  // App Information
  static const String appName = 'EcoTrack';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Personal Expense Tracking Application';
  
  // App Settings
  static const bool enableDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableCrashReporting = false; // Will be enabled in production
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String onboardingKey = 'onboarding_completed';
  static const String biometricKey = 'biometric_enabled';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // QR Scanner Settings
  static const bool enableFlash = true;
  static const bool enableGalleryImport = true;
  static const Duration scanTimeout = Duration(seconds: 30);
  
  // Chart Settings
  static const int maxChartDataPoints = 12; // For monthly data
  static const double chartAnimationDuration = 1.5; // seconds
  
  // Loyalty System
  static const double basePointsRate = 0.01; // 1% of spending
  static const Map<String, double> categoryBonusRates = {
    'food': 0.5, // 50% bonus
    'grocery': 0.3, // 30% bonus
    'fuel': 0.2, // 20% bonus
    'restaurant': 0.4, // 40% bonus
  };
  
  // Currency Settings
  static const String defaultCurrency = 'TRY';
  static const List<String> supportedCurrencies = ['TRY', 'USD', 'EUR'];
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String apiDateFormat = 'yyyy-MM-ddTHH:mm:ssZ';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  static const double minExpenseAmount = 0.01;
  static const double maxExpenseAmount = 999999.99;
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // Notification Settings
  static const bool enablePushNotifications = true;
  static const bool enableBudgetAlerts = true;
  static const bool enableSpendingAlerts = true;
  
  // Cache Settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Error Messages
  static const String genericErrorMessage = 'An error occurred. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String loginSuccessMessage = 'Login successful!';
  static const String registerSuccessMessage = 'Registration successful!';
  static const String expenseAddedMessage = 'Expense added successfully!';
  static const String receiptScannedMessage = 'Receipt scanned successfully!';
  
  // Feature Flags
  static const bool enableAIInsights = true;
  static const bool enableBudgetManagement = true;
  static const bool enableLoyaltyProgram = true;
  static const bool enableMerchantReviews = true;
  static const bool enableOfflineMode = false; // Future feature
  
  // Development Settings
  static const bool showDebugInfo = true;
  static const bool enableMockData = false;
  static const bool skipOnboarding = false; // For development
} 