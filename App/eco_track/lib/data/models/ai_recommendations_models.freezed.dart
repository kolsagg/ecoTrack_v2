// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_recommendations_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WastePreventionAlert _$WastePreventionAlertFromJson(Map<String, dynamic> json) {
  return _WastePreventionAlert.fromJson(json);
}

/// @nodoc
mixin _$WastePreventionAlert {
  @JsonKey(name: 'product_name')
  String get productName => throw _privateConstructorUsedError;
  @JsonKey(name: 'estimated_shelf_life_days')
  int get estimatedShelfLifeDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'purchase_date')
  DateTime get purchaseDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_since_purchase')
  int get daysSincePurchase => throw _privateConstructorUsedError;
  @JsonKey(name: 'risk_level')
  String get riskLevel => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_message')
  String get alertMessage => throw _privateConstructorUsedError;

  /// Serializes this WastePreventionAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WastePreventionAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WastePreventionAlertCopyWith<WastePreventionAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WastePreventionAlertCopyWith<$Res> {
  factory $WastePreventionAlertCopyWith(
    WastePreventionAlert value,
    $Res Function(WastePreventionAlert) then,
  ) = _$WastePreventionAlertCopyWithImpl<$Res, WastePreventionAlert>;
  @useResult
  $Res call({
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'estimated_shelf_life_days') int estimatedShelfLifeDays,
    @JsonKey(name: 'purchase_date') DateTime purchaseDate,
    @JsonKey(name: 'days_since_purchase') int daysSincePurchase,
    @JsonKey(name: 'risk_level') String riskLevel,
    @JsonKey(name: 'alert_message') String alertMessage,
  });
}

/// @nodoc
class _$WastePreventionAlertCopyWithImpl<
  $Res,
  $Val extends WastePreventionAlert
>
    implements $WastePreventionAlertCopyWith<$Res> {
  _$WastePreventionAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WastePreventionAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? estimatedShelfLifeDays = null,
    Object? purchaseDate = null,
    Object? daysSincePurchase = null,
    Object? riskLevel = null,
    Object? alertMessage = null,
  }) {
    return _then(
      _value.copyWith(
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            estimatedShelfLifeDays: null == estimatedShelfLifeDays
                ? _value.estimatedShelfLifeDays
                : estimatedShelfLifeDays // ignore: cast_nullable_to_non_nullable
                      as int,
            purchaseDate: null == purchaseDate
                ? _value.purchaseDate
                : purchaseDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            daysSincePurchase: null == daysSincePurchase
                ? _value.daysSincePurchase
                : daysSincePurchase // ignore: cast_nullable_to_non_nullable
                      as int,
            riskLevel: null == riskLevel
                ? _value.riskLevel
                : riskLevel // ignore: cast_nullable_to_non_nullable
                      as String,
            alertMessage: null == alertMessage
                ? _value.alertMessage
                : alertMessage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WastePreventionAlertImplCopyWith<$Res>
    implements $WastePreventionAlertCopyWith<$Res> {
  factory _$$WastePreventionAlertImplCopyWith(
    _$WastePreventionAlertImpl value,
    $Res Function(_$WastePreventionAlertImpl) then,
  ) = __$$WastePreventionAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'product_name') String productName,
    @JsonKey(name: 'estimated_shelf_life_days') int estimatedShelfLifeDays,
    @JsonKey(name: 'purchase_date') DateTime purchaseDate,
    @JsonKey(name: 'days_since_purchase') int daysSincePurchase,
    @JsonKey(name: 'risk_level') String riskLevel,
    @JsonKey(name: 'alert_message') String alertMessage,
  });
}

/// @nodoc
class __$$WastePreventionAlertImplCopyWithImpl<$Res>
    extends _$WastePreventionAlertCopyWithImpl<$Res, _$WastePreventionAlertImpl>
    implements _$$WastePreventionAlertImplCopyWith<$Res> {
  __$$WastePreventionAlertImplCopyWithImpl(
    _$WastePreventionAlertImpl _value,
    $Res Function(_$WastePreventionAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WastePreventionAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productName = null,
    Object? estimatedShelfLifeDays = null,
    Object? purchaseDate = null,
    Object? daysSincePurchase = null,
    Object? riskLevel = null,
    Object? alertMessage = null,
  }) {
    return _then(
      _$WastePreventionAlertImpl(
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        estimatedShelfLifeDays: null == estimatedShelfLifeDays
            ? _value.estimatedShelfLifeDays
            : estimatedShelfLifeDays // ignore: cast_nullable_to_non_nullable
                  as int,
        purchaseDate: null == purchaseDate
            ? _value.purchaseDate
            : purchaseDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        daysSincePurchase: null == daysSincePurchase
            ? _value.daysSincePurchase
            : daysSincePurchase // ignore: cast_nullable_to_non_nullable
                  as int,
        riskLevel: null == riskLevel
            ? _value.riskLevel
            : riskLevel // ignore: cast_nullable_to_non_nullable
                  as String,
        alertMessage: null == alertMessage
            ? _value.alertMessage
            : alertMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WastePreventionAlertImpl implements _WastePreventionAlert {
  const _$WastePreventionAlertImpl({
    @JsonKey(name: 'product_name') required this.productName,
    @JsonKey(name: 'estimated_shelf_life_days')
    required this.estimatedShelfLifeDays,
    @JsonKey(name: 'purchase_date') required this.purchaseDate,
    @JsonKey(name: 'days_since_purchase') required this.daysSincePurchase,
    @JsonKey(name: 'risk_level') required this.riskLevel,
    @JsonKey(name: 'alert_message') required this.alertMessage,
  });

  factory _$WastePreventionAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$WastePreventionAlertImplFromJson(json);

  @override
  @JsonKey(name: 'product_name')
  final String productName;
  @override
  @JsonKey(name: 'estimated_shelf_life_days')
  final int estimatedShelfLifeDays;
  @override
  @JsonKey(name: 'purchase_date')
  final DateTime purchaseDate;
  @override
  @JsonKey(name: 'days_since_purchase')
  final int daysSincePurchase;
  @override
  @JsonKey(name: 'risk_level')
  final String riskLevel;
  @override
  @JsonKey(name: 'alert_message')
  final String alertMessage;

  @override
  String toString() {
    return 'WastePreventionAlert(productName: $productName, estimatedShelfLifeDays: $estimatedShelfLifeDays, purchaseDate: $purchaseDate, daysSincePurchase: $daysSincePurchase, riskLevel: $riskLevel, alertMessage: $alertMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WastePreventionAlertImpl &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.estimatedShelfLifeDays, estimatedShelfLifeDays) ||
                other.estimatedShelfLifeDays == estimatedShelfLifeDays) &&
            (identical(other.purchaseDate, purchaseDate) ||
                other.purchaseDate == purchaseDate) &&
            (identical(other.daysSincePurchase, daysSincePurchase) ||
                other.daysSincePurchase == daysSincePurchase) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            (identical(other.alertMessage, alertMessage) ||
                other.alertMessage == alertMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    productName,
    estimatedShelfLifeDays,
    purchaseDate,
    daysSincePurchase,
    riskLevel,
    alertMessage,
  );

  /// Create a copy of WastePreventionAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WastePreventionAlertImplCopyWith<_$WastePreventionAlertImpl>
  get copyWith =>
      __$$WastePreventionAlertImplCopyWithImpl<_$WastePreventionAlertImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WastePreventionAlertImplToJson(this);
  }
}

abstract class _WastePreventionAlert implements WastePreventionAlert {
  const factory _WastePreventionAlert({
    @JsonKey(name: 'product_name') required final String productName,
    @JsonKey(name: 'estimated_shelf_life_days')
    required final int estimatedShelfLifeDays,
    @JsonKey(name: 'purchase_date') required final DateTime purchaseDate,
    @JsonKey(name: 'days_since_purchase') required final int daysSincePurchase,
    @JsonKey(name: 'risk_level') required final String riskLevel,
    @JsonKey(name: 'alert_message') required final String alertMessage,
  }) = _$WastePreventionAlertImpl;

  factory _WastePreventionAlert.fromJson(Map<String, dynamic> json) =
      _$WastePreventionAlertImpl.fromJson;

  @override
  @JsonKey(name: 'product_name')
  String get productName;
  @override
  @JsonKey(name: 'estimated_shelf_life_days')
  int get estimatedShelfLifeDays;
  @override
  @JsonKey(name: 'purchase_date')
  DateTime get purchaseDate;
  @override
  @JsonKey(name: 'days_since_purchase')
  int get daysSincePurchase;
  @override
  @JsonKey(name: 'risk_level')
  String get riskLevel;
  @override
  @JsonKey(name: 'alert_message')
  String get alertMessage;

  /// Create a copy of WastePreventionAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WastePreventionAlertImplCopyWith<_$WastePreventionAlertImpl>
  get copyWith => throw _privateConstructorUsedError;
}

CategoryAnomalyAlert _$CategoryAnomalyAlertFromJson(Map<String, dynamic> json) {
  return _CategoryAnomalyAlert.fromJson(json);
}

/// @nodoc
mixin _$CategoryAnomalyAlert {
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_month_spending')
  double get currentMonthSpending => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_spending')
  double get averageSpending => throw _privateConstructorUsedError;
  @JsonKey(name: 'anomaly_percentage')
  double get anomalyPercentage => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  @JsonKey(name: 'alert_message')
  String get alertMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'suggested_action')
  String get suggestedAction => throw _privateConstructorUsedError;

  /// Serializes this CategoryAnomalyAlert to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryAnomalyAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryAnomalyAlertCopyWith<CategoryAnomalyAlert> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryAnomalyAlertCopyWith<$Res> {
  factory $CategoryAnomalyAlertCopyWith(
    CategoryAnomalyAlert value,
    $Res Function(CategoryAnomalyAlert) then,
  ) = _$CategoryAnomalyAlertCopyWithImpl<$Res, CategoryAnomalyAlert>;
  @useResult
  $Res call({
    String category,
    @JsonKey(name: 'current_month_spending') double currentMonthSpending,
    @JsonKey(name: 'average_spending') double averageSpending,
    @JsonKey(name: 'anomaly_percentage') double anomalyPercentage,
    String severity,
    @JsonKey(name: 'alert_message') String alertMessage,
    @JsonKey(name: 'suggested_action') String suggestedAction,
  });
}

/// @nodoc
class _$CategoryAnomalyAlertCopyWithImpl<
  $Res,
  $Val extends CategoryAnomalyAlert
>
    implements $CategoryAnomalyAlertCopyWith<$Res> {
  _$CategoryAnomalyAlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryAnomalyAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? currentMonthSpending = null,
    Object? averageSpending = null,
    Object? anomalyPercentage = null,
    Object? severity = null,
    Object? alertMessage = null,
    Object? suggestedAction = null,
  }) {
    return _then(
      _value.copyWith(
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            currentMonthSpending: null == currentMonthSpending
                ? _value.currentMonthSpending
                : currentMonthSpending // ignore: cast_nullable_to_non_nullable
                      as double,
            averageSpending: null == averageSpending
                ? _value.averageSpending
                : averageSpending // ignore: cast_nullable_to_non_nullable
                      as double,
            anomalyPercentage: null == anomalyPercentage
                ? _value.anomalyPercentage
                : anomalyPercentage // ignore: cast_nullable_to_non_nullable
                      as double,
            severity: null == severity
                ? _value.severity
                : severity // ignore: cast_nullable_to_non_nullable
                      as String,
            alertMessage: null == alertMessage
                ? _value.alertMessage
                : alertMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            suggestedAction: null == suggestedAction
                ? _value.suggestedAction
                : suggestedAction // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryAnomalyAlertImplCopyWith<$Res>
    implements $CategoryAnomalyAlertCopyWith<$Res> {
  factory _$$CategoryAnomalyAlertImplCopyWith(
    _$CategoryAnomalyAlertImpl value,
    $Res Function(_$CategoryAnomalyAlertImpl) then,
  ) = __$$CategoryAnomalyAlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String category,
    @JsonKey(name: 'current_month_spending') double currentMonthSpending,
    @JsonKey(name: 'average_spending') double averageSpending,
    @JsonKey(name: 'anomaly_percentage') double anomalyPercentage,
    String severity,
    @JsonKey(name: 'alert_message') String alertMessage,
    @JsonKey(name: 'suggested_action') String suggestedAction,
  });
}

/// @nodoc
class __$$CategoryAnomalyAlertImplCopyWithImpl<$Res>
    extends _$CategoryAnomalyAlertCopyWithImpl<$Res, _$CategoryAnomalyAlertImpl>
    implements _$$CategoryAnomalyAlertImplCopyWith<$Res> {
  __$$CategoryAnomalyAlertImplCopyWithImpl(
    _$CategoryAnomalyAlertImpl _value,
    $Res Function(_$CategoryAnomalyAlertImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryAnomalyAlert
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? currentMonthSpending = null,
    Object? averageSpending = null,
    Object? anomalyPercentage = null,
    Object? severity = null,
    Object? alertMessage = null,
    Object? suggestedAction = null,
  }) {
    return _then(
      _$CategoryAnomalyAlertImpl(
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        currentMonthSpending: null == currentMonthSpending
            ? _value.currentMonthSpending
            : currentMonthSpending // ignore: cast_nullable_to_non_nullable
                  as double,
        averageSpending: null == averageSpending
            ? _value.averageSpending
            : averageSpending // ignore: cast_nullable_to_non_nullable
                  as double,
        anomalyPercentage: null == anomalyPercentage
            ? _value.anomalyPercentage
            : anomalyPercentage // ignore: cast_nullable_to_non_nullable
                  as double,
        severity: null == severity
            ? _value.severity
            : severity // ignore: cast_nullable_to_non_nullable
                  as String,
        alertMessage: null == alertMessage
            ? _value.alertMessage
            : alertMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        suggestedAction: null == suggestedAction
            ? _value.suggestedAction
            : suggestedAction // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryAnomalyAlertImpl implements _CategoryAnomalyAlert {
  const _$CategoryAnomalyAlertImpl({
    required this.category,
    @JsonKey(name: 'current_month_spending') required this.currentMonthSpending,
    @JsonKey(name: 'average_spending') required this.averageSpending,
    @JsonKey(name: 'anomaly_percentage') required this.anomalyPercentage,
    required this.severity,
    @JsonKey(name: 'alert_message') required this.alertMessage,
    @JsonKey(name: 'suggested_action') required this.suggestedAction,
  });

  factory _$CategoryAnomalyAlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryAnomalyAlertImplFromJson(json);

  @override
  final String category;
  @override
  @JsonKey(name: 'current_month_spending')
  final double currentMonthSpending;
  @override
  @JsonKey(name: 'average_spending')
  final double averageSpending;
  @override
  @JsonKey(name: 'anomaly_percentage')
  final double anomalyPercentage;
  @override
  final String severity;
  @override
  @JsonKey(name: 'alert_message')
  final String alertMessage;
  @override
  @JsonKey(name: 'suggested_action')
  final String suggestedAction;

  @override
  String toString() {
    return 'CategoryAnomalyAlert(category: $category, currentMonthSpending: $currentMonthSpending, averageSpending: $averageSpending, anomalyPercentage: $anomalyPercentage, severity: $severity, alertMessage: $alertMessage, suggestedAction: $suggestedAction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryAnomalyAlertImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.currentMonthSpending, currentMonthSpending) ||
                other.currentMonthSpending == currentMonthSpending) &&
            (identical(other.averageSpending, averageSpending) ||
                other.averageSpending == averageSpending) &&
            (identical(other.anomalyPercentage, anomalyPercentage) ||
                other.anomalyPercentage == anomalyPercentage) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.alertMessage, alertMessage) ||
                other.alertMessage == alertMessage) &&
            (identical(other.suggestedAction, suggestedAction) ||
                other.suggestedAction == suggestedAction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    category,
    currentMonthSpending,
    averageSpending,
    anomalyPercentage,
    severity,
    alertMessage,
    suggestedAction,
  );

  /// Create a copy of CategoryAnomalyAlert
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryAnomalyAlertImplCopyWith<_$CategoryAnomalyAlertImpl>
  get copyWith =>
      __$$CategoryAnomalyAlertImplCopyWithImpl<_$CategoryAnomalyAlertImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryAnomalyAlertImplToJson(this);
  }
}

abstract class _CategoryAnomalyAlert implements CategoryAnomalyAlert {
  const factory _CategoryAnomalyAlert({
    required final String category,
    @JsonKey(name: 'current_month_spending')
    required final double currentMonthSpending,
    @JsonKey(name: 'average_spending') required final double averageSpending,
    @JsonKey(name: 'anomaly_percentage')
    required final double anomalyPercentage,
    required final String severity,
    @JsonKey(name: 'alert_message') required final String alertMessage,
    @JsonKey(name: 'suggested_action') required final String suggestedAction,
  }) = _$CategoryAnomalyAlertImpl;

  factory _CategoryAnomalyAlert.fromJson(Map<String, dynamic> json) =
      _$CategoryAnomalyAlertImpl.fromJson;

  @override
  String get category;
  @override
  @JsonKey(name: 'current_month_spending')
  double get currentMonthSpending;
  @override
  @JsonKey(name: 'average_spending')
  double get averageSpending;
  @override
  @JsonKey(name: 'anomaly_percentage')
  double get anomalyPercentage;
  @override
  String get severity;
  @override
  @JsonKey(name: 'alert_message')
  String get alertMessage;
  @override
  @JsonKey(name: 'suggested_action')
  String get suggestedAction;

  /// Create a copy of CategoryAnomalyAlert
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryAnomalyAlertImplCopyWith<_$CategoryAnomalyAlertImpl>
  get copyWith => throw _privateConstructorUsedError;
}

SpendingPatternInsight _$SpendingPatternInsightFromJson(
  Map<String, dynamic> json,
) {
  return _SpendingPatternInsight.fromJson(json);
}

/// @nodoc
mixin _$SpendingPatternInsight {
  @JsonKey(name: 'pattern_type')
  String get patternType => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'insight_message')
  String get insightMessage => throw _privateConstructorUsedError;
  String get recommendation => throw _privateConstructorUsedError;
  @JsonKey(name: 'potential_savings')
  double? get potentialSavings => throw _privateConstructorUsedError;

  /// Serializes this SpendingPatternInsight to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpendingPatternInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpendingPatternInsightCopyWith<SpendingPatternInsight> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpendingPatternInsightCopyWith<$Res> {
  factory $SpendingPatternInsightCopyWith(
    SpendingPatternInsight value,
    $Res Function(SpendingPatternInsight) then,
  ) = _$SpendingPatternInsightCopyWithImpl<$Res, SpendingPatternInsight>;
  @useResult
  $Res call({
    @JsonKey(name: 'pattern_type') String patternType,
    String category,
    @JsonKey(name: 'insight_message') String insightMessage,
    String recommendation,
    @JsonKey(name: 'potential_savings') double? potentialSavings,
  });
}

/// @nodoc
class _$SpendingPatternInsightCopyWithImpl<
  $Res,
  $Val extends SpendingPatternInsight
>
    implements $SpendingPatternInsightCopyWith<$Res> {
  _$SpendingPatternInsightCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpendingPatternInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patternType = null,
    Object? category = null,
    Object? insightMessage = null,
    Object? recommendation = null,
    Object? potentialSavings = freezed,
  }) {
    return _then(
      _value.copyWith(
            patternType: null == patternType
                ? _value.patternType
                : patternType // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            insightMessage: null == insightMessage
                ? _value.insightMessage
                : insightMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            recommendation: null == recommendation
                ? _value.recommendation
                : recommendation // ignore: cast_nullable_to_non_nullable
                      as String,
            potentialSavings: freezed == potentialSavings
                ? _value.potentialSavings
                : potentialSavings // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SpendingPatternInsightImplCopyWith<$Res>
    implements $SpendingPatternInsightCopyWith<$Res> {
  factory _$$SpendingPatternInsightImplCopyWith(
    _$SpendingPatternInsightImpl value,
    $Res Function(_$SpendingPatternInsightImpl) then,
  ) = __$$SpendingPatternInsightImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'pattern_type') String patternType,
    String category,
    @JsonKey(name: 'insight_message') String insightMessage,
    String recommendation,
    @JsonKey(name: 'potential_savings') double? potentialSavings,
  });
}

/// @nodoc
class __$$SpendingPatternInsightImplCopyWithImpl<$Res>
    extends
        _$SpendingPatternInsightCopyWithImpl<$Res, _$SpendingPatternInsightImpl>
    implements _$$SpendingPatternInsightImplCopyWith<$Res> {
  __$$SpendingPatternInsightImplCopyWithImpl(
    _$SpendingPatternInsightImpl _value,
    $Res Function(_$SpendingPatternInsightImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SpendingPatternInsight
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patternType = null,
    Object? category = null,
    Object? insightMessage = null,
    Object? recommendation = null,
    Object? potentialSavings = freezed,
  }) {
    return _then(
      _$SpendingPatternInsightImpl(
        patternType: null == patternType
            ? _value.patternType
            : patternType // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        insightMessage: null == insightMessage
            ? _value.insightMessage
            : insightMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        recommendation: null == recommendation
            ? _value.recommendation
            : recommendation // ignore: cast_nullable_to_non_nullable
                  as String,
        potentialSavings: freezed == potentialSavings
            ? _value.potentialSavings
            : potentialSavings // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SpendingPatternInsightImpl implements _SpendingPatternInsight {
  const _$SpendingPatternInsightImpl({
    @JsonKey(name: 'pattern_type') required this.patternType,
    required this.category,
    @JsonKey(name: 'insight_message') required this.insightMessage,
    required this.recommendation,
    @JsonKey(name: 'potential_savings') this.potentialSavings,
  });

  factory _$SpendingPatternInsightImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpendingPatternInsightImplFromJson(json);

  @override
  @JsonKey(name: 'pattern_type')
  final String patternType;
  @override
  final String category;
  @override
  @JsonKey(name: 'insight_message')
  final String insightMessage;
  @override
  final String recommendation;
  @override
  @JsonKey(name: 'potential_savings')
  final double? potentialSavings;

  @override
  String toString() {
    return 'SpendingPatternInsight(patternType: $patternType, category: $category, insightMessage: $insightMessage, recommendation: $recommendation, potentialSavings: $potentialSavings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpendingPatternInsightImpl &&
            (identical(other.patternType, patternType) ||
                other.patternType == patternType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.insightMessage, insightMessage) ||
                other.insightMessage == insightMessage) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.potentialSavings, potentialSavings) ||
                other.potentialSavings == potentialSavings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    patternType,
    category,
    insightMessage,
    recommendation,
    potentialSavings,
  );

  /// Create a copy of SpendingPatternInsight
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpendingPatternInsightImplCopyWith<_$SpendingPatternInsightImpl>
  get copyWith =>
      __$$SpendingPatternInsightImplCopyWithImpl<_$SpendingPatternInsightImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SpendingPatternInsightImplToJson(this);
  }
}

abstract class _SpendingPatternInsight implements SpendingPatternInsight {
  const factory _SpendingPatternInsight({
    @JsonKey(name: 'pattern_type') required final String patternType,
    required final String category,
    @JsonKey(name: 'insight_message') required final String insightMessage,
    required final String recommendation,
    @JsonKey(name: 'potential_savings') final double? potentialSavings,
  }) = _$SpendingPatternInsightImpl;

  factory _SpendingPatternInsight.fromJson(Map<String, dynamic> json) =
      _$SpendingPatternInsightImpl.fromJson;

  @override
  @JsonKey(name: 'pattern_type')
  String get patternType;
  @override
  String get category;
  @override
  @JsonKey(name: 'insight_message')
  String get insightMessage;
  @override
  String get recommendation;
  @override
  @JsonKey(name: 'potential_savings')
  double? get potentialSavings;

  /// Create a copy of SpendingPatternInsight
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpendingPatternInsightImplCopyWith<_$SpendingPatternInsightImpl>
  get copyWith => throw _privateConstructorUsedError;
}

RecommendationResponse _$RecommendationResponseFromJson(
  Map<String, dynamic> json,
) {
  return _RecommendationResponse.fromJson(json);
}

/// @nodoc
mixin _$RecommendationResponse {
  @JsonKey(name: 'waste_prevention_alerts')
  List<WastePreventionAlert> get wastePreventionAlerts =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'anomaly_alerts')
  List<CategoryAnomalyAlert> get anomalyAlerts =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'pattern_insights')
  List<SpendingPatternInsight> get patternInsights =>
      throw _privateConstructorUsedError;
  @JsonKey(name: 'generated_at')
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this RecommendationResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationResponseCopyWith<RecommendationResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationResponseCopyWith<$Res> {
  factory $RecommendationResponseCopyWith(
    RecommendationResponse value,
    $Res Function(RecommendationResponse) then,
  ) = _$RecommendationResponseCopyWithImpl<$Res, RecommendationResponse>;
  @useResult
  $Res call({
    @JsonKey(name: 'waste_prevention_alerts')
    List<WastePreventionAlert> wastePreventionAlerts,
    @JsonKey(name: 'anomaly_alerts') List<CategoryAnomalyAlert> anomalyAlerts,
    @JsonKey(name: 'pattern_insights')
    List<SpendingPatternInsight> patternInsights,
    @JsonKey(name: 'generated_at') DateTime generatedAt,
  });
}

/// @nodoc
class _$RecommendationResponseCopyWithImpl<
  $Res,
  $Val extends RecommendationResponse
>
    implements $RecommendationResponseCopyWith<$Res> {
  _$RecommendationResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wastePreventionAlerts = null,
    Object? anomalyAlerts = null,
    Object? patternInsights = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            wastePreventionAlerts: null == wastePreventionAlerts
                ? _value.wastePreventionAlerts
                : wastePreventionAlerts // ignore: cast_nullable_to_non_nullable
                      as List<WastePreventionAlert>,
            anomalyAlerts: null == anomalyAlerts
                ? _value.anomalyAlerts
                : anomalyAlerts // ignore: cast_nullable_to_non_nullable
                      as List<CategoryAnomalyAlert>,
            patternInsights: null == patternInsights
                ? _value.patternInsights
                : patternInsights // ignore: cast_nullable_to_non_nullable
                      as List<SpendingPatternInsight>,
            generatedAt: null == generatedAt
                ? _value.generatedAt
                : generatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecommendationResponseImplCopyWith<$Res>
    implements $RecommendationResponseCopyWith<$Res> {
  factory _$$RecommendationResponseImplCopyWith(
    _$RecommendationResponseImpl value,
    $Res Function(_$RecommendationResponseImpl) then,
  ) = __$$RecommendationResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'waste_prevention_alerts')
    List<WastePreventionAlert> wastePreventionAlerts,
    @JsonKey(name: 'anomaly_alerts') List<CategoryAnomalyAlert> anomalyAlerts,
    @JsonKey(name: 'pattern_insights')
    List<SpendingPatternInsight> patternInsights,
    @JsonKey(name: 'generated_at') DateTime generatedAt,
  });
}

/// @nodoc
class __$$RecommendationResponseImplCopyWithImpl<$Res>
    extends
        _$RecommendationResponseCopyWithImpl<$Res, _$RecommendationResponseImpl>
    implements _$$RecommendationResponseImplCopyWith<$Res> {
  __$$RecommendationResponseImplCopyWithImpl(
    _$RecommendationResponseImpl _value,
    $Res Function(_$RecommendationResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? wastePreventionAlerts = null,
    Object? anomalyAlerts = null,
    Object? patternInsights = null,
    Object? generatedAt = null,
  }) {
    return _then(
      _$RecommendationResponseImpl(
        wastePreventionAlerts: null == wastePreventionAlerts
            ? _value._wastePreventionAlerts
            : wastePreventionAlerts // ignore: cast_nullable_to_non_nullable
                  as List<WastePreventionAlert>,
        anomalyAlerts: null == anomalyAlerts
            ? _value._anomalyAlerts
            : anomalyAlerts // ignore: cast_nullable_to_non_nullable
                  as List<CategoryAnomalyAlert>,
        patternInsights: null == patternInsights
            ? _value._patternInsights
            : patternInsights // ignore: cast_nullable_to_non_nullable
                  as List<SpendingPatternInsight>,
        generatedAt: null == generatedAt
            ? _value.generatedAt
            : generatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecommendationResponseImpl implements _RecommendationResponse {
  const _$RecommendationResponseImpl({
    @JsonKey(name: 'waste_prevention_alerts')
    final List<WastePreventionAlert> wastePreventionAlerts = const [],
    @JsonKey(name: 'anomaly_alerts')
    final List<CategoryAnomalyAlert> anomalyAlerts = const [],
    @JsonKey(name: 'pattern_insights')
    final List<SpendingPatternInsight> patternInsights = const [],
    @JsonKey(name: 'generated_at') required this.generatedAt,
  }) : _wastePreventionAlerts = wastePreventionAlerts,
       _anomalyAlerts = anomalyAlerts,
       _patternInsights = patternInsights;

  factory _$RecommendationResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecommendationResponseImplFromJson(json);

  final List<WastePreventionAlert> _wastePreventionAlerts;
  @override
  @JsonKey(name: 'waste_prevention_alerts')
  List<WastePreventionAlert> get wastePreventionAlerts {
    if (_wastePreventionAlerts is EqualUnmodifiableListView)
      return _wastePreventionAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wastePreventionAlerts);
  }

  final List<CategoryAnomalyAlert> _anomalyAlerts;
  @override
  @JsonKey(name: 'anomaly_alerts')
  List<CategoryAnomalyAlert> get anomalyAlerts {
    if (_anomalyAlerts is EqualUnmodifiableListView) return _anomalyAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_anomalyAlerts);
  }

  final List<SpendingPatternInsight> _patternInsights;
  @override
  @JsonKey(name: 'pattern_insights')
  List<SpendingPatternInsight> get patternInsights {
    if (_patternInsights is EqualUnmodifiableListView) return _patternInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_patternInsights);
  }

  @override
  @JsonKey(name: 'generated_at')
  final DateTime generatedAt;

  @override
  String toString() {
    return 'RecommendationResponse(wastePreventionAlerts: $wastePreventionAlerts, anomalyAlerts: $anomalyAlerts, patternInsights: $patternInsights, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationResponseImpl &&
            const DeepCollectionEquality().equals(
              other._wastePreventionAlerts,
              _wastePreventionAlerts,
            ) &&
            const DeepCollectionEquality().equals(
              other._anomalyAlerts,
              _anomalyAlerts,
            ) &&
            const DeepCollectionEquality().equals(
              other._patternInsights,
              _patternInsights,
            ) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_wastePreventionAlerts),
    const DeepCollectionEquality().hash(_anomalyAlerts),
    const DeepCollectionEquality().hash(_patternInsights),
    generatedAt,
  );

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationResponseImplCopyWith<_$RecommendationResponseImpl>
  get copyWith =>
      __$$RecommendationResponseImplCopyWithImpl<_$RecommendationResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecommendationResponseImplToJson(this);
  }
}

abstract class _RecommendationResponse implements RecommendationResponse {
  const factory _RecommendationResponse({
    @JsonKey(name: 'waste_prevention_alerts')
    final List<WastePreventionAlert> wastePreventionAlerts,
    @JsonKey(name: 'anomaly_alerts')
    final List<CategoryAnomalyAlert> anomalyAlerts,
    @JsonKey(name: 'pattern_insights')
    final List<SpendingPatternInsight> patternInsights,
    @JsonKey(name: 'generated_at') required final DateTime generatedAt,
  }) = _$RecommendationResponseImpl;

  factory _RecommendationResponse.fromJson(Map<String, dynamic> json) =
      _$RecommendationResponseImpl.fromJson;

  @override
  @JsonKey(name: 'waste_prevention_alerts')
  List<WastePreventionAlert> get wastePreventionAlerts;
  @override
  @JsonKey(name: 'anomaly_alerts')
  List<CategoryAnomalyAlert> get anomalyAlerts;
  @override
  @JsonKey(name: 'pattern_insights')
  List<SpendingPatternInsight> get patternInsights;
  @override
  @JsonKey(name: 'generated_at')
  DateTime get generatedAt;

  /// Create a copy of RecommendationResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationResponseImplCopyWith<_$RecommendationResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecommendationsState {
  RecommendationCategory get selectedCategory =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  RecommendationResponse? get recommendations =>
      throw _privateConstructorUsedError;
  bool get isLoadingWastePrevention => throw _privateConstructorUsedError;
  bool get isLoadingAnomalies => throw _privateConstructorUsedError;
  bool get isLoadingPatterns => throw _privateConstructorUsedError;
  List<WastePreventionAlert> get wastePreventionAlerts =>
      throw _privateConstructorUsedError;
  List<CategoryAnomalyAlert> get anomalyAlerts =>
      throw _privateConstructorUsedError;
  List<SpendingPatternInsight> get patternInsights =>
      throw _privateConstructorUsedError; // Cache time fields for performance optimization
  DateTime? get wastePreventionCacheTime => throw _privateConstructorUsedError;
  DateTime? get anomalyCacheTime => throw _privateConstructorUsedError;
  DateTime? get patternCacheTime => throw _privateConstructorUsedError;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecommendationsStateCopyWith<RecommendationsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecommendationsStateCopyWith<$Res> {
  factory $RecommendationsStateCopyWith(
    RecommendationsState value,
    $Res Function(RecommendationsState) then,
  ) = _$RecommendationsStateCopyWithImpl<$Res, RecommendationsState>;
  @useResult
  $Res call({
    RecommendationCategory selectedCategory,
    bool isLoading,
    bool hasError,
    String? errorMessage,
    RecommendationResponse? recommendations,
    bool isLoadingWastePrevention,
    bool isLoadingAnomalies,
    bool isLoadingPatterns,
    List<WastePreventionAlert> wastePreventionAlerts,
    List<CategoryAnomalyAlert> anomalyAlerts,
    List<SpendingPatternInsight> patternInsights,
    DateTime? wastePreventionCacheTime,
    DateTime? anomalyCacheTime,
    DateTime? patternCacheTime,
  });

  $RecommendationResponseCopyWith<$Res>? get recommendations;
}

/// @nodoc
class _$RecommendationsStateCopyWithImpl<
  $Res,
  $Val extends RecommendationsState
>
    implements $RecommendationsStateCopyWith<$Res> {
  _$RecommendationsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedCategory = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? recommendations = freezed,
    Object? isLoadingWastePrevention = null,
    Object? isLoadingAnomalies = null,
    Object? isLoadingPatterns = null,
    Object? wastePreventionAlerts = null,
    Object? anomalyAlerts = null,
    Object? patternInsights = null,
    Object? wastePreventionCacheTime = freezed,
    Object? anomalyCacheTime = freezed,
    Object? patternCacheTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            selectedCategory: null == selectedCategory
                ? _value.selectedCategory
                : selectedCategory // ignore: cast_nullable_to_non_nullable
                      as RecommendationCategory,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            recommendations: freezed == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as RecommendationResponse?,
            isLoadingWastePrevention: null == isLoadingWastePrevention
                ? _value.isLoadingWastePrevention
                : isLoadingWastePrevention // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingAnomalies: null == isLoadingAnomalies
                ? _value.isLoadingAnomalies
                : isLoadingAnomalies // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingPatterns: null == isLoadingPatterns
                ? _value.isLoadingPatterns
                : isLoadingPatterns // ignore: cast_nullable_to_non_nullable
                      as bool,
            wastePreventionAlerts: null == wastePreventionAlerts
                ? _value.wastePreventionAlerts
                : wastePreventionAlerts // ignore: cast_nullable_to_non_nullable
                      as List<WastePreventionAlert>,
            anomalyAlerts: null == anomalyAlerts
                ? _value.anomalyAlerts
                : anomalyAlerts // ignore: cast_nullable_to_non_nullable
                      as List<CategoryAnomalyAlert>,
            patternInsights: null == patternInsights
                ? _value.patternInsights
                : patternInsights // ignore: cast_nullable_to_non_nullable
                      as List<SpendingPatternInsight>,
            wastePreventionCacheTime: freezed == wastePreventionCacheTime
                ? _value.wastePreventionCacheTime
                : wastePreventionCacheTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            anomalyCacheTime: freezed == anomalyCacheTime
                ? _value.anomalyCacheTime
                : anomalyCacheTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            patternCacheTime: freezed == patternCacheTime
                ? _value.patternCacheTime
                : patternCacheTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RecommendationResponseCopyWith<$Res>? get recommendations {
    if (_value.recommendations == null) {
      return null;
    }

    return $RecommendationResponseCopyWith<$Res>(_value.recommendations!, (
      value,
    ) {
      return _then(_value.copyWith(recommendations: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RecommendationsStateImplCopyWith<$Res>
    implements $RecommendationsStateCopyWith<$Res> {
  factory _$$RecommendationsStateImplCopyWith(
    _$RecommendationsStateImpl value,
    $Res Function(_$RecommendationsStateImpl) then,
  ) = __$$RecommendationsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RecommendationCategory selectedCategory,
    bool isLoading,
    bool hasError,
    String? errorMessage,
    RecommendationResponse? recommendations,
    bool isLoadingWastePrevention,
    bool isLoadingAnomalies,
    bool isLoadingPatterns,
    List<WastePreventionAlert> wastePreventionAlerts,
    List<CategoryAnomalyAlert> anomalyAlerts,
    List<SpendingPatternInsight> patternInsights,
    DateTime? wastePreventionCacheTime,
    DateTime? anomalyCacheTime,
    DateTime? patternCacheTime,
  });

  @override
  $RecommendationResponseCopyWith<$Res>? get recommendations;
}

/// @nodoc
class __$$RecommendationsStateImplCopyWithImpl<$Res>
    extends _$RecommendationsStateCopyWithImpl<$Res, _$RecommendationsStateImpl>
    implements _$$RecommendationsStateImplCopyWith<$Res> {
  __$$RecommendationsStateImplCopyWithImpl(
    _$RecommendationsStateImpl _value,
    $Res Function(_$RecommendationsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedCategory = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? recommendations = freezed,
    Object? isLoadingWastePrevention = null,
    Object? isLoadingAnomalies = null,
    Object? isLoadingPatterns = null,
    Object? wastePreventionAlerts = null,
    Object? anomalyAlerts = null,
    Object? patternInsights = null,
    Object? wastePreventionCacheTime = freezed,
    Object? anomalyCacheTime = freezed,
    Object? patternCacheTime = freezed,
  }) {
    return _then(
      _$RecommendationsStateImpl(
        selectedCategory: null == selectedCategory
            ? _value.selectedCategory
            : selectedCategory // ignore: cast_nullable_to_non_nullable
                  as RecommendationCategory,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        recommendations: freezed == recommendations
            ? _value.recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as RecommendationResponse?,
        isLoadingWastePrevention: null == isLoadingWastePrevention
            ? _value.isLoadingWastePrevention
            : isLoadingWastePrevention // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingAnomalies: null == isLoadingAnomalies
            ? _value.isLoadingAnomalies
            : isLoadingAnomalies // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingPatterns: null == isLoadingPatterns
            ? _value.isLoadingPatterns
            : isLoadingPatterns // ignore: cast_nullable_to_non_nullable
                  as bool,
        wastePreventionAlerts: null == wastePreventionAlerts
            ? _value._wastePreventionAlerts
            : wastePreventionAlerts // ignore: cast_nullable_to_non_nullable
                  as List<WastePreventionAlert>,
        anomalyAlerts: null == anomalyAlerts
            ? _value._anomalyAlerts
            : anomalyAlerts // ignore: cast_nullable_to_non_nullable
                  as List<CategoryAnomalyAlert>,
        patternInsights: null == patternInsights
            ? _value._patternInsights
            : patternInsights // ignore: cast_nullable_to_non_nullable
                  as List<SpendingPatternInsight>,
        wastePreventionCacheTime: freezed == wastePreventionCacheTime
            ? _value.wastePreventionCacheTime
            : wastePreventionCacheTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        anomalyCacheTime: freezed == anomalyCacheTime
            ? _value.anomalyCacheTime
            : anomalyCacheTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        patternCacheTime: freezed == patternCacheTime
            ? _value.patternCacheTime
            : patternCacheTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$RecommendationsStateImpl implements _RecommendationsState {
  const _$RecommendationsStateImpl({
    this.selectedCategory = RecommendationCategory.waste,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.recommendations,
    this.isLoadingWastePrevention = false,
    this.isLoadingAnomalies = false,
    this.isLoadingPatterns = false,
    final List<WastePreventionAlert> wastePreventionAlerts = const [],
    final List<CategoryAnomalyAlert> anomalyAlerts = const [],
    final List<SpendingPatternInsight> patternInsights = const [],
    this.wastePreventionCacheTime,
    this.anomalyCacheTime,
    this.patternCacheTime,
  }) : _wastePreventionAlerts = wastePreventionAlerts,
       _anomalyAlerts = anomalyAlerts,
       _patternInsights = patternInsights;

  @override
  @JsonKey()
  final RecommendationCategory selectedCategory;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;
  @override
  final RecommendationResponse? recommendations;
  @override
  @JsonKey()
  final bool isLoadingWastePrevention;
  @override
  @JsonKey()
  final bool isLoadingAnomalies;
  @override
  @JsonKey()
  final bool isLoadingPatterns;
  final List<WastePreventionAlert> _wastePreventionAlerts;
  @override
  @JsonKey()
  List<WastePreventionAlert> get wastePreventionAlerts {
    if (_wastePreventionAlerts is EqualUnmodifiableListView)
      return _wastePreventionAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_wastePreventionAlerts);
  }

  final List<CategoryAnomalyAlert> _anomalyAlerts;
  @override
  @JsonKey()
  List<CategoryAnomalyAlert> get anomalyAlerts {
    if (_anomalyAlerts is EqualUnmodifiableListView) return _anomalyAlerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_anomalyAlerts);
  }

  final List<SpendingPatternInsight> _patternInsights;
  @override
  @JsonKey()
  List<SpendingPatternInsight> get patternInsights {
    if (_patternInsights is EqualUnmodifiableListView) return _patternInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_patternInsights);
  }

  // Cache time fields for performance optimization
  @override
  final DateTime? wastePreventionCacheTime;
  @override
  final DateTime? anomalyCacheTime;
  @override
  final DateTime? patternCacheTime;

  @override
  String toString() {
    return 'RecommendationsState(selectedCategory: $selectedCategory, isLoading: $isLoading, hasError: $hasError, errorMessage: $errorMessage, recommendations: $recommendations, isLoadingWastePrevention: $isLoadingWastePrevention, isLoadingAnomalies: $isLoadingAnomalies, isLoadingPatterns: $isLoadingPatterns, wastePreventionAlerts: $wastePreventionAlerts, anomalyAlerts: $anomalyAlerts, patternInsights: $patternInsights, wastePreventionCacheTime: $wastePreventionCacheTime, anomalyCacheTime: $anomalyCacheTime, patternCacheTime: $patternCacheTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecommendationsStateImpl &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.recommendations, recommendations) ||
                other.recommendations == recommendations) &&
            (identical(
                  other.isLoadingWastePrevention,
                  isLoadingWastePrevention,
                ) ||
                other.isLoadingWastePrevention == isLoadingWastePrevention) &&
            (identical(other.isLoadingAnomalies, isLoadingAnomalies) ||
                other.isLoadingAnomalies == isLoadingAnomalies) &&
            (identical(other.isLoadingPatterns, isLoadingPatterns) ||
                other.isLoadingPatterns == isLoadingPatterns) &&
            const DeepCollectionEquality().equals(
              other._wastePreventionAlerts,
              _wastePreventionAlerts,
            ) &&
            const DeepCollectionEquality().equals(
              other._anomalyAlerts,
              _anomalyAlerts,
            ) &&
            const DeepCollectionEquality().equals(
              other._patternInsights,
              _patternInsights,
            ) &&
            (identical(
                  other.wastePreventionCacheTime,
                  wastePreventionCacheTime,
                ) ||
                other.wastePreventionCacheTime == wastePreventionCacheTime) &&
            (identical(other.anomalyCacheTime, anomalyCacheTime) ||
                other.anomalyCacheTime == anomalyCacheTime) &&
            (identical(other.patternCacheTime, patternCacheTime) ||
                other.patternCacheTime == patternCacheTime));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    selectedCategory,
    isLoading,
    hasError,
    errorMessage,
    recommendations,
    isLoadingWastePrevention,
    isLoadingAnomalies,
    isLoadingPatterns,
    const DeepCollectionEquality().hash(_wastePreventionAlerts),
    const DeepCollectionEquality().hash(_anomalyAlerts),
    const DeepCollectionEquality().hash(_patternInsights),
    wastePreventionCacheTime,
    anomalyCacheTime,
    patternCacheTime,
  );

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecommendationsStateImplCopyWith<_$RecommendationsStateImpl>
  get copyWith =>
      __$$RecommendationsStateImplCopyWithImpl<_$RecommendationsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _RecommendationsState implements RecommendationsState {
  const factory _RecommendationsState({
    final RecommendationCategory selectedCategory,
    final bool isLoading,
    final bool hasError,
    final String? errorMessage,
    final RecommendationResponse? recommendations,
    final bool isLoadingWastePrevention,
    final bool isLoadingAnomalies,
    final bool isLoadingPatterns,
    final List<WastePreventionAlert> wastePreventionAlerts,
    final List<CategoryAnomalyAlert> anomalyAlerts,
    final List<SpendingPatternInsight> patternInsights,
    final DateTime? wastePreventionCacheTime,
    final DateTime? anomalyCacheTime,
    final DateTime? patternCacheTime,
  }) = _$RecommendationsStateImpl;

  @override
  RecommendationCategory get selectedCategory;
  @override
  bool get isLoading;
  @override
  bool get hasError;
  @override
  String? get errorMessage;
  @override
  RecommendationResponse? get recommendations;
  @override
  bool get isLoadingWastePrevention;
  @override
  bool get isLoadingAnomalies;
  @override
  bool get isLoadingPatterns;
  @override
  List<WastePreventionAlert> get wastePreventionAlerts;
  @override
  List<CategoryAnomalyAlert> get anomalyAlerts;
  @override
  List<SpendingPatternInsight> get patternInsights; // Cache time fields for performance optimization
  @override
  DateTime? get wastePreventionCacheTime;
  @override
  DateTime? get anomalyCacheTime;
  @override
  DateTime? get patternCacheTime;

  /// Create a copy of RecommendationsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecommendationsStateImplCopyWith<_$RecommendationsStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
