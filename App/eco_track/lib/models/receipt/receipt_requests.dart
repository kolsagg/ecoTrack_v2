import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'receipt_model.dart';

part 'receipt_requests.g.dart';

// QR Scan Request
@JsonSerializable()
class QrScanRequest extends Equatable {
  @JsonKey(name: 'qr_data')
  final String qrData;

  const QrScanRequest({
    required this.qrData,
  });

  factory QrScanRequest.fromJson(Map<String, dynamic> json) => _$QrScanRequestFromJson(json);
  Map<String, dynamic> toJson() => _$QrScanRequestToJson(this);

  @override
  List<Object> get props => [qrData];
}

// Create Expense Request
@JsonSerializable()
class CreateExpenseRequest extends Equatable {
  @JsonKey(name: 'merchant_name')
  final String merchantName;
  @JsonKey(name: 'expense_date')
  final DateTime? expenseDate;
  final String? notes;
  final String currency;
  final List<ExpenseItem> items;

  const CreateExpenseRequest({
    required this.merchantName,
    this.expenseDate,
    this.notes,
    this.currency = 'TRY',
    required this.items,
  });

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) => _$CreateExpenseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateExpenseRequestToJson(this);

  @override
  List<Object?> get props => [
        merchantName,
        expenseDate,
        notes,
        currency,
        items,
      ];
}

@JsonSerializable()
class ExpenseItem extends Equatable {
  @JsonKey(name: 'category_id', includeIfNull: false)
  final String? categoryId;
  @JsonKey(name: 'item_name')
  final String itemName;
  final double amount;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double? unitPrice;
  @JsonKey(name: 'kdv_rate')
  final double kdvRate;
  final String? notes;

  const ExpenseItem({
    this.categoryId,
    required this.itemName,
    required this.amount,
    this.quantity = 1,
    this.unitPrice,
    this.kdvRate = 20.0,
    this.notes,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => _$ExpenseItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemToJson(this);

  @override
  List<Object?> get props => [
        categoryId,
        itemName,
        amount,
        quantity,
        unitPrice,
        kdvRate,
        notes,
      ];
}

// Receipts List Response
@JsonSerializable()
class ReceiptsListResponse extends Equatable {
  final List<Receipt> receipts;
  final int total;
  final int page;
  @JsonKey(name: 'per_page')
  final int perPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;

  const ReceiptsListResponse({
    required this.receipts,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory ReceiptsListResponse.fromJson(Map<String, dynamic> json) => _$ReceiptsListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptsListResponseToJson(this);

  @override
  List<Object> get props => [receipts, total, page, perPage, totalPages];
}

// QR Scan Response
@JsonSerializable()
class QrScanResponse extends Equatable {
  final bool success;
  final String message;
  final Receipt? receipt;

  const QrScanResponse({
    required this.success,
    required this.message,
    this.receipt,
  });

  factory QrScanResponse.fromJson(Map<String, dynamic> json) => _$QrScanResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QrScanResponseToJson(this);

  @override
  List<Object?> get props => [success, message, receipt];
} 