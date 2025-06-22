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

// Transaction Type Enum
enum TransactionType {
  @JsonValue('expense')
  expense,
  @JsonValue('bonus')
  bonus,
  @JsonValue('adjustment')
  adjustment,
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.adjustment:
        return 'Adjustment';
    }
  }

  String get description {
    switch (this) {
      case TransactionType.expense:
        return 'Points earned from purchases';
      case TransactionType.bonus:
        return 'Bonus points from promotions';
      case TransactionType.adjustment:
        return 'Manual point adjustments';
    }
  }
}

// Loyalty Transaction Model
@JsonSerializable()
class LoyaltyTransaction extends Equatable {
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'expense_id')
  final String? expenseId;
  @JsonKey(name: 'points_earned')
  final int pointsEarned;
  @JsonKey(name: 'transaction_amount')
  final double transactionAmount;
  @JsonKey(name: 'merchant_name')
  final String? merchantName;
  final String? category;
  @JsonKey(name: 'calculation_details')
  final Map<String, dynamic> calculationDetails;
  @JsonKey(name: 'transaction_type')
  final TransactionType transactionType;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const LoyaltyTransaction({
    required this.id,
    this.userId,
    this.expenseId,
    required this.pointsEarned,
    required this.transactionAmount,
    this.merchantName,
    this.category,
    required this.calculationDetails,
    required this.transactionType,
    required this.createdAt,
    this.updatedAt,
  });

  factory LoyaltyTransaction.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransaction(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String?,
      expenseId: json['expense_id'] as String?,
      pointsEarned: (json['points_earned'] as num?)?.toInt() ?? 0,
      transactionAmount:
          (json['transaction_amount'] as num?)?.toDouble() ?? 0.0,
      merchantName: json['merchant_name'] as String?,
      category: json['category'] as String?,
      calculationDetails:
          (json['calculation_details'] as Map<String, dynamic>?) ?? {},
      transactionType: _parseTransactionType(json['transaction_type']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: json['updated_at'] != null
          ? _parseDateTime(json['updated_at'])
          : null,
    );
  }

  static TransactionType _parseTransactionType(dynamic value) {
    if (value == null) return TransactionType.expense;
    final stringValue = value.toString().toLowerCase();
    switch (stringValue) {
      case 'bonus':
        return TransactionType.bonus;
      case 'adjustment':
        return TransactionType.adjustment;
      default:
        return TransactionType.expense;
    }
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() => _$LoyaltyTransactionToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    expenseId,
    pointsEarned,
    transactionAmount,
    merchantName,
    category,
    calculationDetails,
    transactionType,
    createdAt,
    updatedAt,
  ];
}

// Loyalty History Response (updated)
@JsonSerializable()
class LoyaltyHistoryResponse extends Equatable {
  final bool success;
  final int count;
  @JsonKey(name: 'history')
  final List<LoyaltyTransaction> transactions;

  const LoyaltyHistoryResponse({
    required this.success,
    required this.count,
    required this.transactions,
  });

  factory LoyaltyHistoryResponse.fromJson(Map<String, dynamic> json) {
    return LoyaltyHistoryResponse(
      success: json['success'] as bool? ?? false,
      count: json['count'] as int? ?? 0,
      transactions:
          (json['history'] as List<dynamic>?)
              ?.map(
                (e) => LoyaltyTransaction.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => _$LoyaltyHistoryResponseToJson(this);

  @override
  List<Object?> get props => [success, count, transactions];
}

// Legacy Loyalty History Item (keeping for backward compatibility)
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
