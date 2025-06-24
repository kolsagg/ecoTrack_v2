// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_recommendations_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WastePreventionAlertImpl _$$WastePreventionAlertImplFromJson(
  Map<String, dynamic> json,
) => _$WastePreventionAlertImpl(
  productName: json['product_name'] as String,
  estimatedShelfLifeDays: (json['estimated_shelf_life_days'] as num).toInt(),
  purchaseDate: DateTime.parse(json['purchase_date'] as String),
  daysSincePurchase: (json['days_since_purchase'] as num).toInt(),
  riskLevel: json['risk_level'] as String,
  alertMessage: json['alert_message'] as String,
);

Map<String, dynamic> _$$WastePreventionAlertImplToJson(
  _$WastePreventionAlertImpl instance,
) => <String, dynamic>{
  'product_name': instance.productName,
  'estimated_shelf_life_days': instance.estimatedShelfLifeDays,
  'purchase_date': instance.purchaseDate.toIso8601String(),
  'days_since_purchase': instance.daysSincePurchase,
  'risk_level': instance.riskLevel,
  'alert_message': instance.alertMessage,
};

_$CategoryAnomalyAlertImpl _$$CategoryAnomalyAlertImplFromJson(
  Map<String, dynamic> json,
) => _$CategoryAnomalyAlertImpl(
  category: json['category'] as String,
  currentMonthSpending: (json['current_month_spending'] as num).toDouble(),
  averageSpending: (json['average_spending'] as num).toDouble(),
  anomalyPercentage: (json['anomaly_percentage'] as num).toDouble(),
  severity: json['severity'] as String,
  alertMessage: json['alert_message'] as String,
  suggestedAction: json['suggested_action'] as String,
);

Map<String, dynamic> _$$CategoryAnomalyAlertImplToJson(
  _$CategoryAnomalyAlertImpl instance,
) => <String, dynamic>{
  'category': instance.category,
  'current_month_spending': instance.currentMonthSpending,
  'average_spending': instance.averageSpending,
  'anomaly_percentage': instance.anomalyPercentage,
  'severity': instance.severity,
  'alert_message': instance.alertMessage,
  'suggested_action': instance.suggestedAction,
};

_$SpendingPatternInsightImpl _$$SpendingPatternInsightImplFromJson(
  Map<String, dynamic> json,
) => _$SpendingPatternInsightImpl(
  patternType: json['pattern_type'] as String,
  category: json['category'] as String,
  insightMessage: json['insight_message'] as String,
  recommendation: json['recommendation'] as String,
  potentialSavings: (json['potential_savings'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$SpendingPatternInsightImplToJson(
  _$SpendingPatternInsightImpl instance,
) => <String, dynamic>{
  'pattern_type': instance.patternType,
  'category': instance.category,
  'insight_message': instance.insightMessage,
  'recommendation': instance.recommendation,
  'potential_savings': instance.potentialSavings,
};

_$RecommendationResponseImpl _$$RecommendationResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RecommendationResponseImpl(
  wastePreventionAlerts:
      (json['waste_prevention_alerts'] as List<dynamic>?)
          ?.map((e) => WastePreventionAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  anomalyAlerts:
      (json['anomaly_alerts'] as List<dynamic>?)
          ?.map((e) => CategoryAnomalyAlert.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  patternInsights:
      (json['pattern_insights'] as List<dynamic>?)
          ?.map(
            (e) => SpendingPatternInsight.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  generatedAt: DateTime.parse(json['generated_at'] as String),
);

Map<String, dynamic> _$$RecommendationResponseImplToJson(
  _$RecommendationResponseImpl instance,
) => <String, dynamic>{
  'waste_prevention_alerts': instance.wastePreventionAlerts,
  'anomaly_alerts': instance.anomalyAlerts,
  'pattern_insights': instance.patternInsights,
  'generated_at': instance.generatedAt.toIso8601String(),
};
