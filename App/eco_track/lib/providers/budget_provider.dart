import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../models/budget/budget_models.dart';
import '../services/budget_service.dart';

// Selected Date State Management
class SelectedDateState {
  final DateTime selectedDate;
  final bool isLoading;
  final String? error;

  const SelectedDateState({
    required this.selectedDate,
    this.isLoading = false,
    this.error,
  });

  SelectedDateState copyWith({
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
  }) {
    return SelectedDateState(
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Selected Date Notifier
class SelectedDateNotifier extends StateNotifier<SelectedDateState> {
  SelectedDateNotifier()
    : super(SelectedDateState(selectedDate: DateTime.now()));

  void setSelectedDate(DateTime date) {
    print(
      '📅 SelectedDateNotifier: Date changed to ${date.year}/${date.month}',
    );
    state = state.copyWith(selectedDate: date);
  }

  void goToNextMonth() {
    final currentDate = state.selectedDate;
    final nextMonth = DateTime(currentDate.year, currentDate.month + 1, 1);
    state = state.copyWith(selectedDate: nextMonth);
  }

  void goToPreviousMonth() {
    final currentDate = state.selectedDate;
    final previousMonth = DateTime(currentDate.year, currentDate.month - 1, 1);
    state = state.copyWith(selectedDate: previousMonth);
  }

  void goToCurrentMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    print(
      '📅 SelectedDateNotifier: Going to current month ${currentMonth.year}/${currentMonth.month}',
    );
    state = state.copyWith(selectedDate: currentMonth);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Selected Date Provider
final selectedDateProvider =
    StateNotifierProvider<SelectedDateNotifier, SelectedDateState>((ref) {
      return SelectedDateNotifier();
    });

// Budget Service Provider
final budgetServiceProvider = Provider<BudgetService>((ref) {
  return getIt<BudgetService>();
});

// User Budget State
class UserBudgetState {
  final Map<String, UserBudget?> budgets; // Key: "YYYY-MM"
  final Map<String, String?> errors;
  final String?
  loadingMonth; // The month key "YYYY-MM" that is currently loading

  const UserBudgetState({
    this.budgets = const {},
    this.errors = const {},
    this.loadingMonth,
  });

  // Helper methods for UI compatibility
  UserBudget? budgetForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return budgets[key];
  }

  String? errorForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return errors[key];
  }

  bool isLoadingForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return loadingMonth == key;
  }

  // Backward compatibility properties
  UserBudget? get budget {
    // This is deprecated - should use budgetForDate instead
    if (budgets.isEmpty) return null;
    return budgets.values.first;
  }

  String? get error {
    // This is deprecated - should use errorForDate instead
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  bool get isLoading {
    // This is deprecated - should use isLoadingForDate instead
    return loadingMonth != null;
  }

  UserBudgetState copyWith({
    Map<String, UserBudget?>? budgets,
    Map<String, String?>? errors,
    String? loadingMonth,
    bool clearLoading = false,
    String? clearErrorForMonth,
  }) {
    final newErrors = Map<String, String?>.from(errors ?? this.errors);
    if (clearErrorForMonth != null) {
      newErrors.remove(clearErrorForMonth);
    }

    return UserBudgetState(
      budgets: budgets ?? this.budgets,
      errors: newErrors,
      loadingMonth: clearLoading ? null : (loadingMonth ?? this.loadingMonth),
    );
  }
}

// User Budget Notifier
class UserBudgetNotifier extends StateNotifier<UserBudgetState> {
  final BudgetService _budgetService;
  final Ref _ref;

  UserBudgetNotifier(this._budgetService, this._ref)
    : super(const UserBudgetState());

  Future<void> loadUserBudget() async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    // If already loaded/failed or currently loading, do nothing.
    if (state.budgets.containsKey(key) || state.loadingMonth == key) {
      print(
        '✅ UserBudgetNotifier: Budget for $key already in cache or loading. Skipping fetch.',
      );
      return;
    }

    try {
      state = state.copyWith(loadingMonth: key, clearErrorForMonth: key);
      print('🔍 UserBudgetNotifier: Loading budget for $key');

      final budget = await _budgetService.getUserBudget(
        year: selectedDate.year,
        month: selectedDate.month,
      );

      final newBudgets = {...state.budgets, key: budget};
      print('✅ UserBudgetNotifier: Budget loaded for $key');
      state = state.copyWith(budgets: newBudgets, clearLoading: true);
    } catch (e) {
      print('❌ UserBudgetNotifier: Error loading budget for $key - $e');
      final newErrors = {...state.errors, key: e.toString()};
      // Store a null for the budget to indicate a failed load, preventing re-fetching.
      final newBudgets = {...state.budgets, key: null};
      state = state.copyWith(
        budgets: newBudgets,
        errors: newErrors,
        clearLoading: true,
      );
    }
  }

  Future<void> createUserBudget(UserBudgetCreateRequest request) async {
    // This will still work on the selected month, but after creation, we update the cache.
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    try {
      state = state.copyWith(loadingMonth: key);
      final budget = await _budgetService.createUserBudget(
        request,
        year: selectedDate.year,
        month: selectedDate.month,
      );
      final newBudgets = {...state.budgets, key: budget};
      state = state.copyWith(budgets: newBudgets, clearLoading: true);
    } catch (e) {
      final newErrors = {...state.errors, key: e.toString()};
      state = state.copyWith(errors: newErrors, clearLoading: true);
      rethrow;
    }
  }

  Future<void> updateUserBudget(UserBudgetUpdateRequest request) async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";
    try {
      state = state.copyWith(loadingMonth: key);
      final budget = await _budgetService.updateUserBudget(
        request,
        year: selectedDate.year,
        month: selectedDate.month,
      );
      final newBudgets = {...state.budgets, key: budget};
      state = state.copyWith(budgets: newBudgets, clearLoading: true);
    } catch (e) {
      final newErrors = {...state.errors, key: e.toString()};
      state = state.copyWith(errors: newErrors, clearLoading: true);
      rethrow;
    }
  }

  Future<BudgetAllocationResponse?> updateUserBudgetWithAutoAllocation(
    UserBudgetUpdateRequest request,
    double totalBudget,
  ) async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";
    try {
      state = state.copyWith(loadingMonth: key);

      final budget = await _budgetService.updateUserBudget(
        request,
        year: selectedDate.year,
        month: selectedDate.month,
      );
      final newBudgets = {...state.budgets, key: budget};
      state = state.copyWith(budgets: newBudgets, clearLoading: true);

      if (request.autoAllocate == true) {
        final allocationRequest = BudgetAllocationRequest(
          totalBudget: totalBudget,
          year: selectedDate.year,
          month: selectedDate.month,
        );
        return await _budgetService.applyBudgetAllocation(
          allocationRequest,
          year: selectedDate.year,
          month: selectedDate.month,
        );
      }
      return null;
    } catch (e) {
      final newErrors = {...state.errors, key: e.toString()};
      state = state.copyWith(errors: newErrors, clearLoading: true);
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(errors: {});
  }

  void reset() {
    print('🔄 UserBudgetNotifier: State cache reset');
    state = const UserBudgetState();
  }
}

// User Budget Provider - Updated to include ref
final userBudgetProvider =
    StateNotifierProvider<UserBudgetNotifier, UserBudgetState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return UserBudgetNotifier(budgetService, ref);
    });

// Category Budgets State
class CategoryBudgetsState {
  final Map<String, List<BudgetCategory>> categoryBudgets; // Key: "YYYY-MM"
  final Map<String, String?> errors;
  final String? loadingMonth;

  const CategoryBudgetsState({
    this.categoryBudgets = const {},
    this.errors = const {},
    this.loadingMonth,
  });

  // Helper methods for UI compatibility
  List<BudgetCategory> categoriesForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return categoryBudgets[key] ?? [];
  }

  String? errorForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return errors[key];
  }

  bool isLoadingForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return loadingMonth == key;
  }

  // Backward compatibility properties
  List<BudgetCategory> get categories {
    if (categoryBudgets.isEmpty) return [];
    return categoryBudgets.values.first;
  }

  String? get error {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  bool get isLoading {
    return loadingMonth != null;
  }

  CategoryBudgetsState copyWith({
    Map<String, List<BudgetCategory>>? categoryBudgets,
    Map<String, String?>? errors,
    String? loadingMonth,
    bool clearLoading = false,
    String? clearErrorForMonth,
  }) {
    final newErrors = Map<String, String?>.from(errors ?? this.errors);
    if (clearErrorForMonth != null) {
      newErrors.remove(clearErrorForMonth);
    }

    return CategoryBudgetsState(
      categoryBudgets: categoryBudgets ?? this.categoryBudgets,
      errors: newErrors,
      loadingMonth: clearLoading ? null : (loadingMonth ?? this.loadingMonth),
    );
  }
}

// Category Budgets Notifier
class CategoryBudgetsNotifier extends StateNotifier<CategoryBudgetsState> {
  final BudgetService _budgetService;
  final Ref _ref;

  CategoryBudgetsNotifier(this._budgetService, this._ref)
    : super(const CategoryBudgetsState());

  Future<void> loadCategoryBudgets() async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    // If already loaded/failed or currently loading, do nothing.
    if (state.categoryBudgets.containsKey(key) || state.loadingMonth == key) {
      print(
        '✅ CategoryBudgetsNotifier: Categories for $key already in cache or loading. Skipping fetch.',
      );
      return;
    }

    try {
      state = state.copyWith(loadingMonth: key, clearErrorForMonth: key);
      print('🔍 CategoryBudgetsNotifier: Loading categories for $key');

      final response = await _budgetService.getCategoryBudgets(
        year: selectedDate.year,
        month: selectedDate.month,
      );

      final newCategoryBudgets = {
        ...state.categoryBudgets,
        key: response.categoryBudgets,
      };
      print('✅ CategoryBudgetsNotifier: Categories loaded for $key');
      state = state.copyWith(
        categoryBudgets: newCategoryBudgets,
        clearLoading: true,
      );
    } catch (e) {
      print(
        '❌ CategoryBudgetsNotifier: Error loading categories for $key - $e',
      );
      final newErrors = {...state.errors, key: e.toString()};
      // Store an empty list for the categories to indicate a failed load, preventing re-fetching.
      final newCategoryBudgets = {
        ...state.categoryBudgets,
        key: <BudgetCategory>[],
      };
      state = state.copyWith(
        categoryBudgets: newCategoryBudgets,
        errors: newErrors,
        clearLoading: true,
      );
    }
  }

  Future<void> createCategoryBudget(BudgetCategoryCreateRequest request) async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    try {
      state = state.copyWith(loadingMonth: key);
      final newCategory = await _budgetService.createCategoryBudget(
        request,
        year: selectedDate.year,
        month: selectedDate.month,
      );

      // Update existing category or add new one in the cache
      final currentCategories = state.categoryBudgets[key] ?? [];
      final updatedCategories = [...currentCategories];
      final existingIndex = updatedCategories.indexWhere(
        (cat) => cat.categoryId == newCategory.categoryId,
      );

      if (existingIndex != -1) {
        updatedCategories[existingIndex] = newCategory;
      } else {
        updatedCategories.add(newCategory);
      }

      final newCategoryBudgets = {
        ...state.categoryBudgets,
        key: updatedCategories,
      };
      state = state.copyWith(
        categoryBudgets: newCategoryBudgets,
        clearLoading: true,
      );
    } catch (e) {
      final newErrors = {...state.errors, key: e.toString()};
      state = state.copyWith(errors: newErrors, clearLoading: true);
      rethrow;
    }
  }

  Future<void> deleteCategoryBudget(String categoryId) async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    try {
      state = state.copyWith(loadingMonth: key);
      await _budgetService.deleteCategoryBudget(
        categoryId,
        year: selectedDate.year,
        month: selectedDate.month,
      );

      // Remove category from cache
      final currentCategories = state.categoryBudgets[key] ?? [];
      final updatedCategories = currentCategories
          .where((cat) => cat.categoryId != categoryId)
          .toList();

      final newCategoryBudgets = {
        ...state.categoryBudgets,
        key: updatedCategories,
      };
      state = state.copyWith(
        categoryBudgets: newCategoryBudgets,
        clearLoading: true,
      );
    } catch (e) {
      final newErrors = {...state.errors, key: e.toString()};
      state = state.copyWith(errors: newErrors, clearLoading: true);
      rethrow;
    }
  }

  Future<void> resetAllCategoryBudgets() async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    try {
      state = state.copyWith(loadingMonth: key);
      await _budgetService.resetAllCategoryBudgets(
        year: selectedDate.year,
        month: selectedDate.month,
      );

      // Clear all categories from cache for this month
      final newCategoryBudgets = {
        ...state.categoryBudgets,
        key: <BudgetCategory>[],
      };
      state = state.copyWith(
        categoryBudgets: newCategoryBudgets,
        clearLoading: true,
      );
    } catch (e) {
      final newErrors = {...state.errors, key: e.toString()};
      state = state.copyWith(errors: newErrors, clearLoading: true);
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(errors: {});
  }

  void reset() {
    print('🔄 CategoryBudgetsNotifier: State cache reset');
    state = const CategoryBudgetsState();
  }
}

// Category Budgets Provider - Updated to include ref
final categoryBudgetsProvider =
    StateNotifierProvider<CategoryBudgetsNotifier, CategoryBudgetsState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return CategoryBudgetsNotifier(budgetService, ref);
    });

// Budget Summary State
class BudgetSummaryState {
  final Map<String, BudgetSummaryResponse?> summaries; // Key: "YYYY-MM"
  final Map<String, String?> errors;
  final String? loadingMonth;

  const BudgetSummaryState({
    this.summaries = const {},
    this.errors = const {},
    this.loadingMonth,
  });

  // Helper methods for UI compatibility
  BudgetSummaryResponse? summaryForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return summaries[key];
  }

  String? errorForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return errors[key];
  }

  bool isLoadingForDate(DateTime date) {
    final key = "${date.year}-${date.month}";
    return loadingMonth == key;
  }

  // Backward compatibility properties
  BudgetSummaryResponse? get summary {
    if (summaries.isEmpty) return null;
    return summaries.values.first;
  }

  String? get error {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  bool get isLoading {
    return loadingMonth != null;
  }

  BudgetSummaryState copyWith({
    Map<String, BudgetSummaryResponse?>? summaries,
    Map<String, String?>? errors,
    String? loadingMonth,
    bool clearLoading = false,
    String? clearErrorForMonth,
  }) {
    final newErrors = Map<String, String?>.from(errors ?? this.errors);
    if (clearErrorForMonth != null) {
      newErrors.remove(clearErrorForMonth);
    }

    return BudgetSummaryState(
      summaries: summaries ?? this.summaries,
      errors: newErrors,
      loadingMonth: clearLoading ? null : (loadingMonth ?? this.loadingMonth),
    );
  }
}

// Budget Summary Notifier
class BudgetSummaryNotifier extends StateNotifier<BudgetSummaryState> {
  final BudgetService _budgetService;
  final Ref _ref;

  BudgetSummaryNotifier(this._budgetService, this._ref)
    : super(const BudgetSummaryState());

  Future<void> loadBudgetSummary() async {
    final selectedDate = _ref.read(selectedDateProvider).selectedDate;
    final key = "${selectedDate.year}-${selectedDate.month}";

    // If already loaded/failed or currently loading, do nothing.
    if (state.summaries.containsKey(key) || state.loadingMonth == key) {
      print(
        '✅ BudgetSummaryNotifier: Summary for $key already in cache or loading. Skipping fetch.',
      );
      return;
    }

    try {
      state = state.copyWith(loadingMonth: key, clearErrorForMonth: key);
      print('🔍 BudgetSummaryNotifier: Loading summary for $key');

      final summary = await _budgetService.getBudgetSummary(
        year: selectedDate.year,
        month: selectedDate.month,
      );

      final newSummaries = {...state.summaries, key: summary};
      print('✅ BudgetSummaryNotifier: Summary loaded for $key');
      state = state.copyWith(summaries: newSummaries, clearLoading: true);
    } catch (e) {
      print('❌ BudgetSummaryNotifier: Error loading summary for $key - $e');
      final newErrors = {...state.errors, key: e.toString()};
      // Store a null for the summary to indicate a failed load, preventing re-fetching.
      final newSummaries = {...state.summaries, key: null};
      state = state.copyWith(
        summaries: newSummaries,
        errors: newErrors,
        clearLoading: true,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errors: {});
  }

  void reset() {
    print('🔄 BudgetSummaryNotifier: State cache reset');
    state = const BudgetSummaryState();
  }
}

// Budget Summary Provider - Updated to include ref
final budgetSummaryProvider =
    StateNotifierProvider<BudgetSummaryNotifier, BudgetSummaryState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return BudgetSummaryNotifier(budgetService, ref);
    });

// Budget Allocation State
class BudgetAllocationState {
  final BudgetAllocationResponse? allocation;
  final bool isLoading;
  final String? error;

  const BudgetAllocationState({
    this.allocation,
    this.isLoading = false,
    this.error,
  });

  BudgetAllocationState copyWith({
    BudgetAllocationResponse? allocation,
    bool? isLoading,
    String? error,
  }) {
    return BudgetAllocationState(
      allocation: allocation ?? this.allocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Budget Allocation Notifier
class BudgetAllocationNotifier extends StateNotifier<BudgetAllocationState> {
  final BudgetService _budgetService;
  final Ref _ref;

  BudgetAllocationNotifier(this._budgetService, this._ref)
    : super(const BudgetAllocationState());

  Future<void> applyBudgetAllocation(BudgetAllocationRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final selectedDate = _ref.read(selectedDateProvider).selectedDate;
      final allocation = await _budgetService.applyBudgetAllocation(
        request,
        year: selectedDate.year,
        month: selectedDate.month,
      );

      state = state.copyWith(allocation: allocation, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const BudgetAllocationState();
  }
}

// Budget Allocation Provider - Updated to include ref
final budgetAllocationProvider =
    StateNotifierProvider<BudgetAllocationNotifier, BudgetAllocationState>((
      ref,
    ) {
      final budgetService = ref.watch(budgetServiceProvider);
      return BudgetAllocationNotifier(budgetService, ref);
    });

// Budget List State
class BudgetListState {
  final List<UserBudget> budgets;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const BudgetListState({
    this.budgets = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 0,
  });

  BudgetListState copyWith({
    List<UserBudget>? budgets,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return BudgetListState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Budget List Notifier
class BudgetListNotifier extends StateNotifier<BudgetListState> {
  final BudgetService _budgetService;

  BudgetListNotifier(this._budgetService) : super(const BudgetListState());

  Future<void> loadBudgetList({bool refresh = false}) async {
    try {
      if (refresh) {
        state = state.copyWith(isLoading: true, error: null, currentPage: 0);
      } else {
        state = state.copyWith(isLoading: true, error: null);
      }

      final offset = refresh ? 0 : state.budgets.length;
      final response = await _budgetService.getBudgetList(
        limit: 12,
        offset: offset,
      );

      List<UserBudget> updatedBudgets;
      if (refresh) {
        updatedBudgets = response.budgets;
      } else {
        updatedBudgets = [...state.budgets, ...response.budgets];
      }

      state = state.copyWith(
        budgets: updatedBudgets,
        isLoading: false,
        hasMore: response.hasNext,
        currentPage: response.page,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const BudgetListState();
  }
}

// Budget List Provider
final budgetListProvider =
    StateNotifierProvider<BudgetListNotifier, BudgetListState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return BudgetListNotifier(budgetService);
    });
