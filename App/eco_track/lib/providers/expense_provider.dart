import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../models/expense/expense_model.dart';
import '../services/expense_service.dart';

// Expense Service Provider
final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return getIt<ExpenseService>();
});

// Expense State
class ExpenseState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
  final Expense? selectedExpense;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
    this.selectedExpense,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
    Expense? selectedExpense,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      selectedExpense: selectedExpense ?? this.selectedExpense,
    );
  }
}

// Expense Notifier
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final ExpenseService _expenseService;

  ExpenseNotifier(this._expenseService) : super(const ExpenseState());

  // Load Expenses with Filtering
  Future<void> loadExpenses({
    bool refresh = false,
    String? merchantName,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    double? minAmount,
    double? maxAmount,
    String sortBy = 'expense_date',
    String sortOrder = 'desc',
  }) async {
    if (state.isLoading) return;

    try {
      final page = refresh ? 1 : state.currentPage + 1;

      if (!refresh && !state.hasMore) return;

      state = state.copyWith(isLoading: true, error: null);

      final response = await _expenseService.getExpenses(
        page: page,
        merchantName: merchantName,
        startDate: startDate,
        endDate: endDate,
        category: category,
        minAmount: minAmount,
        maxAmount: maxAmount,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newExpenses = refresh
          ? response.expenses
          : [...state.expenses, ...response.expenses];

      state = state.copyWith(
        expenses: newExpenses,
        isLoading: false,
        currentPage: response.page,
        totalPages: response.total ~/ response.limit + 1,
        hasMore: response.hasNext,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Get Expense Detail
  Future<void> loadExpenseDetail(String expenseId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final expense = await _expenseService.getExpenseDetail(expenseId);

      state = state.copyWith(selectedExpense: expense, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Get Expense by Receipt ID
  Future<Expense?> getExpenseByReceiptId(String receiptId) async {
    try {
      return await _expenseService.getExpenseByReceiptId(receiptId);
    } catch (e) {
      rethrow;
    }
  }

  // Update Expense
  Future<void> updateExpense(
    String expenseId,
    ExpenseUpdateRequest request,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedExpense = await _expenseService.updateExpense(
        expenseId,
        request,
      );

      // Update in the list
      final updatedExpenses = state.expenses.map((expense) {
        return expense.id == expenseId ? updatedExpense : expense;
      }).toList();

      state = state.copyWith(
        expenses: updatedExpenses,
        selectedExpense: state.selectedExpense?.id == expenseId
            ? updatedExpense
            : state.selectedExpense,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Delete Expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _expenseService.deleteExpense(expenseId);

      // Remove from the list
      final updatedExpenses = state.expenses
          .where((expense) => expense.id != expenseId)
          .toList();

      state = state.copyWith(
        expenses: updatedExpenses,
        selectedExpense: state.selectedExpense?.id == expenseId
            ? null
            : state.selectedExpense,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset State
  void reset() {
    state = const ExpenseState();
  }

  // Clear Selected Expense
  void clearSelectedExpense() {
    state = state.copyWith(selectedExpense: null);
  }
}

// Expense Provider
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((
  ref,
) {
  final expenseService = ref.watch(expenseServiceProvider);
  return ExpenseNotifier(expenseService);
});

// Expense Items State
class ExpenseItemsState {
  final List<ExpenseItem> items;
  final bool isLoading;
  final String? error;

  const ExpenseItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ExpenseItemsState copyWith({
    List<ExpenseItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return ExpenseItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Expense Items Notifier
class ExpenseItemsNotifier extends StateNotifier<ExpenseItemsState> {
  final ExpenseService _expenseService;

  ExpenseItemsNotifier(this._expenseService) : super(const ExpenseItemsState());

  // Load Expense Items
  Future<void> loadExpenseItems(String expenseId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final items = await _expenseService.getExpenseItems(expenseId);

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Create Expense Item
  Future<void> createExpenseItem(
    String expenseId,
    ExpenseItemCreateRequest request,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final newItem = await _expenseService.createExpenseItem(
        expenseId,
        request,
      );

      state = state.copyWith(
        items: [...state.items, newItem],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Update Expense Item
  Future<void> updateExpenseItem(
    String expenseId,
    String itemId,
    ExpenseItemUpdateRequest request,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final updatedItem = await _expenseService.updateExpenseItem(
        expenseId,
        itemId,
        request,
      );

      final updatedItems = state.items.map((item) {
        return item.id == itemId ? updatedItem : item;
      }).toList();

      state = state.copyWith(items: updatedItems, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Delete Expense Item
  Future<void> deleteExpenseItem(String expenseId, String itemId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _expenseService.deleteExpenseItem(expenseId, itemId);

      final updatedItems = state.items
          .where((item) => item.id != itemId)
          .toList();

      state = state.copyWith(items: updatedItems, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset State
  void reset() {
    state = const ExpenseItemsState();
  }
}

// Expense Items Provider
final expenseItemsProvider =
    StateNotifierProvider<ExpenseItemsNotifier, ExpenseItemsState>((ref) {
      final expenseService = ref.watch(expenseServiceProvider);
      return ExpenseItemsNotifier(expenseService);
    });

// Recent Expenses State
class RecentExpensesState {
  final List<Expense> expenses;
  final bool isLoading;
  final String? error;

  const RecentExpensesState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  RecentExpensesState copyWith({
    List<Expense>? expenses,
    bool? isLoading,
    String? error,
  }) {
    return RecentExpensesState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Recent Expenses Notifier
class RecentExpensesNotifier extends StateNotifier<RecentExpensesState> {
  final ExpenseService _expenseService;

  RecentExpensesNotifier(this._expenseService)
    : super(const RecentExpensesState());

  // Load Recent Expenses
  Future<void> loadRecentExpenses() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _expenseService.getExpenses(
        page: 1,
        limit: 5,
        sortBy: 'expense_date',
        sortOrder: 'desc',
      );

      state = state.copyWith(expenses: response.expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        expenses: [], // Fallback to empty list on error
      );
    }
  }

  // Refresh Recent Expenses
  Future<void> refreshRecentExpenses() async {
    await loadRecentExpenses();
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset State
  void reset() {
    state = const RecentExpensesState();
  }
}

// Recent Expenses Provider - StateNotifier version for better control
final recentExpensesStateProvider =
    StateNotifierProvider<RecentExpensesNotifier, RecentExpensesState>((ref) {
      final expenseService = ref.watch(expenseServiceProvider);
      return RecentExpensesNotifier(expenseService);
    });
