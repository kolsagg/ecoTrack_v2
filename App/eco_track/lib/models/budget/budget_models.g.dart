// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBudgetCreateRequest _$UserBudgetCreateRequestFromJson(
  Map<String, dynamic> json,
) => UserBudgetCreateRequest(
  totalMonthlyBudget: (json['total_monthly_budget'] as num).toDouble(),
  currency: json['currency'] as String? ?? 'TRY',
  autoAllocate: json['auto_allocate'] as bool? ?? true,
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserBudgetCreateRequestToJson(
  UserBudgetCreateRequest instance,
) => <String, dynamic>{
  'total_monthly_budget': instance.totalMonthlyBudget,
  'currency': instance.currency,
  'auto_allocate': instance.autoAllocate,
  'year': instance.year,
  'month': instance.month,
};

UserBudgetUpdateRequest _$UserBudgetUpdateRequestFromJson(
  Map<String, dynamic> json,
) => UserBudgetUpdateRequest(
  totalMonthlyBudget: (json['total_monthly_budget'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  autoAllocate: json['auto_allocate'] as bool?,
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserBudgetUpdateRequestToJson(
  UserBudgetUpdateRequest instance,
) => <String, dynamic>{
  'total_monthly_budget': instance.totalMonthlyBudget,
  'currency': instance.currency,
  'auto_allocate': instance.autoAllocate,
  'year': instance.year,
  'month': instance.month,
};

UserBudget _$UserBudgetFromJson(Map<String, dynamic> json) => UserBudget(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  totalMonthlyBudget: (json['total_monthly_budget'] as num).toDouble(),
  currency: json['currency'] as String,
  autoAllocate: json['auto_allocate'] as bool,
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserBudgetToJson(UserBudget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'total_monthly_budget': instance.totalMonthlyBudget,
      'currency': instance.currency,
      'auto_allocate': instance.autoAllocate,
      'year': instance.year,
      'month': instance.month,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

BudgetCategoryCreateRequest _$BudgetCategoryCreateRequestFromJson(
  Map<String, dynamic> json,
) => BudgetCategoryCreateRequest(
  categoryId: json['category_id'] as String,
  monthlyLimit: (json['monthly_limit'] as num).toDouble(),
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$BudgetCategoryCreateRequestToJson(
  BudgetCategoryCreateRequest instance,
) => <String, dynamic>{
  'category_id': instance.categoryId,
  'monthly_limit': instance.monthlyLimit,
  'is_active': instance.isActive,
};

BudgetCategory _$BudgetCategoryFromJson(Map<String, dynamic> json) =>
    BudgetCategory(
      id: json['id'] as String,
      userBudgetId: json['user_budget_id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      monthlyLimit: (json['monthly_limit'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$BudgetCategoryToJson(BudgetCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_budget_id': instance.userBudgetId,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'monthly_limit': instance.monthlyLimit,
      'is_active': instance.isActive,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

BudgetCategoriesResponse _$BudgetCategoriesResponseFromJson(
  Map<String, dynamic> json,
) => BudgetCategoriesResponse(
  categoryBudgets: (json['category_budgets'] as List<dynamic>)
      .map((e) => BudgetCategory.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BudgetCategoriesResponseToJson(
  BudgetCategoriesResponse instance,
) => <String, dynamic>{'category_budgets': instance.categoryBudgets};

BudgetSummaryItem _$BudgetSummaryItemFromJson(Map<String, dynamic> json) =>
    BudgetSummaryItem(
      categoryId: json['category_id'] as String? ?? '',
      categoryName: json['category_name'] as String? ?? '',
      monthlyLimit: (json['monthly_limit'] as num?)?.toDouble() ?? 0.0,
      currentSpending: (json['current_spending'] as num?)?.toDouble() ?? 0.0,
      remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
      usagePercentage: (json['usage_percentage'] as num?)?.toDouble() ?? 0.0,
      isOverBudget: json['is_over_budget'] as bool? ?? false,
    );

Map<String, dynamic> _$BudgetSummaryItemToJson(BudgetSummaryItem instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'monthly_limit': instance.monthlyLimit,
      'current_spending': instance.currentSpending,
      'remaining_budget': instance.remainingBudget,
      'usage_percentage': instance.usagePercentage,
      'is_over_budget': instance.isOverBudget,
    };

BudgetSummaryResponse _$BudgetSummaryResponseFromJson(
  Map<String, dynamic> json,
) => BudgetSummaryResponse(
  totalMonthlyBudget: (json['total_monthly_budget'] as num?)?.toDouble() ?? 0.0,
  totalAllocated: (json['total_allocated'] as num?)?.toDouble() ?? 0.0,
  totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
  remainingBudget: (json['remaining_budget'] as num?)?.toDouble() ?? 0.0,
  unallocatedBudget: (json['unallocated_budget'] as num?)?.toDouble() ?? 0.0,
  allocationPercentage:
      (json['allocation_percentage'] as num?)?.toDouble() ?? 0.0,
  spendingPercentage: (json['spending_percentage'] as num?)?.toDouble() ?? 0.0,
  categoriesOverBudget: (json['categories_over_budget'] as num?)?.toInt() ?? 0,
  categorySummaries:
      (json['category_summaries'] as List<dynamic>?)
          ?.map((e) => BudgetSummaryItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
);

Map<String, dynamic> _$BudgetSummaryResponseToJson(
  BudgetSummaryResponse instance,
) => <String, dynamic>{
  'total_monthly_budget': instance.totalMonthlyBudget,
  'total_allocated': instance.totalAllocated,
  'total_spent': instance.totalSpent,
  'remaining_budget': instance.remainingBudget,
  'unallocated_budget': instance.unallocatedBudget,
  'allocation_percentage': instance.allocationPercentage,
  'spending_percentage': instance.spendingPercentage,
  'categories_over_budget': instance.categoriesOverBudget,
  'category_summaries': instance.categorySummaries,
  'year': instance.year,
  'month': instance.month,
};

BudgetAllocationRequest _$BudgetAllocationRequestFromJson(
  Map<String, dynamic> json,
) => BudgetAllocationRequest(
  totalBudget: (json['total_budget'] as num).toDouble(),
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  year: (json['year'] as num?)?.toInt(),
  month: (json['month'] as num?)?.toInt(),
);

Map<String, dynamic> _$BudgetAllocationRequestToJson(
  BudgetAllocationRequest instance,
) => <String, dynamic>{
  'total_budget': instance.totalBudget,
  'categories': instance.categories,
  'year': instance.year,
  'month': instance.month,
};

BudgetAllocationItem _$BudgetAllocationItemFromJson(
  Map<String, dynamic> json,
) => BudgetAllocationItem(
  categoryId: json['category_id'] as String? ?? '',
  categoryName: json['category_name'] as String? ?? '',
  allocatedAmount: (json['allocated_amount'] as num?)?.toDouble() ?? 0.0,
  percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$BudgetAllocationItemToJson(
  BudgetAllocationItem instance,
) => <String, dynamic>{
  'category_id': instance.categoryId,
  'category_name': instance.categoryName,
  'allocated_amount': instance.allocatedAmount,
  'percentage': instance.percentage,
};

BudgetAllocationResponse _$BudgetAllocationResponseFromJson(
  Map<String, dynamic> json,
) => BudgetAllocationResponse(
  totalBudget: (json['total_budget'] as num?)?.toDouble() ?? 0.0,
  totalAllocated: (json['total_allocated'] as num?)?.toDouble() ?? 0.0,
  allocations:
      (json['allocations'] as List<dynamic>?)
          ?.map((e) => BudgetAllocationItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  message: json['message'] as String? ?? '',
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
);

Map<String, dynamic> _$BudgetAllocationResponseToJson(
  BudgetAllocationResponse instance,
) => <String, dynamic>{
  'total_budget': instance.totalBudget,
  'total_allocated': instance.totalAllocated,
  'allocations': instance.allocations,
  'message': instance.message,
  'year': instance.year,
  'month': instance.month,
};

BudgetHealthResponse _$BudgetHealthResponseFromJson(
  Map<String, dynamic> json,
) => BudgetHealthResponse(
  status: json['status'] as String,
  service: json['service'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  version: json['version'] as String,
);

Map<String, dynamic> _$BudgetHealthResponseToJson(
  BudgetHealthResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'service': instance.service,
  'timestamp': instance.timestamp.toIso8601String(),
  'version': instance.version,
};

BudgetListResponse _$BudgetListResponseFromJson(Map<String, dynamic> json) =>
    BudgetListResponse(
      budgets:
          (json['budgets'] as List<dynamic>?)
              ?.map((e) => UserBudget.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      count: (json['count'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 12,
      hasNext: json['has_next'] as bool? ?? false,
      hasPrevious: json['has_previous'] as bool? ?? false,
    );

Map<String, dynamic> _$BudgetListResponseToJson(BudgetListResponse instance) =>
    <String, dynamic>{
      'budgets': instance.budgets,
      'count': instance.count,
      'page': instance.page,
      'limit': instance.limit,
      'has_next': instance.hasNext,
      'has_previous': instance.hasPrevious,
    };
