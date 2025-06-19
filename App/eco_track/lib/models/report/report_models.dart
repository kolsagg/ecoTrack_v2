import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'report_models.g.dart';

// Category Distribution Request
@JsonSerializable()
class CategoryDistributionRequest extends Equatable {
  final int year;
  final int month; // 1-12
  @JsonKey(name: 'chart_type')
  final String chartType;

  const CategoryDistributionRequest({
    required this.year,
    required this.month,
    this.chartType = 'donut',
  });

  factory CategoryDistributionRequest.fromJson(Map<String, dynamic> json) => _$CategoryDistributionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryDistributionRequestToJson(this);

  @override
  List<Object?> get props => [year, month, chartType];
}

// Category Distribution Data Item
@JsonSerializable()
class CategoryDistributionData extends Equatable {
  final String label;
  final double value;
  final double percentage;
  final String color;

  const CategoryDistributionData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });

  factory CategoryDistributionData.fromJson(Map<String, dynamic> json) => _$CategoryDistributionDataFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryDistributionDataToJson(this);

  @override
  List<Object?> get props => [label, value, percentage, color];
}

// Category Distribution Response
@JsonSerializable()
class CategoryDistributionResponse extends Equatable {
  @JsonKey(name: 'reportTitle')
  final String reportTitle;
  @JsonKey(name: 'totalAmount')
  final double totalAmount;
  @JsonKey(name: 'chartType')
  final String chartType;
  final List<CategoryDistributionData> data;

  const CategoryDistributionResponse({
    required this.reportTitle,
    required this.totalAmount,
    required this.chartType,
    required this.data,
  });

  factory CategoryDistributionResponse.fromJson(Map<String, dynamic> json) => _$CategoryDistributionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryDistributionResponseToJson(this);

  @override
  List<Object?> get props => [reportTitle, totalAmount, chartType, data];
}

// Spending Trends Request
@JsonSerializable()
class SpendingTrendsRequest extends Equatable {
  final String period; // '3_months', '6_months', '1_year'
  @JsonKey(name: 'chart_type')
  final String chartType;

  const SpendingTrendsRequest({
    required this.period,
    this.chartType = 'line',
  });

  factory SpendingTrendsRequest.fromJson(Map<String, dynamic> json) => _$SpendingTrendsRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SpendingTrendsRequestToJson(this);

  @override
  List<Object?> get props => [period, chartType];
}

// Spending Trends Data Point
@JsonSerializable()
class SpendingTrendDataPoint extends Equatable {
  final int x;
  final double y;

  const SpendingTrendDataPoint({
    required this.x,
    required this.y,
  });

  factory SpendingTrendDataPoint.fromJson(Map<String, dynamic> json) => _$SpendingTrendDataPointFromJson(json);
  Map<String, dynamic> toJson() => _$SpendingTrendDataPointToJson(this);

  @override
  List<Object?> get props => [x, y];
}

// Spending Trends Dataset
@JsonSerializable()
class SpendingTrendsDataset extends Equatable {
  final String label;
  final String color;
  final List<SpendingTrendDataPoint> data;

  const SpendingTrendsDataset({
    required this.label,
    required this.color,
    required this.data,
  });

  factory SpendingTrendsDataset.fromJson(Map<String, dynamic> json) => _$SpendingTrendsDatasetFromJson(json);
  Map<String, dynamic> toJson() => _$SpendingTrendsDatasetToJson(this);

  @override
  List<Object?> get props => [label, color, data];
}

// Spending Trends Response
@JsonSerializable()
class SpendingTrendsResponse extends Equatable {
  @JsonKey(name: 'reportTitle')
  final String reportTitle;
  @JsonKey(name: 'chartType')
  final String chartType;
  @JsonKey(name: 'xAxisLabels')
  final Map<String, String> xAxisLabels;
  final List<SpendingTrendsDataset> datasets;

  const SpendingTrendsResponse({
    required this.reportTitle,
    required this.chartType,
    required this.xAxisLabels,
    required this.datasets,
  });

  factory SpendingTrendsResponse.fromJson(Map<String, dynamic> json) => _$SpendingTrendsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SpendingTrendsResponseToJson(this);

  @override
  List<Object?> get props => [reportTitle, chartType, xAxisLabels, datasets];
}

// Budget vs Actual Request
@JsonSerializable()
class BudgetVsActualRequest extends Equatable {
  final int year;
  final int month; // 1-12
  @JsonKey(name: 'chart_type')
  final String chartType;

  const BudgetVsActualRequest({
    required this.year,
    required this.month,
    this.chartType = 'bar',
  });

  factory BudgetVsActualRequest.fromJson(Map<String, dynamic> json) => _$BudgetVsActualRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetVsActualRequestToJson(this);

  @override
  List<Object?> get props => [year, month, chartType];
}

// Budget vs Actual Dataset
@JsonSerializable()
class BudgetVsActualDataset extends Equatable {
  final String label;
  final String color;
  final List<double> data;

  const BudgetVsActualDataset({
    required this.label,
    required this.color,
    required this.data,
  });

  factory BudgetVsActualDataset.fromJson(Map<String, dynamic> json) => _$BudgetVsActualDatasetFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetVsActualDatasetToJson(this);

  @override
  List<Object?> get props => [label, color, data];
}

// Budget vs Actual Response
@JsonSerializable()
class BudgetVsActualResponse extends Equatable {
  @JsonKey(name: 'reportTitle')
  final String reportTitle;
  @JsonKey(name: 'chartType')
  final String chartType;
  final List<String> labels;
  final List<BudgetVsActualDataset> datasets;

  const BudgetVsActualResponse({
    required this.reportTitle,
    required this.chartType,
    required this.labels,
    required this.datasets,
  });

  factory BudgetVsActualResponse.fromJson(Map<String, dynamic> json) => _$BudgetVsActualResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetVsActualResponseToJson(this);

  @override
  List<Object?> get props => [reportTitle, chartType, labels, datasets];
}

// Date Range
@JsonSerializable()
class DateRange extends Equatable {
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @JsonKey(name: 'end_date')
  final DateTime endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) => _$DateRangeFromJson(json);
  Map<String, dynamic> toJson() => _$DateRangeToJson(this);

  @override
  List<Object?> get props => [startDate, endDate];
}

// Report Export Request
@JsonSerializable()
class ReportExportRequest extends Equatable {
  final String format; // 'json' or 'csv'
  @JsonKey(name: 'report_type')
  final String reportType; // 'category-distribution', 'spending-trends', 'budget-vs-actual'
  @JsonKey(name: 'date_range')
  final DateRange? dateRange;
  final Map<String, dynamic>? filters;

  const ReportExportRequest({
    required this.format,
    required this.reportType,
    this.dateRange,
    this.filters,
  });

  factory ReportExportRequest.fromJson(Map<String, dynamic> json) => _$ReportExportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ReportExportRequestToJson(this);

  @override
  List<Object?> get props => [format, reportType, dateRange, filters];
}

 