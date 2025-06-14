import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'receipt_model.g.dart';

@JsonSerializable()
class Receipt extends Equatable {
  final String id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'raw_qr_data')
  final String? rawQrData;
  @JsonKey(name: 'merchant_name')
  final String? merchantName;
  @JsonKey(name: 'transaction_date')
  final DateTime transactionDate;
  @JsonKey(name: 'total_amount')
  final double? totalAmount;
  final String? currency;
  final String source;
  @JsonKey(name: 'parsed_receipt_data')
  final ParsedReceiptData? parsedReceiptData;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'merchant_id')
  final String? merchantId;
  @JsonKey(name: 'is_public')
  final bool isPublic;

  const Receipt({
    required this.id,
    this.userId,
    this.rawQrData,
    this.merchantName,
    required this.transactionDate,
    this.totalAmount,
    this.currency,
    required this.source,
    this.parsedReceiptData,
    required this.createdAt,
    required this.updatedAt,
    this.merchantId,
    this.isPublic = false,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptToJson(this);

  Receipt copyWith({
    String? id,
    String? userId,
    String? rawQrData,
    String? merchantName,
    DateTime? transactionDate,
    double? totalAmount,
    String? currency,
    String? source,
    ParsedReceiptData? parsedReceiptData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? merchantId,
    bool? isPublic,
  }) {
    return Receipt(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      rawQrData: rawQrData ?? this.rawQrData,
      merchantName: merchantName ?? this.merchantName,
      transactionDate: transactionDate ?? this.transactionDate,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      parsedReceiptData: parsedReceiptData ?? this.parsedReceiptData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      merchantId: merchantId ?? this.merchantId,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        rawQrData,
        merchantName,
        transactionDate,
        totalAmount,
        currency,
        source,
        parsedReceiptData,
        createdAt,
        updatedAt,
        merchantId,
        isPublic,
      ];
}

@JsonSerializable()
class ParsedReceiptData extends Equatable {
  final List<ReceiptItem>? items;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const ParsedReceiptData({
    this.items,
    this.notes,
    this.metadata,
  });

  factory ParsedReceiptData.fromJson(Map<String, dynamic> json) => _$ParsedReceiptDataFromJson(json);
  Map<String, dynamic> toJson() => _$ParsedReceiptDataToJson(this);

  ParsedReceiptData copyWith({
    List<ReceiptItem>? items,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return ParsedReceiptData(
      items: items ?? this.items,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [items, notes, metadata];
}

@JsonSerializable()
class ReceiptItem extends Equatable {
  final String description;
  final double amount;
  final int quantity;
  final String? category;
  @JsonKey(name: 'unit_price')
  final double unitPrice;

  const ReceiptItem({
    required this.description,
    required this.amount,
    required this.quantity,
    this.category,
    required this.unitPrice,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) => _$ReceiptItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptItemToJson(this);

  ReceiptItem copyWith({
    String? description,
    double? amount,
    int? quantity,
    String? category,
    double? unitPrice,
  }) {
    return ReceiptItem(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  List<Object?> get props => [
        description,
        amount,
        quantity,
        category,
        unitPrice,
      ];
} 