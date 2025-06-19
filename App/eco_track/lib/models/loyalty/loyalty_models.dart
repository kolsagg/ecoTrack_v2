import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'loyalty_models.g.dart';

// Loyalty Level Enum
enum LoyaltyLevel {
  @JsonValue('bronze')
  bronze,
  @JsonValue('silver')
  silver,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum,
}

extension LoyaltyLevelExtension on LoyaltyLevel {
  String get displayName {
    switch (this) {
      case LoyaltyLevel.bronze:
        return 'Bronze';
      case LoyaltyLevel.silver:
        return 'Silver';
      case LoyaltyLevel.gold:
        return 'Gold';
      case LoyaltyLevel.platinum:
        return 'Platinum';
    }
  }

  String get description {
    switch (this) {
      case LoyaltyLevel.bronze:
        return 'Start your journey';
      case LoyaltyLevel.silver:
        return 'Unlock bonus rewards';
      case LoyaltyLevel.gold:
        return 'Premium benefits';
      case LoyaltyLevel.platinum:
        return 'Ultimate rewards';
    }
  }

  int get colorValue {
    switch (this) {
      case LoyaltyLevel.bronze:
        return 0xFFCD7F32; // Bronze color
      case LoyaltyLevel.silver:
        return 0xFFC0C0C0; // Silver color
      case LoyaltyLevel.gold:
        return 0xFFFFD700; // Gold color
      case LoyaltyLevel.platinum:
        return 0xFFE5E4E2; // Platinum color
    }
  }
}

// Loyalty Status Response
@JsonSerializable()
class LoyaltyStatusResponse extends Equatable {
  @JsonKey(name: 'user_id')
  final String userId;
  final int points;
  final LoyaltyLevel? level;
  @JsonKey(name: 'points_to_next_level')
  final int? pointsToNextLevel;
  @JsonKey(name: 'next_level')
  final LoyaltyLevel? nextLevel;
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  const LoyaltyStatusResponse({
    required this.userId,
    required this.points,
    this.level,
    this.pointsToNextLevel,
    this.nextLevel,
    required this.lastUpdated,
  });

  factory LoyaltyStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyStatusResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyStatusResponseToJson(this);

  @override
  List<Object?> get props => [
    userId,
    points,
    level,
    pointsToNextLevel,
    nextLevel,
    lastUpdated,
  ];
}

// Points Calculation Response
@JsonSerializable()
class PointsCalculationResponse extends Equatable {
  @JsonKey(name: 'base_points')
  final int basePoints;
  @JsonKey(name: 'bonus_points')
  final int bonusPoints;
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @JsonKey(name: 'calculation_details')
  final CalculationDetails calculationDetails;

  const PointsCalculationResponse({
    required this.basePoints,
    required this.bonusPoints,
    required this.totalPoints,
    required this.calculationDetails,
  });

  factory PointsCalculationResponse.fromJson(Map<String, dynamic> json) =>
      _$PointsCalculationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PointsCalculationResponseToJson(this);

  @override
  List<Object?> get props => [
    basePoints,
    bonusPoints,
    totalPoints,
    calculationDetails,
  ];
}

// Calculation Details
@JsonSerializable()
class CalculationDetails extends Equatable {
  @JsonKey(name: 'base_rate')
  final double baseRate;
  @JsonKey(name: 'category_bonus')
  final double? categoryBonus;
  @JsonKey(name: 'level_multiplier')
  final double levelMultiplier;

  const CalculationDetails({
    required this.baseRate,
    this.categoryBonus,
    required this.levelMultiplier,
  });

  factory CalculationDetails.fromJson(Map<String, dynamic> json) =>
      _$CalculationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CalculationDetailsToJson(this);

  @override
  List<Object?> get props => [baseRate, categoryBonus, levelMultiplier];
}

// Loyalty History Response
@JsonSerializable()
class LoyaltyHistoryResponse extends Equatable {
  final bool success;
  final int count;
  final List<LoyaltyHistoryItem> history;

  const LoyaltyHistoryResponse({
    required this.success,
    required this.count,
    required this.history,
  });

  factory LoyaltyHistoryResponse.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyHistoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyHistoryResponseToJson(this);

  @override
  List<Object?> get props => [success, count, history];
}

// Loyalty History Item
@JsonSerializable()
class LoyaltyHistoryItem extends Equatable {
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'points_earned')
  final int pointsEarned;
  @JsonKey(name: 'transaction_amount')
  final double transactionAmount;
  @JsonKey(name: 'merchant_name')
  final String? merchantName;
  @JsonKey(name: 'calculation_details')
  final HistoryCalculationDetails calculationDetails;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const LoyaltyHistoryItem({
    required this.transactionId,
    required this.userId,
    required this.pointsEarned,
    required this.transactionAmount,
    this.merchantName,
    required this.calculationDetails,
    required this.createdAt,
  });

  factory LoyaltyHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyHistoryItemFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyHistoryItemToJson(this);

  @override
  List<Object?> get props => [
    transactionId,
    userId,
    pointsEarned,
    transactionAmount,
    merchantName,
    calculationDetails,
    createdAt,
  ];
}

// History Calculation Details
@JsonSerializable()
class HistoryCalculationDetails extends Equatable {
  @JsonKey(name: 'base_points')
  final int basePoints;
  @JsonKey(name: 'bonus_points')
  final int bonusPoints;

  const HistoryCalculationDetails({
    required this.basePoints,
    required this.bonusPoints,
  });

  factory HistoryCalculationDetails.fromJson(Map<String, dynamic> json) =>
      _$HistoryCalculationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryCalculationDetailsToJson(this);

  @override
  List<Object?> get props => [basePoints, bonusPoints];
}

// Loyalty Levels Response
@JsonSerializable()
class LoyaltyLevelsResponse extends Equatable {
  final bool success;
  final Map<String, LoyaltyLevelInfo> levels;
  @JsonKey(name: 'category_bonuses')
  final Map<String, String> categoryBonuses;

  const LoyaltyLevelsResponse({
    required this.success,
    required this.levels,
    required this.categoryBonuses,
  });

  factory LoyaltyLevelsResponse.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyLevelsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyLevelsResponseToJson(this);

  @override
  List<Object?> get props => [success, levels, categoryBonuses];
}

// Loyalty Level Info
@JsonSerializable()
class LoyaltyLevelInfo extends Equatable {
  final String name;
  @JsonKey(name: 'points_required')
  final int pointsRequired;
  final double multiplier;
  final List<String> benefits;

  const LoyaltyLevelInfo({
    required this.name,
    required this.pointsRequired,
    required this.multiplier,
    required this.benefits,
  });

  factory LoyaltyLevelInfo.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyLevelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LoyaltyLevelInfoToJson(this);

  @override
  List<Object?> get props => [name, pointsRequired, multiplier, benefits];
}
