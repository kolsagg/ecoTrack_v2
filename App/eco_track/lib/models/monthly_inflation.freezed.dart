// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_inflation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MonthlyInflation _$MonthlyInflationFromJson(Map<String, dynamic> json) {
  return _MonthlyInflation.fromJson(json);
}

/// @nodoc
mixin _$MonthlyInflation {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'product_name')
  String get productName => throw _privateConstructorUsedError;
  int get year => throw _privateConstructorUsedError;
  int get month => throw _privateConstructorUsedError;
  @JsonKey(name: 'average_price')
  double get averagePrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'purchase_count')
  int get purchaseCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'previous_month_price')
  double? get previousMonthPrice => throw _privateConstructorUsedError;
  @JsonKey(name: 'inflation_percentage')
  double? get inflationPercentage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_updated_at')
  String get lastUpdatedAt => throw _privateConstructorUsedError;

  /// Serializes this MonthlyInflation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyInflation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyInflationCopyWith<MonthlyInflation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyInflationCopyWith<$Res> {
  factory $MonthlyInflationCopyWith(
    MonthlyInflation value,
    $Res Function(MonthlyInflation) then,
  ) = _$MonthlyInflationCopyWithImpl<$Res, MonthlyInflation>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_name') String productName,
    int year,
    int month,
    @JsonKey(name: 'average_price') double averagePrice,
    @JsonKey(name: 'purchase_count') int purchaseCount,
    @JsonKey(name: 'previous_month_price') double? previousMonthPrice,
    @JsonKey(name: 'inflation_percentage') double? inflationPercentage,
    @JsonKey(name: 'last_updated_at') String lastUpdatedAt,
  });
}

/// @nodoc
class _$MonthlyInflationCopyWithImpl<$Res, $Val extends MonthlyInflation>
    implements $MonthlyInflationCopyWith<$Res> {
  _$MonthlyInflationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyInflation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productName = null,
    Object? year = null,
    Object? month = null,
    Object? averagePrice = null,
    Object? purchaseCount = null,
    Object? previousMonthPrice = freezed,
    Object? inflationPercentage = freezed,
    Object? lastUpdatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            productName: null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                      as String,
            year: null == year
                ? _value.year
                : year // ignore: cast_nullable_to_non_nullable
                      as int,
            month: null == month
                ? _value.month
                : month // ignore: cast_nullable_to_non_nullable
                      as int,
            averagePrice: null == averagePrice
                ? _value.averagePrice
                : averagePrice // ignore: cast_nullable_to_non_nullable
                      as double,
            purchaseCount: null == purchaseCount
                ? _value.purchaseCount
                : purchaseCount // ignore: cast_nullable_to_non_nullable
                      as int,
            previousMonthPrice: freezed == previousMonthPrice
                ? _value.previousMonthPrice
                : previousMonthPrice // ignore: cast_nullable_to_non_nullable
                      as double?,
            inflationPercentage: freezed == inflationPercentage
                ? _value.inflationPercentage
                : inflationPercentage // ignore: cast_nullable_to_non_nullable
                      as double?,
            lastUpdatedAt: null == lastUpdatedAt
                ? _value.lastUpdatedAt
                : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyInflationImplCopyWith<$Res>
    implements $MonthlyInflationCopyWith<$Res> {
  factory _$$MonthlyInflationImplCopyWith(
    _$MonthlyInflationImpl value,
    $Res Function(_$MonthlyInflationImpl) then,
  ) = __$$MonthlyInflationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'product_name') String productName,
    int year,
    int month,
    @JsonKey(name: 'average_price') double averagePrice,
    @JsonKey(name: 'purchase_count') int purchaseCount,
    @JsonKey(name: 'previous_month_price') double? previousMonthPrice,
    @JsonKey(name: 'inflation_percentage') double? inflationPercentage,
    @JsonKey(name: 'last_updated_at') String lastUpdatedAt,
  });
}

/// @nodoc
class __$$MonthlyInflationImplCopyWithImpl<$Res>
    extends _$MonthlyInflationCopyWithImpl<$Res, _$MonthlyInflationImpl>
    implements _$$MonthlyInflationImplCopyWith<$Res> {
  __$$MonthlyInflationImplCopyWithImpl(
    _$MonthlyInflationImpl _value,
    $Res Function(_$MonthlyInflationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyInflation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? productName = null,
    Object? year = null,
    Object? month = null,
    Object? averagePrice = null,
    Object? purchaseCount = null,
    Object? previousMonthPrice = freezed,
    Object? inflationPercentage = freezed,
    Object? lastUpdatedAt = null,
  }) {
    return _then(
      _$MonthlyInflationImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        productName: null == productName
            ? _value.productName
            : productName // ignore: cast_nullable_to_non_nullable
                  as String,
        year: null == year
            ? _value.year
            : year // ignore: cast_nullable_to_non_nullable
                  as int,
        month: null == month
            ? _value.month
            : month // ignore: cast_nullable_to_non_nullable
                  as int,
        averagePrice: null == averagePrice
            ? _value.averagePrice
            : averagePrice // ignore: cast_nullable_to_non_nullable
                  as double,
        purchaseCount: null == purchaseCount
            ? _value.purchaseCount
            : purchaseCount // ignore: cast_nullable_to_non_nullable
                  as int,
        previousMonthPrice: freezed == previousMonthPrice
            ? _value.previousMonthPrice
            : previousMonthPrice // ignore: cast_nullable_to_non_nullable
                  as double?,
        inflationPercentage: freezed == inflationPercentage
            ? _value.inflationPercentage
            : inflationPercentage // ignore: cast_nullable_to_non_nullable
                  as double?,
        lastUpdatedAt: null == lastUpdatedAt
            ? _value.lastUpdatedAt
            : lastUpdatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MonthlyInflationImpl implements _MonthlyInflation {
  const _$MonthlyInflationImpl({
    required this.id,
    @JsonKey(name: 'product_name') required this.productName,
    required this.year,
    required this.month,
    @JsonKey(name: 'average_price') required this.averagePrice,
    @JsonKey(name: 'purchase_count') required this.purchaseCount,
    @JsonKey(name: 'previous_month_price') this.previousMonthPrice,
    @JsonKey(name: 'inflation_percentage') this.inflationPercentage,
    @JsonKey(name: 'last_updated_at') required this.lastUpdatedAt,
  });

  factory _$MonthlyInflationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MonthlyInflationImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'product_name')
  final String productName;
  @override
  final int year;
  @override
  final int month;
  @override
  @JsonKey(name: 'average_price')
  final double averagePrice;
  @override
  @JsonKey(name: 'purchase_count')
  final int purchaseCount;
  @override
  @JsonKey(name: 'previous_month_price')
  final double? previousMonthPrice;
  @override
  @JsonKey(name: 'inflation_percentage')
  final double? inflationPercentage;
  @override
  @JsonKey(name: 'last_updated_at')
  final String lastUpdatedAt;

  @override
  String toString() {
    return 'MonthlyInflation(id: $id, productName: $productName, year: $year, month: $month, averagePrice: $averagePrice, purchaseCount: $purchaseCount, previousMonthPrice: $previousMonthPrice, inflationPercentage: $inflationPercentage, lastUpdatedAt: $lastUpdatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyInflationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.year, year) || other.year == year) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.averagePrice, averagePrice) ||
                other.averagePrice == averagePrice) &&
            (identical(other.purchaseCount, purchaseCount) ||
                other.purchaseCount == purchaseCount) &&
            (identical(other.previousMonthPrice, previousMonthPrice) ||
                other.previousMonthPrice == previousMonthPrice) &&
            (identical(other.inflationPercentage, inflationPercentage) ||
                other.inflationPercentage == inflationPercentage) &&
            (identical(other.lastUpdatedAt, lastUpdatedAt) ||
                other.lastUpdatedAt == lastUpdatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    productName,
    year,
    month,
    averagePrice,
    purchaseCount,
    previousMonthPrice,
    inflationPercentage,
    lastUpdatedAt,
  );

  /// Create a copy of MonthlyInflation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyInflationImplCopyWith<_$MonthlyInflationImpl> get copyWith =>
      __$$MonthlyInflationImplCopyWithImpl<_$MonthlyInflationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MonthlyInflationImplToJson(this);
  }
}

abstract class _MonthlyInflation implements MonthlyInflation {
  const factory _MonthlyInflation({
    required final String id,
    @JsonKey(name: 'product_name') required final String productName,
    required final int year,
    required final int month,
    @JsonKey(name: 'average_price') required final double averagePrice,
    @JsonKey(name: 'purchase_count') required final int purchaseCount,
    @JsonKey(name: 'previous_month_price') final double? previousMonthPrice,
    @JsonKey(name: 'inflation_percentage') final double? inflationPercentage,
    @JsonKey(name: 'last_updated_at') required final String lastUpdatedAt,
  }) = _$MonthlyInflationImpl;

  factory _MonthlyInflation.fromJson(Map<String, dynamic> json) =
      _$MonthlyInflationImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'product_name')
  String get productName;
  @override
  int get year;
  @override
  int get month;
  @override
  @JsonKey(name: 'average_price')
  double get averagePrice;
  @override
  @JsonKey(name: 'purchase_count')
  int get purchaseCount;
  @override
  @JsonKey(name: 'previous_month_price')
  double? get previousMonthPrice;
  @override
  @JsonKey(name: 'inflation_percentage')
  double? get inflationPercentage;
  @override
  @JsonKey(name: 'last_updated_at')
  String get lastUpdatedAt;

  /// Create a copy of MonthlyInflation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyInflationImplCopyWith<_$MonthlyInflationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MonthlyInflationState {
  List<MonthlyInflation> get data => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int? get selectedYear => throw _privateConstructorUsedError;
  int? get selectedMonth => throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  String get sortBy => throw _privateConstructorUsedError;
  String get order => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyInflationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyInflationStateCopyWith<MonthlyInflationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyInflationStateCopyWith<$Res> {
  factory $MonthlyInflationStateCopyWith(
    MonthlyInflationState value,
    $Res Function(MonthlyInflationState) then,
  ) = _$MonthlyInflationStateCopyWithImpl<$Res, MonthlyInflationState>;
  @useResult
  $Res call({
    List<MonthlyInflation> data,
    bool isLoading,
    String? error,
    int? selectedYear,
    int? selectedMonth,
    String searchQuery,
    String sortBy,
    String order,
  });
}

/// @nodoc
class _$MonthlyInflationStateCopyWithImpl<
  $Res,
  $Val extends MonthlyInflationState
>
    implements $MonthlyInflationStateCopyWith<$Res> {
  _$MonthlyInflationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyInflationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedYear = freezed,
    Object? selectedMonth = freezed,
    Object? searchQuery = null,
    Object? sortBy = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as List<MonthlyInflation>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedYear: freezed == selectedYear
                ? _value.selectedYear
                : selectedYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            selectedMonth: freezed == selectedMonth
                ? _value.selectedMonth
                : selectedMonth // ignore: cast_nullable_to_non_nullable
                      as int?,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as String,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyInflationStateImplCopyWith<$Res>
    implements $MonthlyInflationStateCopyWith<$Res> {
  factory _$$MonthlyInflationStateImplCopyWith(
    _$MonthlyInflationStateImpl value,
    $Res Function(_$MonthlyInflationStateImpl) then,
  ) = __$$MonthlyInflationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<MonthlyInflation> data,
    bool isLoading,
    String? error,
    int? selectedYear,
    int? selectedMonth,
    String searchQuery,
    String sortBy,
    String order,
  });
}

/// @nodoc
class __$$MonthlyInflationStateImplCopyWithImpl<$Res>
    extends
        _$MonthlyInflationStateCopyWithImpl<$Res, _$MonthlyInflationStateImpl>
    implements _$$MonthlyInflationStateImplCopyWith<$Res> {
  __$$MonthlyInflationStateImplCopyWithImpl(
    _$MonthlyInflationStateImpl _value,
    $Res Function(_$MonthlyInflationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyInflationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? selectedYear = freezed,
    Object? selectedMonth = freezed,
    Object? searchQuery = null,
    Object? sortBy = null,
    Object? order = null,
  }) {
    return _then(
      _$MonthlyInflationStateImpl(
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as List<MonthlyInflation>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedYear: freezed == selectedYear
            ? _value.selectedYear
            : selectedYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        selectedMonth: freezed == selectedMonth
            ? _value.selectedMonth
            : selectedMonth // ignore: cast_nullable_to_non_nullable
                  as int?,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as String,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$MonthlyInflationStateImpl implements _MonthlyInflationState {
  const _$MonthlyInflationStateImpl({
    final List<MonthlyInflation> data = const [],
    this.isLoading = false,
    this.error = null,
    this.selectedYear = null,
    this.selectedMonth = null,
    this.searchQuery = '',
    this.sortBy = 'inflation_percentage',
    this.order = 'desc',
  }) : _data = data;

  final List<MonthlyInflation> _data;
  @override
  @JsonKey()
  List<MonthlyInflation> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;
  @override
  @JsonKey()
  final int? selectedYear;
  @override
  @JsonKey()
  final int? selectedMonth;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String sortBy;
  @override
  @JsonKey()
  final String order;

  @override
  String toString() {
    return 'MonthlyInflationState(data: $data, isLoading: $isLoading, error: $error, selectedYear: $selectedYear, selectedMonth: $selectedMonth, searchQuery: $searchQuery, sortBy: $sortBy, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyInflationStateImpl &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.selectedYear, selectedYear) ||
                other.selectedYear == selectedYear) &&
            (identical(other.selectedMonth, selectedMonth) ||
                other.selectedMonth == selectedMonth) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.order, order) || other.order == order));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_data),
    isLoading,
    error,
    selectedYear,
    selectedMonth,
    searchQuery,
    sortBy,
    order,
  );

  /// Create a copy of MonthlyInflationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyInflationStateImplCopyWith<_$MonthlyInflationStateImpl>
  get copyWith =>
      __$$MonthlyInflationStateImplCopyWithImpl<_$MonthlyInflationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _MonthlyInflationState implements MonthlyInflationState {
  const factory _MonthlyInflationState({
    final List<MonthlyInflation> data,
    final bool isLoading,
    final String? error,
    final int? selectedYear,
    final int? selectedMonth,
    final String searchQuery,
    final String sortBy,
    final String order,
  }) = _$MonthlyInflationStateImpl;

  @override
  List<MonthlyInflation> get data;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  int? get selectedYear;
  @override
  int? get selectedMonth;
  @override
  String get searchQuery;
  @override
  String get sortBy;
  @override
  String get order;

  /// Create a copy of MonthlyInflationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyInflationStateImplCopyWith<_$MonthlyInflationStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}
