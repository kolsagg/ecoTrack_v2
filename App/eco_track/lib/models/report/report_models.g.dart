// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryDistributionRequest _$CategoryDistributionRequestFromJson(
  Map<String, dynamic> json,
) => CategoryDistributionRequest(
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  chartType: json['chart_type'] as String? ?? 'donut',
);

Map<String, dynamic> _$CategoryDistributionRequestToJson(
  CategoryDistributionRequest instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'chart_type': instance.chartType,
};

CategoryDistributionData _$CategoryDistributionDataFromJson(
  Map<String, dynamic> json,
) => CategoryDistributionData(
  label: json['label'] as String,
  value: (json['value'] as num).toDouble(),
  percentage: (json['percentage'] as num).toDouble(),
  color: json['color'] as String,
);

Map<String, dynamic> _$CategoryDistributionDataToJson(
  CategoryDistributionData instance,
) => <String, dynamic>{
  'label': instance.label,
  'value': instance.value,
  'percentage': instance.percentage,
  'color': instance.color,
};

CategoryDistributionResponse _$CategoryDistributionResponseFromJson(
  Map<String, dynamic> json,
) => CategoryDistributionResponse(
  reportTitle: json['reportTitle'] as String,
  totalAmount: (json['totalAmount'] as num).toDouble(),
  chartType: json['chartType'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => CategoryDistributionData.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CategoryDistributionResponseToJson(
  CategoryDistributionResponse instance,
) => <String, dynamic>{
  'reportTitle': instance.reportTitle,
  'totalAmount': instance.totalAmount,
  'chartType': instance.chartType,
  'data': instance.data,
};

SpendingTrendsRequest _$SpendingTrendsRequestFromJson(
  Map<String, dynamic> json,
) => SpendingTrendsRequest(
  period: json['period'] as String,
  chartType: json['chart_type'] as String? ?? 'line',
);

Map<String, dynamic> _$SpendingTrendsRequestToJson(
  SpendingTrendsRequest instance,
) => <String, dynamic>{
  'period': instance.period,
  'chart_type': instance.chartType,
};

SpendingTrendDataPoint _$SpendingTrendDataPointFromJson(
  Map<String, dynamic> json,
) => SpendingTrendDataPoint(
  x: (json['x'] as num).toInt(),
  y: (json['y'] as num).toDouble(),
);

Map<String, dynamic> _$SpendingTrendDataPointToJson(
  SpendingTrendDataPoint instance,
) => <String, dynamic>{'x': instance.x, 'y': instance.y};

SpendingTrendsDataset _$SpendingTrendsDatasetFromJson(
  Map<String, dynamic> json,
) => SpendingTrendsDataset(
  label: json['label'] as String,
  color: json['color'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => SpendingTrendDataPoint.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SpendingTrendsDatasetToJson(
  SpendingTrendsDataset instance,
) => <String, dynamic>{
  'label': instance.label,
  'color': instance.color,
  'data': instance.data,
};

SpendingTrendsResponse _$SpendingTrendsResponseFromJson(
  Map<String, dynamic> json,
) => SpendingTrendsResponse(
  reportTitle: json['reportTitle'] as String,
  chartType: json['chartType'] as String,
  xAxisLabels: Map<String, String>.from(json['xAxisLabels'] as Map),
  datasets: (json['datasets'] as List<dynamic>)
      .map((e) => SpendingTrendsDataset.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SpendingTrendsResponseToJson(
  SpendingTrendsResponse instance,
) => <String, dynamic>{
  'reportTitle': instance.reportTitle,
  'chartType': instance.chartType,
  'xAxisLabels': instance.xAxisLabels,
  'datasets': instance.datasets,
};

BudgetVsActualRequest _$BudgetVsActualRequestFromJson(
  Map<String, dynamic> json,
) => BudgetVsActualRequest(
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  chartType: json['chart_type'] as String? ?? 'bar',
);

Map<String, dynamic> _$BudgetVsActualRequestToJson(
  BudgetVsActualRequest instance,
) => <String, dynamic>{
  'year': instance.year,
  'month': instance.month,
  'chart_type': instance.chartType,
};

BudgetVsActualDataset _$BudgetVsActualDatasetFromJson(
  Map<String, dynamic> json,
) => BudgetVsActualDataset(
  label: json['label'] as String,
  color: json['color'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList(),
);

Map<String, dynamic> _$BudgetVsActualDatasetToJson(
  BudgetVsActualDataset instance,
) => <String, dynamic>{
  'label': instance.label,
  'color': instance.color,
  'data': instance.data,
};

BudgetVsActualResponse _$BudgetVsActualResponseFromJson(
  Map<String, dynamic> json,
) => BudgetVsActualResponse(
  reportTitle: json['reportTitle'] as String,
  chartType: json['chartType'] as String,
  labels: (json['labels'] as List<dynamic>).map((e) => e as String).toList(),
  datasets: (json['datasets'] as List<dynamic>)
      .map((e) => BudgetVsActualDataset.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BudgetVsActualResponseToJson(
  BudgetVsActualResponse instance,
) => <String, dynamic>{
  'reportTitle': instance.reportTitle,
  'chartType': instance.chartType,
  'labels': instance.labels,
  'datasets': instance.datasets,
};

DateRange _$DateRangeFromJson(Map<String, dynamic> json) => DateRange(
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
);

Map<String, dynamic> _$DateRangeToJson(DateRange instance) => <String, dynamic>{
  'start_date': instance.startDate.toIso8601String(),
  'end_date': instance.endDate.toIso8601String(),
};

ReportExportRequest _$ReportExportRequestFromJson(Map<String, dynamic> json) =>
    ReportExportRequest(
      format: json['format'] as String,
      reportType: json['report_type'] as String,
      dateRange: json['date_range'] == null
          ? null
          : DateRange.fromJson(json['date_range'] as Map<String, dynamic>),
      filters: json['filters'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ReportExportRequestToJson(
  ReportExportRequest instance,
) => <String, dynamic>{
  'format': instance.format,
  'report_type': instance.reportType,
  'date_range': instance.dateRange,
  'filters': instance.filters,
};
