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
  @JsonKey(name: 'transaction_date')
  final DateTime transactionDate;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  final String currency;
  final String? notes;
  final List<ExpenseItem> items;

  const CreateExpenseRequest({
    required this.merchantName,
    required this.transactionDate,
    required this.totalAmount,
    required this.currency,
    this.notes,
    required this.items,
  });

  factory CreateExpenseRequest.fromJson(Map<String, dynamic> json) => _$CreateExpenseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateExpenseRequestToJson(this);

  @override
  List<Object?> get props => [
        merchantName,
        transactionDate,
        totalAmount,
        currency,
        notes,
        items,
      ];
}

@JsonSerializable()
class ExpenseItem extends Equatable {
  final String description;
  final double amount;
  final int quantity;
  final String? category;
  @JsonKey(name: 'unit_price')
  final double unitPrice;

  const ExpenseItem({
    required this.description,
    required this.amount,
    required this.quantity,
    this.category,
    required this.unitPrice,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => _$ExpenseItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemToJson(this);

  @override
  List<Object?> get props => [
        description,
        amount,
        quantity,
        category,
        unitPrice,
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