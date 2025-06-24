import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/receipt/qr_scanner_screen.dart';
import '../screens/expense/add_expense_screen.dart';
import '../screens/expense/expenses_list_screen.dart';
import '../screens/expense/expense_detail_screen.dart';
import '../screens/receipt/receipt_detail_screen.dart';
import '../screens/receipt/receipts_list_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/budget/budget_management_screen.dart';
import '../screens/budget/budget_setup_screen.dart';
import '../screens/budget/category_budget_screen.dart';
import '../screens/reviews/my_reviews_screen.dart';
import '../screens/reviews/receipt_review_screen.dart';
import '../screens/loyalty/loyalty_dashboard_screen.dart';
import '../screens/loyalty/points_calculator_screen.dart';
import '../screens/loyalty/loyalty_history_screen.dart';
import '../screens/loyalty/loyalty_levels_screen.dart';
import '../screens/device/device_management_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/merchant_management_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/security_settings_screen.dart';
import '../screens/ai_recommendations/ai_recommendations_screen.dart';
import '../widgets/navigation/main_navigation.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String editProfile = '/edit-profile';
  static const String securitySettings = '/security-settings';
  static const String reports = '/reports';
  static const String qrScanner = '/qr-scanner';
  static const String addExpense = '/add-expense';
  static const String expenses = '/expenses';
  static const String expenseDetail = '/expense-detail';
  static const String expenseEdit = '/expense-edit';
  static const String receipts = '/receipts';
  static const String receiptDetail = '/receipt-detail';
  static const String dashboard = '/dashboard';
  static const String budgetManagement = '/budget-management';
  static const String budgetSetup = '/budget-setup';
  static const String categoryBudget = '/category-budget';
  static const String myReviews = '/my-reviews';
  static const String receiptReview = '/receipt-review';
  static const String loyaltyDashboard = '/loyalty-dashboard';
  static const String loyaltyCalculator = '/loyalty-calculator';
  static const String loyaltyHistory = '/loyalty-history';
  static const String loyaltyLevels = '/loyalty-levels';

  // Device Management routes
  static const String deviceManagement = '/device-management';
  static const String notificationSettings = '/notification-settings';

  // Admin routes
  static const String adminDashboard = '/admin-dashboard';
  static const String merchantManagement = '/merchant-management';

  // AI Recommendations routes
  static const String aiRecommendations = '/ai-recommendations';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(),
    main: (context) => const MainNavigation(),
    profile: (context) => const ProfileScreen(),
    settings: (context) => const SettingsScreen(),
    editProfile: (context) => const EditProfileScreen(),
    securitySettings: (context) => const SecuritySettingsScreen(),
    reports: (context) => const ReportsScreen(),
    qrScanner: (context) => const QrScannerScreen(),
    addExpense: (context) => const AddExpenseScreen(),
    expenses: (context) => const ExpensesListScreen(),
    receipts: (context) => const ReceiptsListScreen(),
    dashboard: (context) => const HomeScreen(),
    budgetManagement: (context) => const BudgetManagementScreen(),
    budgetSetup: (context) => const BudgetSetupScreen(isEdit: false),
    categoryBudget: (context) => const CategoryBudgetScreen(),
    loyaltyDashboard: (context) => const LoyaltyDashboardScreen(),
    loyaltyCalculator: (context) => const PointsCalculatorScreen(),
    loyaltyHistory: (context) => const LoyaltyHistoryScreen(),
    loyaltyLevels: (context) => const LoyaltyLevelsScreen(),
    deviceManagement: (context) => const DeviceManagementScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    merchantManagement: (context) => const MerchantManagementScreen(),
    aiRecommendations: (context) => const AiRecommendationsScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case expenseDetail:
        final expenseId = settings.arguments as String?;
        if (expenseId != null) {
          return MaterialPageRoute(
            builder: (context) => ExpenseDetailScreen(expenseId: expenseId),
          );
        }
        return _errorRoute();

      case receiptDetail:
        final receiptId = settings.arguments as String?;
        if (receiptId != null) {
          return MaterialPageRoute(
            builder: (context) => ReceiptDetailScreen(receiptId: receiptId),
          );
        }
        return _errorRoute();

      case myReviews:
        return MaterialPageRoute(builder: (context) => const MyReviewsScreen());

      case receiptReview:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args != null &&
            args['receiptId'] != null &&
            args['merchantName'] != null) {
          return MaterialPageRoute(
            builder: (context) => ReceiptReviewScreen(
              receiptId: args['receiptId'] as String,
              merchantName: args['merchantName'] as String,
              allowAnonymous: args['allowAnonymous'] as bool? ?? true,
            ),
          );
        }
        return _errorRoute();

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
