import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/receipt/qr_scanner_screen.dart';
import '../screens/expense/add_expense_screen.dart';
import '../screens/receipt/receipts_list_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String qrScanner = '/qr-scanner';
  static const String addExpense = '/add-expense';
  static const String receipts = '/receipts';
  static const String receiptDetail = '/receipt-detail';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        home: (context) => const HomeScreen(),
        qrScanner: (context) => const QrScannerScreen(),
        addExpense: (context) => const AddExpenseScreen(),
        receipts: (context) => const ReceiptsListScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case receiptDetail:
        final receiptId = settings.arguments as String?;
        if (receiptId != null) {
          // TODO: Create ReceiptDetailScreen
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Receipt Detail')),
              body: Center(
                child: Text('Receipt Detail: $receiptId'),
              ),
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
        body: const Center(
          child: Text('Page not found'),
        ),
      ),
    );
  }
} 