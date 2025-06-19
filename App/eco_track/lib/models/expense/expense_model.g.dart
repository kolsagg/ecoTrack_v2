// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  receiptId: json['receipt_id'] as String,
  userId: json['user_id'] as String?,
  expenseDate: DateTime.parse(json['expense_date'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  totalAmount: (json['total_amount'] as num).toDouble(),
  merchantName: json['merchant_name'] as String?,
  currency: json['currency'] as String?,
  source: json['source'] as String?,
  itemsCount: (json['items_count'] as num?)?.toInt(),
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  qrCode: json['qr_code'] as String?,
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'receipt_id': instance.receiptId,
  'user_id': instance.userId,
  'expense_date': instance.expenseDate.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'total_amount': instance.totalAmount,
  'merchant_name': instance.merchantName,
  'currency': instance.currency,
  'source': instance.source,
  'items_count': instance.itemsCount,
  'items': instance.items,
  'qr_code': instance.qrCode,
};

ExpenseItem _$ExpenseItemFromJson(Map<String, dynamic> json) => ExpenseItem(
  id: json['id'] as String,
  expenseId: json['expense_id'] as String,
  categoryId: json['category_id'] as String?,
  categoryName: json['category_name'] as String?,
  itemName: json['item_name'] as String,
  amount: (json['amount'] as num).toDouble(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unit_price'] as num?)?.toDouble(),
  kdvRate: (json['kdv_rate'] as num?)?.toDouble() ?? 20.0,
  amountWithoutKdv: (json['amount_without_kdv'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ExpenseItemToJson(ExpenseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expense_id': instance.expenseId,
      'category_id': instance.categoryId,
      'category_name': instance.categoryName,
      'item_name': instance.itemName,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'kdv_rate': instance.kdvRate,
      'amount_without_kdv': instance.amountWithoutKdv,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

ExpenseListResponse _$ExpenseListResponseFromJson(Map<String, dynamic> json) =>
    ExpenseListResponse(
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );

Map<String, dynamic> _$ExpenseListResponseToJson(
  ExpenseListResponse instance,
) => <String, dynamic>{
  'expenses': instance.expenses,
  'total': instance.total,
  'page': instance.page,
  'limit': instance.limit,
  'has_next': instance.hasNext,
  'has_previous': instance.hasPrevious,
};

ExpenseUpdateRequest _$ExpenseUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ExpenseUpdateRequest(
  expenseDate: json['expense_date'] == null
      ? null
      : DateTime.parse(json['expense_date'] as String),
  notes: json['notes'] as String?,
  merchantName: json['merchant_name'] as String?,
);

Map<String, dynamic> _$ExpenseUpdateRequestToJson(
  ExpenseUpdateRequest instance,
) => <String, dynamic>{
  'expense_date': instance.expenseDate?.toIso8601String(),
  'notes': instance.notes,
  'merchant_name': instance.merchantName,
};

ExpenseItemCreateRequest _$ExpenseItemCreateRequestFromJson(
  Map<String, dynamic> json,
) => ExpenseItemCreateRequest(
  categoryId: json['category_id'] as String?,
  itemName: json['item_name'] as String,
  amount: (json['amount'] as num).toDouble(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unit_price'] as num?)?.toDouble(),
  kdvRate: (json['kdv_rate'] as num?)?.toDouble() ?? 20.0,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ExpenseItemCreateRequestToJson(
  ExpenseItemCreateRequest instance,
) => <String, dynamic>{
  'category_id': instance.categoryId,
  'item_name': instance.itemName,
  'amount': instance.amount,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'kdv_rate': instance.kdvRate,
  'notes': instance.notes,
};

ExpenseItemUpdateRequest _$ExpenseItemUpdateRequestFromJson(
  Map<String, dynamic> json,
) => ExpenseItemUpdateRequest(
  categoryId: json['category_id'] as String?,
  itemName: json['item_name'] as String?,
  amount: (json['amount'] as num?)?.toDouble(),
  quantity: (json['quantity'] as num?)?.toInt(),
  unitPrice: (json['unit_price'] as num?)?.toDouble(),
  kdvRate: (json['kdv_rate'] as num?)?.toDouble(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ExpenseItemUpdateRequestToJson(
  ExpenseItemUpdateRequest instance,
) => <String, dynamic>{
  'category_id': instance.categoryId,
  'item_name': instance.itemName,
  'amount': instance.amount,
  'quantity': instance.quantity,
  'unit_price': instance.unitPrice,
  'kdv_rate': instance.kdvRate,
  'notes': instance.notes,
};
