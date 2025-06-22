import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'budget_models.g.dart';

// User Budget Create Request
@JsonSerializable()
class UserBudgetCreateRequest extends Equatable {
  @JsonKey(name: 'total_monthly_budget')
  final double totalMonthlyBudget;
  final String currency;
  @JsonKey(name: 'auto_allocate')
  final bool autoAllocate;
  final int? year;
  final int? month;

  const UserBudgetCreateRequest({
    required this.totalMonthlyBudget,
    this.currency = 'TRY',
    this.autoAllocate = true,
    this.year,
    this.month,
  });

  factory UserBudgetCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserBudgetCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserBudgetCreateRequestToJson(this);

  @override
  List<Object?> get props => [
    totalMonthlyBudget,
    currency,
    autoAllocate,
    year,
    month,
  ];
}

// User Budget Update Request
@JsonSerializable()
class UserBudgetUpdateRequest extends Equatable {
  @JsonKey(name: 'total_monthly_budget')
  final double? totalMonthlyBudget;
  final String? currency;
  @JsonKey(name: 'auto_allocate')
  final bool? autoAllocate;
  final int? year;
  final int? month;

  const UserBudgetUpdateRequest({
    this.totalMonthlyBudget,
    this.currency,
    this.autoAllocate,
    this.year,
    this.month,
  });

  factory UserBudgetUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$UserBudgetUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UserBudgetUpdateRequestToJson(this);

  @override
  List<Object?> get props => [
    totalMonthlyBudget,
    currency,
    autoAllocate,
    year,
    month,
  ];
}

// User Budget Response
@JsonSerializable()
class UserBudget extends Equatable {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'total_monthly_budget')
  final double totalMonthlyBudget;
  final String currency;
  @JsonKey(name: 'auto_allocate')
  final bool autoAllocate;
  final int year;
  final int month;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const UserBudget({
    required this.id,
    required this.userId,
    required this.totalMonthlyBudget,
    required this.currency,
    required this.autoAllocate,
    required this.year,
    required this.month,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserBudget.fromJson(Map<String, dynamic> json) =>
      _$UserBudgetFromJson(json);
  Map<String, dynamic> toJson() => _$UserBudgetToJson(this);

  @override
  List<Object?> get props => [
    id,
    userId,
    totalMonthlyBudget,
    currency,
    autoAllocate,
    year,
    month,
    createdAt,
    updatedAt,
  ];
}

// Budget Category Create Request
@JsonSerializable()
class BudgetCategoryCreateRequest extends Equatable {
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'monthly_limit')
  final double monthlyLimit;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const BudgetCategoryCreateRequest({
    required this.categoryId,
    required this.monthlyLimit,
    this.isActive = true,
  });

  factory BudgetCategoryCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoryCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetCategoryCreateRequestToJson(this);

  @override
  List<Object?> get props => [categoryId, monthlyLimit, isActive];
}

// Budget Category Response
@JsonSerializable()
class BudgetCategory extends Equatable {
  final String id;
  @JsonKey(name: 'user_budget_id')
  final String userBudgetId;
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'category_name')
  final String categoryName;
  @JsonKey(name: 'monthly_limit')
  final double monthlyLimit;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const BudgetCategory({
    required this.id,
    required this.userBudgetId,
    required this.categoryId,
    required this.categoryName,
    required this.monthlyLimit,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetCategoryToJson(this);

  @override
  List<Object?> get props => [
    id,
    userBudgetId,
    categoryId,
    categoryName,
    monthlyLimit,
    isActive,
    createdAt,
    updatedAt,
  ];
}

// Budget Categories List Response
@JsonSerializable()
class BudgetCategoriesResponse extends Equatable {
  @JsonKey(name: 'category_budgets')
  final List<BudgetCategory> categoryBudgets;

  const BudgetCategoriesResponse({required this.categoryBudgets});

  factory BudgetCategoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$BudgetCategoriesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetCategoriesResponseToJson(this);

  @override
  List<Object?> get props => [categoryBudgets];
}

// Budget Summary Item
@JsonSerializable()
class BudgetSummaryItem extends Equatable {
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'category_name')
  final String categoryName;
  @JsonKey(name: 'monthly_limit')
  final double monthlyLimit;
  @JsonKey(name: 'current_spending')
  final double currentSpending;
  @JsonKey(name: 'remaining_budget')
  final double remainingBudget;
  @JsonKey(name: 'usage_percentage')
  final double usagePercentage;
  @JsonKey(name: 'is_over_budget')
  final bool isOverBudget;

  const BudgetSummaryItem({
    this.categoryId = '',
    this.categoryName = '',
    this.monthlyLimit = 0.0,
    this.currentSpending = 0.0,
    this.remainingBudget = 0.0,
    this.usagePercentage = 0.0,
    this.isOverBudget = false,
  });

  factory BudgetSummaryItem.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetSummaryItem(
        categoryId: json['category_id'] as String? ?? '',
        categoryName: json['category_name'] as String? ?? '',
        monthlyLimit: (json['monthly_limit'] as num?)?.toDouble() ?? 0.0,
        currentSpending: (json['current_spending'] as num?)?.toDouble() ?? 0.0,
        remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
        usagePercentage: (json['usage_percentage'] as num?)?.toDouble() ?? 0.0,
        isOverBudget: json['is_over_budget'] as bool? ?? false,
      );
    } catch (e) {
      print('❌ Error parsing BudgetSummaryItem: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$BudgetSummaryItemToJson(this);

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    monthlyLimit,
    currentSpending,
    remainingBudget,
    usagePercentage,
    isOverBudget,
  ];
}

// Budget Summary Response
@JsonSerializable()
class BudgetSummaryResponse extends Equatable {
  @JsonKey(name: 'total_monthly_budget')
  final double totalMonthlyBudget;
  @JsonKey(name: 'total_allocated')
  final double totalAllocated;
  @JsonKey(name: 'total_spent')
  final double totalSpent;
  @JsonKey(name: 'remaining_budget')
  final double remainingBudget;
  @JsonKey(name: 'unallocated_budget')
  final double unallocatedBudget;
  @JsonKey(name: 'allocation_percentage')
  final double allocationPercentage;
  @JsonKey(name: 'spending_percentage')
  final double spendingPercentage;
  @JsonKey(name: 'categories_over_budget')
  final int categoriesOverBudget;
  @JsonKey(name: 'category_summaries')
  final List<BudgetSummaryItem> categorySummaries;
  final int year;
  final int month;

  const BudgetSummaryResponse({
    this.totalMonthlyBudget = 0.0,
    this.totalAllocated = 0.0,
    this.totalSpent = 0.0,
    this.remainingBudget = 0.0,
    this.unallocatedBudget = 0.0,
    this.allocationPercentage = 0.0,
    this.spendingPercentage = 0.0,
    this.categoriesOverBudget = 0,
    this.categorySummaries = const [],
    required this.year,
    required this.month,
  });

  factory BudgetSummaryResponse.fromJson(Map<String, dynamic> json) {
    try {
      final now = DateTime.now();
      return BudgetSummaryResponse(
        totalMonthlyBudget:
            (json['total_monthly_budget'] as num?)?.toDouble() ?? 0.0,
        totalAllocated: (json['total_allocated'] as num?)?.toDouble() ?? 0.0,
        totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
        remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
        unallocatedBudget:
            (json['unallocated_budget'] as num?)?.toDouble() ?? 0.0,
        allocationPercentage:
            (json['allocation_percentage'] as num?)?.toDouble() ?? 0.0,
        spendingPercentage:
            (json['spending_percentage'] as num?)?.toDouble() ?? 0.0,
        categoriesOverBudget:
            (json['categories_over_budget'] as num?)?.toInt() ?? 0,
        categorySummaries:
            (json['category_summaries'] as List<dynamic>?)
                ?.map(
                  (item) =>
                      BudgetSummaryItem.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [],
        year: (json['year'] as int?) ?? now.year,
        month: (json['month'] as int?) ?? now.month,
      );
    } catch (e) {
      print('❌ Error parsing BudgetSummaryResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$BudgetSummaryResponseToJson(this);

  @override
  List<Object?> get props => [
    totalMonthlyBudget,
    totalAllocated,
    totalSpent,
    remainingBudget,
    unallocatedBudget,
    allocationPercentage,
    spendingPercentage,
    categoriesOverBudget,
    categorySummaries,
    year,
    month,
  ];
}

// Budget Allocation Request
@JsonSerializable()
class BudgetAllocationRequest extends Equatable {
  @JsonKey(name: 'total_budget')
  final double totalBudget;
  final List<String>? categories;
  final int? year;
  final int? month;

  const BudgetAllocationRequest({
    required this.totalBudget,
    this.categories,
    this.year,
    this.month,
  });

  factory BudgetAllocationRequest.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetAllocationRequest(
        totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
        categories: (json['categories'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        year: json['year'] as int?,
        month: json['month'] as int?,
      );
    } catch (e) {
      print('❌ Error parsing BudgetAllocationRequest: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$BudgetAllocationRequestToJson(this);

  @override
  List<Object?> get props => [totalBudget, categories, year, month];
}

// Budget Allocation Item
@JsonSerializable()
class BudgetAllocationItem extends Equatable {
  @JsonKey(name: 'category_id')
  final String categoryId;
  @JsonKey(name: 'category_name')
  final String categoryName;
  @JsonKey(name: 'allocated_amount')
  final double allocatedAmount;
  final double percentage;

  const BudgetAllocationItem({
    this.categoryId = '',
    this.categoryName = '',
    this.allocatedAmount = 0.0,
    this.percentage = 0.0,
  });

  factory BudgetAllocationItem.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetAllocationItem(
        categoryId: json['category_id'] as String? ?? '',
        categoryName: json['category_name'] as String? ?? '',
        allocatedAmount: (json['allocated_amount'] as num?)?.toDouble() ?? 0.0,
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      );
    } catch (e) {
      print('❌ Error parsing BudgetAllocationItem: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$BudgetAllocationItemToJson(this);

  @override
  List<Object?> get props => [
    categoryId,
    categoryName,
    allocatedAmount,
    percentage,
  ];
}

// Budget Allocation Response
@JsonSerializable()
class BudgetAllocationResponse extends Equatable {
  @JsonKey(name: 'total_budget')
  final double totalBudget;
  @JsonKey(name: 'total_allocated')
  final double totalAllocated;
  final List<BudgetAllocationItem> allocations;
  final String message;
  final int year;
  final int month;

  const BudgetAllocationResponse({
    this.totalBudget = 0.0,
    this.totalAllocated = 0.0,
    this.allocations = const [],
    this.message = '',
    required this.year,
    required this.month,
  });

  factory BudgetAllocationResponse.fromJson(Map<String, dynamic> json) {
    try {
      final now = DateTime.now();
      return BudgetAllocationResponse(
        totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
        totalAllocated: (json['total_allocated'] as num?)?.toDouble() ?? 0.0,
        allocations:
            (json['allocations'] as List<dynamic>?)
                ?.map(
                  (item) => BudgetAllocationItem.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
        message: json['message'] as String? ?? '',
        year: (json['year'] as int?) ?? now.year,
        month: (json['month'] as int?) ?? now.month,
      );
    } catch (e) {
      print('❌ Error parsing BudgetAllocationResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }
  Map<String, dynamic> toJson() => _$BudgetAllocationResponseToJson(this);

  @override
  List<Object?> get props => [
    totalBudget,
    totalAllocated,
    allocations,
    message,
    year,
    month,
  ];
}

// Budget Health Response
@JsonSerializable()
class BudgetHealthResponse extends Equatable {
  final String status;
  final String service;
  final DateTime timestamp;
  final String version;

  const BudgetHealthResponse({
    required this.status,
    required this.service,
    required this.timestamp,
    required this.version,
  });

  factory BudgetHealthResponse.fromJson(Map<String, dynamic> json) =>
      _$BudgetHealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetHealthResponseToJson(this);

  @override
  List<Object?> get props => [status, service, timestamp, version];
}

// Yeni model: Budget List Response
@JsonSerializable()
class BudgetListResponse extends Equatable {
  final List<UserBudget> budgets;
  final int count;
  final int page;
  final int limit;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_previous')
  final bool hasPrevious;

  const BudgetListResponse({
    this.budgets = const [],
    this.count = 0,
    this.page = 1,
    this.limit = 12,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory BudgetListResponse.fromJson(Map<String, dynamic> json) {
    try {
      return BudgetListResponse(
        budgets:
            (json['budgets'] as List<dynamic>?)
                ?.map(
                  (item) => UserBudget.fromJson(item as Map<String, dynamic>),
                )
                .toList() ??
            [],
        count: (json['count'] as int?) ?? 0,
        page: (json['page'] as int?) ?? 1,
        limit: (json['limit'] as int?) ?? 12,
        hasNext: json['has_next'] as bool? ?? false,
        hasPrevious: json['has_previous'] as bool? ?? false,
      );
    } catch (e) {
      print('❌ Error parsing BudgetListResponse: $e');
      print('📄 JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$BudgetListResponseToJson(this);

  @override
  List<Object?> get props => [
    budgets,
    count,
    page,
    limit,
    hasNext,
    hasPrevious,
  ];
}
