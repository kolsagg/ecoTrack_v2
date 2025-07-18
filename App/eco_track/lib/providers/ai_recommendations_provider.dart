import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_recommendations_service.dart';
import '../data/models/ai_recommendations_models.dart';
import '../core/errors/exceptions.dart';
import '../core/utils/dependency_injection.dart';

// AI Recommendations Service Provider - getIt'ten singleton instance'ını kullan
final aiRecommendationsServiceProvider = Provider<AiRecommendationsService>((
  ref,
) {
  return getIt<AiRecommendationsService>();
});

// Main Recommendations Provider - Gets all recommendations
final aiRecommendationsProvider =
    AsyncNotifierProvider<AiRecommendationsNotifier, RecommendationsState>(
      AiRecommendationsNotifier.new,
    );

class AiRecommendationsNotifier extends AsyncNotifier<RecommendationsState> {
  @override
  Future<RecommendationsState> build() async {
    // Ekran açıldığında ilk kategorinin verisini yükle
    Future.microtask(() => loadDataForCategory(RecommendationCategory.waste));
    return const RecommendationsState();
  }

  /// Kategori değiştir ve ilgili veriyi yükle
  void changeCategory(RecommendationCategory category) {
    // State'i hemen güncelleyerek UI'ın anında tepki vermesini sağla
    final currentState = state.valueOrNull ?? const RecommendationsState();
    state = AsyncValue.data(currentState.copyWith(selectedCategory: category));

    // Yeni seçilen kategori için veriyi yükle
    loadDataForCategory(category);
  }

  /// Kategoriye göre ilgili veriyi yükle
  Future<void> loadDataForCategory(RecommendationCategory category) async {
    switch (category) {
      case RecommendationCategory.waste:
        await loadWastePreventionAlerts();
        break;
      case RecommendationCategory.anomaly:
        await loadAnomalyAlerts();
        break;
      case RecommendationCategory.pattern:
        await loadPatternInsights();
        break;
    }
  }

  /// Load only waste prevention alerts
  Future<void> loadWastePreventionAlerts() async {
    final currentState = state.valueOrNull ?? const RecommendationsState();

    state = AsyncValue.data(
      currentState.copyWith(
        isLoadingWastePrevention: true,
        hasError: false,
        selectedCategory: RecommendationCategory.waste,
      ),
    );

    try {
      final service = ref.read(aiRecommendationsServiceProvider);
      final alerts = await service.getWastePreventionAlerts();

      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingWastePrevention: false,
          wastePreventionAlerts: alerts,
          selectedCategory: RecommendationCategory.waste,
        ),
      );
    } catch (error, stackTrace) {
      print('🔥🔥🔥 RAW ERROR in Notifier: ${error.toString()}');
      print('🔥🔥🔥 ERROR TYPE: ${error.runtimeType}');
      print('🔥🔥🔥 RAW STACKTRACE: ${stackTrace.toString()}');
      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingWastePrevention: false,
          hasError: true,
          errorMessage: _getErrorMessage(error),
          selectedCategory: RecommendationCategory.waste,
        ),
      );
    }
  }

  /// Load only anomaly alerts
  Future<void> loadAnomalyAlerts() async {
    final currentState = state.valueOrNull ?? const RecommendationsState();

    state = AsyncValue.data(
      currentState.copyWith(
        isLoadingAnomalies: true,
        hasError: false,
        selectedCategory: RecommendationCategory.anomaly,
      ),
    );

    try {
      final service = ref.read(aiRecommendationsServiceProvider);
      final alerts = await service.getAnomalyAlerts();

      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingAnomalies: false,
          anomalyAlerts: alerts,
          selectedCategory: RecommendationCategory.anomaly,
        ),
      );
    } catch (error, stackTrace) {
      print('🔥🔥🔥 RAW ERROR in Anomaly Notifier: ${error.toString()}');
      print('🔥🔥🔥 ERROR TYPE: ${error.runtimeType}');
      print('🔥🔥🔥 RAW STACKTRACE: ${stackTrace.toString()}');
      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingAnomalies: false,
          hasError: true,
          errorMessage: _getErrorMessage(error),
          selectedCategory: RecommendationCategory.anomaly,
        ),
      );
    }
  }

  /// Load only pattern insights
  Future<void> loadPatternInsights() async {
    final currentState = state.valueOrNull ?? const RecommendationsState();

    state = AsyncValue.data(
      currentState.copyWith(
        isLoadingPatterns: true,
        hasError: false,
        selectedCategory: RecommendationCategory.pattern,
      ),
    );

    try {
      final service = ref.read(aiRecommendationsServiceProvider);
      final insights = await service.getPatternInsights();

      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingPatterns: false,
          patternInsights: insights,
          selectedCategory: RecommendationCategory.pattern,
        ),
      );
    } catch (error, stackTrace) {
      print('🔥🔥🔥 RAW ERROR in Pattern Notifier: ${error.toString()}');
      print('🔥🔥🔥 ERROR TYPE: ${error.runtimeType}');
      print('🔥🔥🔥 RAW STACKTRACE: ${stackTrace.toString()}');
      state = AsyncValue.data(
        currentState.copyWith(
          isLoadingPatterns: false,
          hasError: true,
          errorMessage: _getErrorMessage(error),
          selectedCategory: RecommendationCategory.pattern,
        ),
      );
    }
  }

  /// Check service health
  Future<bool> checkHealth() async {
    try {
      final service = ref.read(aiRecommendationsServiceProvider);
      return await service.checkHealth();
    } catch (e) {
      return false;
    }
  }

  /// Clear error state
  void clearError() {
    final currentState = state.valueOrNull ?? const RecommendationsState();
    state = AsyncValue.data(
      currentState.copyWith(hasError: false, errorMessage: null),
    );
  }

  String _getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    } else if (error is ApiException) {
      return error.message;
    } else if (error is AuthException) {
      return error.message;
    } else if (error is ValidationException) {
      return error.message;
    } else {
      return 'Bilinmeyen bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}

// Individual providers for specific data types (optional, for granular access)
final wastePreventionAlertsProvider = Provider<List<WastePreventionAlert>>((
  ref,
) {
  final state = ref.watch(aiRecommendationsProvider);
  return state.valueOrNull?.wastePreventionAlerts ?? [];
});

final anomalyAlertsProvider = Provider<List<CategoryAnomalyAlert>>((ref) {
  final state = ref.watch(aiRecommendationsProvider);
  return state.valueOrNull?.anomalyAlerts ?? [];
});

final patternInsightsProvider = Provider<List<SpendingPatternInsight>>((ref) {
  final state = ref.watch(aiRecommendationsProvider);
  return state.valueOrNull?.patternInsights ?? [];
});
