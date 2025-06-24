import 'package:freezed_annotation/freezed_annotation.dart';

part 'monthly_inflation.freezed.dart';
part 'monthly_inflation.g.dart';

@freezed
class MonthlyInflation with _$MonthlyInflation {
  const factory MonthlyInflation({
    required String id,
    @JsonKey(name: 'product_name') required String productName,
    required int year,
    required int month,
    @JsonKey(name: 'average_price') required double averagePrice,
    @JsonKey(name: 'purchase_count') required int purchaseCount,
    @JsonKey(name: 'previous_month_price') double? previousMonthPrice,
    @JsonKey(name: 'inflation_percentage') double? inflationPercentage,
    @JsonKey(name: 'last_updated_at') required String lastUpdatedAt,
  }) = _MonthlyInflation;

  factory MonthlyInflation.fromJson(Map<String, dynamic> json) =>
      _$MonthlyInflationFromJson(json);
}

@freezed
class MonthlyInflationState with _$MonthlyInflationState {
  const factory MonthlyInflationState({
    @Default([]) List<MonthlyInflation> data,
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default(null) int? selectedYear,
    @Default(null) int? selectedMonth,
    @Default('') String searchQuery,
    @Default('inflation_percentage') String sortBy,
    @Default('desc') String order,
  }) = _MonthlyInflationState;
}
