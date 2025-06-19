import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../models/report/report_models.dart';
import '../services/reports_service.dart';

// Reports Service Provider
final reportsServiceProvider = Provider<ReportsService>((ref) {
  return getIt<ReportsService>();
});



// Category Distribution State
class CategoryDistributionState {
  final CategoryDistributionResponse? data;
  final bool isLoading;
  final String? error;

  const CategoryDistributionState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  CategoryDistributionState copyWith({
    CategoryDistributionResponse? data,
    bool? isLoading,
    String? error,
  }) {
    return CategoryDistributionState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Category Distribution Notifier
class CategoryDistributionNotifier extends StateNotifier<CategoryDistributionState> {
  final ReportsService _reportsService;

  CategoryDistributionNotifier(this._reportsService) : super(const CategoryDistributionState());

  Future<void> loadCategoryDistribution({
    int? year,
    int? month,
    String chartType = 'donut',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final now = DateTime.now();
      final data = await _reportsService.getCategoryDistribution(
        year: year ?? now.year,
        month: month ?? now.month,
        chartType: chartType,
      );
      
      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const CategoryDistributionState();
  }
}

// Category Distribution Provider
final categoryDistributionProvider = StateNotifierProvider<CategoryDistributionNotifier, CategoryDistributionState>((ref) {
  final reportsService = ref.watch(reportsServiceProvider);
  return CategoryDistributionNotifier(reportsService);
});

// Spending Trends State
class SpendingTrendsState {
  final SpendingTrendsResponse? data;
  final bool isLoading;
  final String? error;

  const SpendingTrendsState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  SpendingTrendsState copyWith({
    SpendingTrendsResponse? data,
    bool? isLoading,
    String? error,
  }) {
    return SpendingTrendsState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Spending Trends Notifier
class SpendingTrendsNotifier extends StateNotifier<SpendingTrendsState> {
  final ReportsService _reportsService;

  SpendingTrendsNotifier(this._reportsService) : super(const SpendingTrendsState());

  Future<void> loadSpendingTrends({
    String period = '3_months',
    String chartType = 'line',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final data = await _reportsService.getSpendingTrends(
        period: period,
        chartType: chartType,
      );
      
      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const SpendingTrendsState();
  }
}

// Spending Trends Provider
final spendingTrendsProvider = StateNotifierProvider<SpendingTrendsNotifier, SpendingTrendsState>((ref) {
  final reportsService = ref.watch(reportsServiceProvider);
  return SpendingTrendsNotifier(reportsService);
});

// Budget vs Actual State
class BudgetVsActualState {
  final BudgetVsActualResponse? data;
  final bool isLoading;
  final String? error;

  const BudgetVsActualState({
    this.data,
    this.isLoading = false,
    this.error,
  });

  BudgetVsActualState copyWith({
    BudgetVsActualResponse? data,
    bool? isLoading,
    String? error,
  }) {
    return BudgetVsActualState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Budget vs Actual Notifier
class BudgetVsActualNotifier extends StateNotifier<BudgetVsActualState> {
  final ReportsService _reportsService;

  BudgetVsActualNotifier(this._reportsService) : super(const BudgetVsActualState());

  Future<void> loadBudgetVsActual({
    int? year,
    int? month,
    String chartType = 'bar',
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final now = DateTime.now();
      final data = await _reportsService.getBudgetVsActual(
        year: year ?? now.year,
        month: month ?? now.month,
        chartType: chartType,
      );
      
      state = state.copyWith(
        data: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const BudgetVsActualState();
  }
}

// Budget vs Actual Provider
final budgetVsActualProvider = StateNotifierProvider<BudgetVsActualNotifier, BudgetVsActualState>((ref) {
  final reportsService = ref.watch(reportsServiceProvider);
  return BudgetVsActualNotifier(reportsService);
});

// Report Export State
class ReportExportState {
  final String? exportedData;
  final bool isLoading;
  final String? error;

  const ReportExportState({
    this.exportedData,
    this.isLoading = false,
    this.error,
  });

  ReportExportState copyWith({
    String? exportedData,
    bool? isLoading,
    String? error,
  }) {
    return ReportExportState(
      exportedData: exportedData ?? this.exportedData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Report Export Notifier
class ReportExportNotifier extends StateNotifier<ReportExportState> {
  final ReportsService _reportsService;

  ReportExportNotifier(this._reportsService) : super(const ReportExportState());

  Future<void> exportReport(ReportExportRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final data = await _reportsService.exportReport(request);
      
      state = state.copyWith(
        exportedData: data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const ReportExportState();
  }
}

// Report Export Provider
final reportExportProvider = StateNotifierProvider<ReportExportNotifier, ReportExportState>((ref) {
  final reportsService = ref.watch(reportsServiceProvider);
  return ReportExportNotifier(reportsService);
}); 