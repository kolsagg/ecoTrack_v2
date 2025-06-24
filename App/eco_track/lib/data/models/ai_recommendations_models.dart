import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_recommendations_models.freezed.dart';
part 'ai_recommendations_models.g.dart';

enum RecommendationCategory { waste, anomaly, pattern }

@freezed
class WastePreventionAlert with _$WastePreventionAlert {
  const factory WastePreventionAlert({
    @JsonKey(name: 'product_name') required String productName,
    @JsonKey(name: 'estimated_shelf_life_days')
    required int estimatedShelfLifeDays,
    @JsonKey(name: 'purchase_date') required DateTime purchaseDate,
    @JsonKey(name: 'days_since_purchase') required int daysSincePurchase,
    @JsonKey(name: 'risk_level') required String riskLevel,
    @JsonKey(name: 'alert_message') required String alertMessage,
  }) = _WastePreventionAlert;

  factory WastePreventionAlert.fromJson(Map<String, dynamic> json) =>
      _$WastePreventionAlertFromJson(json);
}

@freezed
class CategoryAnomalyAlert with _$CategoryAnomalyAlert {
  const factory CategoryAnomalyAlert({
    required String category,
    @JsonKey(name: 'current_month_spending')
    required double currentMonthSpending,
    @JsonKey(name: 'average_spending') required double averageSpending,
    @JsonKey(name: 'anomaly_percentage') required double anomalyPercentage,
    required String severity,
    @JsonKey(name: 'alert_message') required String alertMessage,
    @JsonKey(name: 'suggested_action') required String suggestedAction,
  }) = _CategoryAnomalyAlert;

  factory CategoryAnomalyAlert.fromJson(Map<String, dynamic> json) =>
      _$CategoryAnomalyAlertFromJson(json);
}

@freezed
class SpendingPatternInsight with _$SpendingPatternInsight {
  const factory SpendingPatternInsight({
    @JsonKey(name: 'pattern_type') required String patternType,
    required String category,
    @JsonKey(name: 'insight_message') required String insightMessage,
    required String recommendation,
    @JsonKey(name: 'potential_savings') double? potentialSavings,
  }) = _SpendingPatternInsight;

  factory SpendingPatternInsight.fromJson(Map<String, dynamic> json) =>
      _$SpendingPatternInsightFromJson(json);
}

@freezed
class RecommendationResponse with _$RecommendationResponse {
  const factory RecommendationResponse({
    @JsonKey(name: 'waste_prevention_alerts')
    @Default([])
    List<WastePreventionAlert> wastePreventionAlerts,
    @JsonKey(name: 'anomaly_alerts')
    @Default([])
    List<CategoryAnomalyAlert> anomalyAlerts,
    @JsonKey(name: 'pattern_insights')
    @Default([])
    List<SpendingPatternInsight> patternInsights,
    @JsonKey(name: 'generated_at') required DateTime generatedAt,
  }) = _RecommendationResponse;

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) =>
      _$RecommendationResponseFromJson(json);
}

@freezed
class RecommendationsState with _$RecommendationsState {
  const factory RecommendationsState({
    @Default(RecommendationCategory.waste)
    RecommendationCategory selectedCategory,
    @Default(false) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
    RecommendationResponse? recommendations,
    @Default(false) bool isLoadingWastePrevention,
    @Default(false) bool isLoadingAnomalies,
    @Default(false) bool isLoadingPatterns,
    @Default([]) List<WastePreventionAlert> wastePreventionAlerts,
    @Default([]) List<CategoryAnomalyAlert> anomalyAlerts,
    @Default([]) List<SpendingPatternInsight> patternInsights,
  }) = _RecommendationsState;
}
