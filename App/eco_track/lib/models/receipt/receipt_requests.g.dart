// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrScanRequest _$QrScanRequestFromJson(Map<String, dynamic> json) =>
    QrScanRequest(qrData: json['qr_data'] as String);

Map<String, dynamic> _$QrScanRequestToJson(QrScanRequest instance) =>
    <String, dynamic>{'qr_data': instance.qrData};

CreateExpenseRequest _$CreateExpenseRequestFromJson(
  Map<String, dynamic> json,
) => CreateExpenseRequest(
  merchantName: json['merchant_name'] as String,
  expenseDate: json['expense_date'] == null
      ? null
      : DateTime.parse(json['expense_date'] as String),
  notes: json['notes'] as String?,
  currency: json['currency'] as String? ?? 'TRY',
  items: (json['items'] as List<dynamic>)
      .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CreateExpenseRequestToJson(
  CreateExpenseRequest instance,
) => <String, dynamic>{
  'merchant_name': instance.merchantName,
  'expense_date': instance.expenseDate?.toIso8601String(),
  'notes': instance.notes,
  'currency': instance.currency,
  'items': instance.items,
};

ExpenseItem _$ExpenseItemFromJson(Map<String, dynamic> json) => ExpenseItem(
  categoryId: json['category_id'] as String?,
  itemName: json['item_name'] as String,
  amount: (json['amount'] as num).toDouble(),
  quantity: (json['quantity'] as num?)?.toInt() ?? 1,
  unitPrice: (json['unit_price'] as num?)?.toDouble(),
  kdvRate: (json['kdv_rate'] as num?)?.toDouble() ?? 20.0,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ExpenseItemToJson(ExpenseItem instance) =>
    <String, dynamic>{
      if (instance.categoryId case final value?) 'category_id': value,
      'item_name': instance.itemName,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'kdv_rate': instance.kdvRate,
      'notes': instance.notes,
    };

ReceiptsListResponse _$ReceiptsListResponseFromJson(
  Map<String, dynamic> json,
) => ReceiptsListResponse(
  receipts: (json['receipts'] as List<dynamic>)
      .map((e) => Receipt.fromJson(e as Map<String, dynamic>))
      .toList(),
  total: (json['total'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  totalPages: (json['total_pages'] as num).toInt(),
);

Map<String, dynamic> _$ReceiptsListResponseToJson(
  ReceiptsListResponse instance,
) => <String, dynamic>{
  'receipts': instance.receipts,
  'total': instance.total,
  'page': instance.page,
  'per_page': instance.perPage,
  'total_pages': instance.totalPages,
};

QrScanResponse _$QrScanResponseFromJson(Map<String, dynamic> json) =>
    QrScanResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      receipt: json['receipt'] == null
          ? null
          : Receipt.fromJson(json['receipt'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$QrScanResponseToJson(QrScanResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'receipt': instance.receipt,
    };
