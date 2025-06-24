// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_inflation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MonthlyInflationImpl _$$MonthlyInflationImplFromJson(
  Map<String, dynamic> json,
) => _$MonthlyInflationImpl(
  id: json['id'] as String,
  productName: json['product_name'] as String,
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  averagePrice: (json['average_price'] as num).toDouble(),
  purchaseCount: (json['purchase_count'] as num).toInt(),
  previousMonthPrice: (json['previous_month_price'] as num?)?.toDouble(),
  inflationPercentage: (json['inflation_percentage'] as num?)?.toDouble(),
  lastUpdatedAt: json['last_updated_at'] as String,
);

Map<String, dynamic> _$$MonthlyInflationImplToJson(
  _$MonthlyInflationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_name': instance.productName,
  'year': instance.year,
  'month': instance.month,
  'average_price': instance.averagePrice,
  'purchase_count': instance.purchaseCount,
  'previous_month_price': instance.previousMonthPrice,
  'inflation_percentage': instance.inflationPercentage,
  'last_updated_at': instance.lastUpdatedAt,
};
