import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../services/expense_service.dart';
import '../services/budget_service.dart';

// Profile Stats State
class ProfileStatsState {
  final double currentMonthSpending;
  final double lastMonthSpending;
  final int currentMonthExpenseCount;
  final double budgetUsagePercentage;
  final bool isLoading;
  final String? error;

  const ProfileStatsState({
    this.currentMonthSpending = 0.0,
    this.lastMonthSpending = 0.0,
    this.currentMonthExpenseCount = 0,
    this.budgetUsagePercentage = 0.0,
    this.isLoading = false,
    this.error,
  });

  ProfileStatsState copyWith({
    double? currentMonthSpending,
    double? lastMonthSpending,
    int? currentMonthExpenseCount,
    double? budgetUsagePercentage,
    bool? isLoading,
    String? error,
  }) {
    return ProfileStatsState(
      currentMonthSpending: currentMonthSpending ?? this.currentMonthSpending,
      lastMonthSpending: lastMonthSpending ?? this.lastMonthSpending,
      currentMonthExpenseCount:
          currentMonthExpenseCount ?? this.currentMonthExpenseCount,
      budgetUsagePercentage:
          budgetUsagePercentage ?? this.budgetUsagePercentage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Profile Stats Notifier
class ProfileStatsNotifier extends StateNotifier<ProfileStatsState> {
  final ExpenseService _expenseService;
  final BudgetService _budgetService;

  ProfileStatsNotifier(this._expenseService, this._budgetService)
    : super(const ProfileStatsState());

  Future<void> loadProfileStats() async {
    try {
      print('📊 ProfileStats: Starting to load profile stats...');
      state = state.copyWith(isLoading: true, error: null);

      final now = DateTime.now();
      final currentMonthStart = DateTime(now.year, now.month, 1);
      final currentMonthEnd = DateTime(
        now.year,
        now.month + 1,
        1,
      ).subtract(const Duration(days: 1));

      // Handle year transition for last month
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastMonthYear = now.month == 1 ? now.year - 1 : now.year;
      final lastMonthStart = DateTime(lastMonthYear, lastMonth, 1);
      final lastMonthEnd = DateTime(
        lastMonthYear,
        lastMonth + 1,
        1,
      ).subtract(const Duration(days: 1));

      print('📅 Date ranges:');
      print('  Current month: $currentMonthStart to $currentMonthEnd');
      print('  Last month: $lastMonthStart to $lastMonthEnd');

      // Get current month expenses
      print('📊 Fetching current month expenses...');
      final currentMonthResponse = await _expenseService.getExpenses(
        startDate: currentMonthStart,
        endDate: currentMonthEnd,
        limit: 100, // API limit is 100
      );
      print(
        '✅ Current month expenses: ${currentMonthResponse.expenses.length} items',
      );

      // Get last month expenses
      print('📊 Fetching last month expenses...');
      final lastMonthResponse = await _expenseService.getExpenses(
        startDate: lastMonthStart,
        endDate: lastMonthEnd,
        limit: 100, // API limit is 100
      );
      print(
        '✅ Last month expenses: ${lastMonthResponse.expenses.length} items',
      );

      // Calculate current month total spending
      double currentMonthSpending = 0.0;
      for (final expense in currentMonthResponse.expenses) {
        currentMonthSpending += expense.totalAmount;
      }
      print(
        '💰 Current month spending: ₺${currentMonthSpending.toStringAsFixed(2)}',
      );

      // Calculate last month total spending
      double lastMonthSpending = 0.0;
      for (final expense in lastMonthResponse.expenses) {
        lastMonthSpending += expense.totalAmount;
      }
      print('💰 Last month spending: ₺${lastMonthSpending.toStringAsFixed(2)}');

      // Calculate budget usage percentage from user budget and current spending
      double budgetUsagePercentage = 0.0;
      try {
        print('📊 Fetching user budget...');
        final userBudget = await _budgetService.getUserBudget();

        if (userBudget != null && userBudget.totalMonthlyBudget > 0) {
          // Calculate budget usage percentage: (current month spending / total monthly budget) * 100
          budgetUsagePercentage =
              (currentMonthSpending / userBudget.totalMonthlyBudget) * 100;

          print('📊 Budget Calculation:');
          print(
            '  - Total Monthly Budget: ₺${userBudget.totalMonthlyBudget.toStringAsFixed(2)}',
          );
          print(
            '  - Current Month Spending: ₺${currentMonthSpending.toStringAsFixed(2)}',
          );
          print(
            '  - Budget Usage: ${budgetUsagePercentage.toStringAsFixed(1)}%',
          );
        } else {
          print('❌ No user budget found or budget is 0');
        }
      } catch (e) {
        print('❌ Failed to get user budget: $e');
        print('❌ Error type: ${e.runtimeType}');
      }

      final finalState = ProfileStatsState(
        currentMonthSpending: currentMonthSpending,
        lastMonthSpending: lastMonthSpending,
        currentMonthExpenseCount: currentMonthResponse.expenses.length,
        budgetUsagePercentage: budgetUsagePercentage,
        isLoading: false,
        error: null,
      );

      print(
        '📊 Final stats: ${finalState.currentMonthSpending}, ${finalState.lastMonthSpending}, ${finalState.currentMonthExpenseCount}, ${finalState.budgetUsagePercentage}%',
      );

      state = finalState;
    } catch (e) {
      print('❌ ProfileStats error: $e');
      print('❌ Error type: ${e.runtimeType}');

      String errorMessage = 'Unknown error occurred';
      if (e.toString().contains('422')) {
        errorMessage = 'Invalid request parameters';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Authentication required';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error';
      } else {
        errorMessage = e.toString();
      }

      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ProfileStatsState();
  }
}

// Profile Stats Provider
final profileStatsProvider =
    StateNotifierProvider<ProfileStatsNotifier, ProfileStatsState>((ref) {
      final expenseService = getIt<ExpenseService>();
      final budgetService = getIt<BudgetService>();
      return ProfileStatsNotifier(expenseService, budgetService);
    });
