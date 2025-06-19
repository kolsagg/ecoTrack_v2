import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/dependency_injection.dart';
import '../models/loyalty/loyalty_models.dart';
import '../services/loyalty_service.dart';

// Loyalty Service Provider
final loyaltyServiceProvider = Provider<LoyaltyService>((ref) {
  return getIt<LoyaltyService>();
});

// Loyalty Status State
class LoyaltyStatusState {
  final LoyaltyStatusResponse? status;
  final bool isLoading;
  final String? error;

  const LoyaltyStatusState({this.status, this.isLoading = false, this.error});

  LoyaltyStatusState copyWith({
    LoyaltyStatusResponse? status,
    bool? isLoading,
    String? error,
  }) {
    return LoyaltyStatusState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Loyalty Status Notifier
class LoyaltyStatusNotifier extends StateNotifier<LoyaltyStatusState> {
  final LoyaltyService _loyaltyService;

  LoyaltyStatusNotifier(this._loyaltyService)
    : super(const LoyaltyStatusState());

  Future<void> loadLoyaltyStatus() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final status = await _loyaltyService.getLoyaltyStatus();

      state = state.copyWith(status: status, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LoyaltyStatusState();
  }
}

// Points Calculator State
class PointsCalculatorState {
  final PointsCalculationResponse? calculation;
  final bool isLoading;
  final String? error;

  const PointsCalculatorState({
    this.calculation,
    this.isLoading = false,
    this.error,
  });

  PointsCalculatorState copyWith({
    PointsCalculationResponse? calculation,
    bool? isLoading,
    String? error,
  }) {
    return PointsCalculatorState(
      calculation: calculation ?? this.calculation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Points Calculator Notifier
class PointsCalculatorNotifier extends StateNotifier<PointsCalculatorState> {
  final LoyaltyService _loyaltyService;

  PointsCalculatorNotifier(this._loyaltyService)
    : super(const PointsCalculatorState());

  Future<void> calculatePoints({
    required double amount,
    String? category,
    String? merchantName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final calculation = await _loyaltyService.calculatePoints(
        amount: amount,
        category: category,
        merchantName: merchantName,
      );

      state = state.copyWith(calculation: calculation, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearCalculation() {
    state = state.copyWith(calculation: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const PointsCalculatorState();
  }
}

// Loyalty History State
class LoyaltyHistoryState {
  final LoyaltyHistoryResponse? history;
  final bool isLoading;
  final String? error;

  const LoyaltyHistoryState({this.history, this.isLoading = false, this.error});

  LoyaltyHistoryState copyWith({
    LoyaltyHistoryResponse? history,
    bool? isLoading,
    String? error,
  }) {
    return LoyaltyHistoryState(
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Loyalty History Notifier
class LoyaltyHistoryNotifier extends StateNotifier<LoyaltyHistoryState> {
  final LoyaltyService _loyaltyService;

  LoyaltyHistoryNotifier(this._loyaltyService)
    : super(const LoyaltyHistoryState());

  Future<void> loadLoyaltyHistory({int limit = 50}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final history = await _loyaltyService.getLoyaltyHistory(limit: limit);

      state = state.copyWith(history: history, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LoyaltyHistoryState();
  }
}

// Loyalty Levels State
class LoyaltyLevelsState {
  final LoyaltyLevelsResponse? levels;
  final bool isLoading;
  final String? error;

  const LoyaltyLevelsState({this.levels, this.isLoading = false, this.error});

  LoyaltyLevelsState copyWith({
    LoyaltyLevelsResponse? levels,
    bool? isLoading,
    String? error,
  }) {
    return LoyaltyLevelsState(
      levels: levels ?? this.levels,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Loyalty Levels Notifier
class LoyaltyLevelsNotifier extends StateNotifier<LoyaltyLevelsState> {
  final LoyaltyService _loyaltyService;

  LoyaltyLevelsNotifier(this._loyaltyService)
    : super(const LoyaltyLevelsState());

  Future<void> loadLoyaltyLevels() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final levels = await _loyaltyService.getLoyaltyLevels();

      state = state.copyWith(levels: levels, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LoyaltyLevelsState();
  }
}

// Providers
final loyaltyStatusProvider =
    StateNotifierProvider<LoyaltyStatusNotifier, LoyaltyStatusState>((ref) {
      final loyaltyService = ref.watch(loyaltyServiceProvider);
      return LoyaltyStatusNotifier(loyaltyService);
    });

final pointsCalculatorProvider =
    StateNotifierProvider<PointsCalculatorNotifier, PointsCalculatorState>((
      ref,
    ) {
      final loyaltyService = ref.watch(loyaltyServiceProvider);
      return PointsCalculatorNotifier(loyaltyService);
    });

final loyaltyHistoryProvider =
    StateNotifierProvider<LoyaltyHistoryNotifier, LoyaltyHistoryState>((ref) {
      final loyaltyService = ref.watch(loyaltyServiceProvider);
      return LoyaltyHistoryNotifier(loyaltyService);
    });

final loyaltyLevelsProvider =
    StateNotifierProvider<LoyaltyLevelsNotifier, LoyaltyLevelsState>((ref) {
      final loyaltyService = ref.watch(loyaltyServiceProvider);
      return LoyaltyLevelsNotifier(loyaltyService);
    });
