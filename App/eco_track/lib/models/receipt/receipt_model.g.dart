// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
  id: json['id'] as String,
  userId: json['user_id'] as String?,
  rawQrData: json['raw_qr_data'] as String?,
  merchantName: json['merchant_name'] as String?,
  transactionDate: DateTime.parse(json['transaction_date'] as String),
  totalAmount: (json['total_amount'] as num?)?.toDouble(),
  currency: json['currency'] as String?,
  source: json['source'] as String,
  parsedReceiptData: json['parsed_receipt_data'] == null
      ? null
      : ParsedReceiptData.fromJson(
          json['parsed_receipt_data'] as Map<String, dynamic>,
        ),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  merchantId: json['merchant_id'] as String?,
  isPublic: json['is_public'] as bool? ?? false,
);

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'raw_qr_data': instance.rawQrData,
  'merchant_name': instance.merchantName,
  'transaction_date': instance.transactionDate.toIso8601String(),
  'total_amount': instance.totalAmount,
  'currency': instance.currency,
  'source': instance.source,
  'parsed_receipt_data': instance.parsedReceiptData,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'merchant_id': instance.merchantId,
  'is_public': instance.isPublic,
};

ParsedReceiptData _$ParsedReceiptDataFromJson(Map<String, dynamic> json) =>
    ParsedReceiptData(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ReceiptItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ParsedReceiptDataToJson(ParsedReceiptData instance) =>
    <String, dynamic>{
      'items': instance.items,
      'notes': instance.notes,
      'metadata': instance.metadata,
    };

ReceiptItem _$ReceiptItemFromJson(Map<String, dynamic> json) => ReceiptItem(
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  quantity: (json['quantity'] as num).toInt(),
  category: json['category'] as String?,
  unitPrice: (json['unit_price'] as num).toDouble(),
);

Map<String, dynamic> _$ReceiptItemToJson(ReceiptItem instance) =>
    <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'quantity': instance.quantity,
      'category': instance.category,
      'unit_price': instance.unitPrice,
    };
