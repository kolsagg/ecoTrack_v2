// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loyalty_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoyaltyStatusResponse _$LoyaltyStatusResponseFromJson(
  Map<String, dynamic> json,
) => LoyaltyStatusResponse(
  userId: json['user_id'] as String,
  points: (json['points'] as num).toInt(),
  level: $enumDecodeNullable(_$LoyaltyLevelEnumMap, json['level']),
  pointsToNextLevel: (json['points_to_next_level'] as num?)?.toInt(),
  nextLevel: $enumDecodeNullable(_$LoyaltyLevelEnumMap, json['next_level']),
  lastUpdated: DateTime.parse(json['last_updated'] as String),
);

Map<String, dynamic> _$LoyaltyStatusResponseToJson(
  LoyaltyStatusResponse instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'points': instance.points,
  'level': _$LoyaltyLevelEnumMap[instance.level],
  'points_to_next_level': instance.pointsToNextLevel,
  'next_level': _$LoyaltyLevelEnumMap[instance.nextLevel],
  'last_updated': instance.lastUpdated.toIso8601String(),
};

const _$LoyaltyLevelEnumMap = {
  LoyaltyLevel.bronze: 'bronze',
  LoyaltyLevel.silver: 'silver',
  LoyaltyLevel.gold: 'gold',
  LoyaltyLevel.platinum: 'platinum',
};

PointsCalculationResponse _$PointsCalculationResponseFromJson(
  Map<String, dynamic> json,
) => PointsCalculationResponse(
  basePoints: (json['base_points'] as num).toInt(),
  bonusPoints: (json['bonus_points'] as num).toInt(),
  totalPoints: (json['total_points'] as num).toInt(),
  calculationDetails: CalculationDetails.fromJson(
    json['calculation_details'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$PointsCalculationResponseToJson(
  PointsCalculationResponse instance,
) => <String, dynamic>{
  'base_points': instance.basePoints,
  'bonus_points': instance.bonusPoints,
  'total_points': instance.totalPoints,
  'calculation_details': instance.calculationDetails,
};

CalculationDetails _$CalculationDetailsFromJson(Map<String, dynamic> json) =>
    CalculationDetails(
      baseRate: (json['base_rate'] as num).toDouble(),
      categoryBonus: (json['category_bonus'] as num?)?.toDouble(),
      levelMultiplier: (json['level_multiplier'] as num).toDouble(),
    );

Map<String, dynamic> _$CalculationDetailsToJson(CalculationDetails instance) =>
    <String, dynamic>{
      'base_rate': instance.baseRate,
      'category_bonus': instance.categoryBonus,
      'level_multiplier': instance.levelMultiplier,
    };

LoyaltyTransaction _$LoyaltyTransactionFromJson(Map<String, dynamic> json) =>
    LoyaltyTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      expenseId: json['expense_id'] as String?,
      pointsEarned: (json['points_earned'] as num).toInt(),
      transactionAmount: (json['transaction_amount'] as num).toDouble(),
      merchantName: json['merchant_name'] as String?,
      category: json['category'] as String?,
      calculationDetails: json['calculation_details'] as Map<String, dynamic>,
      transactionType: $enumDecode(
        _$TransactionTypeEnumMap,
        json['transaction_type'],
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$LoyaltyTransactionToJson(LoyaltyTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'expense_id': instance.expenseId,
      'points_earned': instance.pointsEarned,
      'transaction_amount': instance.transactionAmount,
      'merchant_name': instance.merchantName,
      'category': instance.category,
      'calculation_details': instance.calculationDetails,
      'transaction_type': _$TransactionTypeEnumMap[instance.transactionType]!,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$TransactionTypeEnumMap = {
  TransactionType.expense: 'expense',
  TransactionType.bonus: 'bonus',
  TransactionType.adjustment: 'adjustment',
};

LoyaltyHistoryResponse _$LoyaltyHistoryResponseFromJson(
  Map<String, dynamic> json,
) => LoyaltyHistoryResponse(
  success: json['success'] as bool,
  count: (json['count'] as num).toInt(),
  transactions: (json['history'] as List<dynamic>)
      .map((e) => LoyaltyTransaction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LoyaltyHistoryResponseToJson(
  LoyaltyHistoryResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'count': instance.count,
  'history': instance.transactions,
};

LoyaltyHistoryItem _$LoyaltyHistoryItemFromJson(Map<String, dynamic> json) =>
    LoyaltyHistoryItem(
      transactionId: json['transaction_id'] as String,
      userId: json['user_id'] as String,
      pointsEarned: (json['points_earned'] as num).toInt(),
      transactionAmount: (json['transaction_amount'] as num).toDouble(),
      merchantName: json['merchant_name'] as String?,
      calculationDetails: HistoryCalculationDetails.fromJson(
        json['calculation_details'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LoyaltyHistoryItemToJson(LoyaltyHistoryItem instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'user_id': instance.userId,
      'points_earned': instance.pointsEarned,
      'transaction_amount': instance.transactionAmount,
      'merchant_name': instance.merchantName,
      'calculation_details': instance.calculationDetails,
      'created_at': instance.createdAt.toIso8601String(),
    };

HistoryCalculationDetails _$HistoryCalculationDetailsFromJson(
  Map<String, dynamic> json,
) => HistoryCalculationDetails(
  basePoints: (json['base_points'] as num).toInt(),
  bonusPoints: (json['bonus_points'] as num).toInt(),
);

Map<String, dynamic> _$HistoryCalculationDetailsToJson(
  HistoryCalculationDetails instance,
) => <String, dynamic>{
  'base_points': instance.basePoints,
  'bonus_points': instance.bonusPoints,
};

LoyaltyLevelsResponse _$LoyaltyLevelsResponseFromJson(
  Map<String, dynamic> json,
) => LoyaltyLevelsResponse(
  success: json['success'] as bool,
  levels: (json['levels'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, LoyaltyLevelInfo.fromJson(e as Map<String, dynamic>)),
  ),
  categoryBonuses: Map<String, String>.from(json['category_bonuses'] as Map),
);

Map<String, dynamic> _$LoyaltyLevelsResponseToJson(
  LoyaltyLevelsResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'levels': instance.levels,
  'category_bonuses': instance.categoryBonuses,
};

LoyaltyLevelInfo _$LoyaltyLevelInfoFromJson(Map<String, dynamic> json) =>
    LoyaltyLevelInfo(
      name: json['name'] as String,
      pointsRequired: (json['points_required'] as num).toInt(),
      multiplier: (json['multiplier'] as num).toDouble(),
      benefits: (json['benefits'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LoyaltyLevelInfoToJson(LoyaltyLevelInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'points_required': instance.pointsRequired,
      'multiplier': instance.multiplier,
      'benefits': instance.benefits,
    };
