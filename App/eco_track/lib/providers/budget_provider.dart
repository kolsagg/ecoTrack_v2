import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../models/budget/budget_models.dart';
import '../services/budget_service.dart';

// Budget Service Provider
final budgetServiceProvider = Provider<BudgetService>((ref) {
  return getIt<BudgetService>();
});

// User Budget State
class UserBudgetState {
  final UserBudget? budget;
  final bool isLoading;
  final String? error;

  const UserBudgetState({this.budget, this.isLoading = false, this.error});

  UserBudgetState copyWith({
    UserBudget? budget,
    bool? isLoading,
    String? error,
  }) {
    return UserBudgetState(
      budget: budget ?? this.budget,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User Budget Notifier
class UserBudgetNotifier extends StateNotifier<UserBudgetState> {
  final BudgetService _budgetService;

  UserBudgetNotifier(this._budgetService) : super(const UserBudgetState());

  Future<void> loadUserBudget() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final budget = await _budgetService.getUserBudget();

      state = state.copyWith(budget: budget, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createUserBudget(UserBudgetCreateRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final budget = await _budgetService.createUserBudget(request);

      state = state.copyWith(budget: budget, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUserBudget(UserBudgetUpdateRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final budget = await _budgetService.updateUserBudget(request);

      state = state.copyWith(budget: budget, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<BudgetAllocationResponse?> updateUserBudgetWithAutoAllocation(
    UserBudgetUpdateRequest request,
    double totalBudget,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // İlk önce budget'ı update et
      final budget = await _budgetService.updateUserBudget(request);
      state = state.copyWith(budget: budget, isLoading: false);

      // Eğer auto allocation enabled ise, allocation uygula
      if (request.autoAllocate == true) {
        final allocationRequest = BudgetAllocationRequest(
          totalBudget: totalBudget,
        );
        final allocation = await _budgetService.applyBudgetAllocation(
          allocationRequest,
        );
        return allocation;
      }

      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const UserBudgetState();
  }
}

// User Budget Provider
final userBudgetProvider =
    StateNotifierProvider<UserBudgetNotifier, UserBudgetState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return UserBudgetNotifier(budgetService);
    });

// Category Budgets State
class CategoryBudgetsState {
  final List<BudgetCategory> categories;
  final bool isLoading;
  final String? error;

  const CategoryBudgetsState({
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  CategoryBudgetsState copyWith({
    List<BudgetCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return CategoryBudgetsState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Category Budgets Notifier
class CategoryBudgetsNotifier extends StateNotifier<CategoryBudgetsState> {
  final BudgetService _budgetService;

  CategoryBudgetsNotifier(this._budgetService)
    : super(const CategoryBudgetsState());

  Future<void> loadCategoryBudgets() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _budgetService.getCategoryBudgets();

      state = state.copyWith(
        categories: response.categoryBudgets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> createCategoryBudget(BudgetCategoryCreateRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final newCategory = await _budgetService.createCategoryBudget(request);

      // Update existing category or add new one
      final updatedCategories = [...state.categories];
      final existingIndex = updatedCategories.indexWhere(
        (cat) => cat.categoryId == newCategory.categoryId,
      );

      if (existingIndex != -1) {
        updatedCategories[existingIndex] = newCategory;
      } else {
        updatedCategories.add(newCategory);
      }

      state = state.copyWith(categories: updatedCategories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCategoryBudget(String categoryId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _budgetService.deleteCategoryBudget(categoryId);

      // Remove category from list
      final updatedCategories = state.categories
          .where((cat) => cat.categoryId != categoryId)
          .toList();

      state = state.copyWith(categories: updatedCategories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetAllCategoryBudgets() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await _budgetService.resetAllCategoryBudgets();

      // Clear all categories from list
      state = state.copyWith(categories: [], isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const CategoryBudgetsState();
  }
}

// Category Budgets Provider
final categoryBudgetsProvider =
    StateNotifierProvider<CategoryBudgetsNotifier, CategoryBudgetsState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return CategoryBudgetsNotifier(budgetService);
    });

// Budget Summary State
class BudgetSummaryState {
  final BudgetSummaryResponse? summary;
  final bool isLoading;
  final String? error;

  const BudgetSummaryState({this.summary, this.isLoading = false, this.error});

  BudgetSummaryState copyWith({
    BudgetSummaryResponse? summary,
    bool? isLoading,
    String? error,
  }) {
    return BudgetSummaryState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Budget Summary Notifier
class BudgetSummaryNotifier extends StateNotifier<BudgetSummaryState> {
  final BudgetService _budgetService;

  BudgetSummaryNotifier(this._budgetService)
    : super(const BudgetSummaryState());

  Future<void> loadBudgetSummary() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final summary = await _budgetService.getBudgetSummary();

      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const BudgetSummaryState();
  }
}

// Budget Summary Provider
final budgetSummaryProvider =
    StateNotifierProvider<BudgetSummaryNotifier, BudgetSummaryState>((ref) {
      final budgetService = ref.watch(budgetServiceProvider);
      return BudgetSummaryNotifier(budgetService);
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

  BudgetAllocationNotifier(this._budgetService)
    : super(const BudgetAllocationState());

  Future<void> applyBudgetAllocation(BudgetAllocationRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final allocation = await _budgetService.applyBudgetAllocation(request);

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

// Budget Allocation Provider
final budgetAllocationProvider =
    StateNotifierProvider<BudgetAllocationNotifier, BudgetAllocationState>((
      ref,
    ) {
      final budgetService = ref.watch(budgetServiceProvider);
      return BudgetAllocationNotifier(budgetService);
    });
