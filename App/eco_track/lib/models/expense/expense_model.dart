import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class Expense extends Equatable {
  final String id;
  @JsonKey(name: 'receipt_id')
  final String receiptId;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'expense_date')
  final DateTime expenseDate;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'merchant_name')
  final String? merchantName;
  final String? currency;
  final String? source;
  @JsonKey(name: 'items_count')
  final int? itemsCount;
  final List<ExpenseItem>? items;
  @JsonKey(name: 'qr_code')
  final String? qrCode;

  const Expense({
    required this.id,
    required this.receiptId,
    this.userId,
    required this.expenseDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    required this.totalAmount,
    this.merchantName,
    this.currency,
    this.source,
    this.itemsCount,
    this.items,
    this.qrCode,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);

  Expense copyWith({
    String? id,
    String? receiptId,
    String? userId,
    DateTime? expenseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? totalAmount,
    String? merchantName,
    String? currency,
    String? source,
    int? itemsCount,
    List<ExpenseItem>? items,
    String? qrCode,
  }) {
    return Expense(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      userId: userId ?? this.userId,
      expenseDate: expenseDate ?? this.expenseDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalAmount: totalAmount ?? this.totalAmount,
      merchantName: merchantName ?? this.merchantName,
      currency: currency ?? this.currency,
      source: source ?? this.source,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  @override
  List<Object?> get props => [
        id,
        receiptId,
        userId,
        expenseDate,
        notes,
        createdAt,
        updatedAt,
        totalAmount,
        merchantName,
        currency,
        source,
        itemsCount,
        items,
        qrCode,
      ];
}

// Expense Item Model
@JsonSerializable()
class ExpenseItem extends Equatable {
  final String id;
  @JsonKey(name: 'expense_id')
  final String expenseId;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'category_name')
  final String? categoryName;
  @JsonKey(name: 'item_name')
  final String itemName;
  final double amount;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double? unitPrice;
  @JsonKey(name: 'kdv_rate')
  final double kdvRate;
  @JsonKey(name: 'amount_without_kdv')
  final double? amountWithoutKdv;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const ExpenseItem({
    required this.id,
    required this.expenseId,
    this.categoryId,
    this.categoryName,
    required this.itemName,
    required this.amount,
    this.quantity = 1,
    this.unitPrice,
    this.kdvRate = 20.0,
    this.amountWithoutKdv,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => _$ExpenseItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemToJson(this);

  ExpenseItem copyWith({
    String? id,
    String? expenseId,
    String? categoryId,
    String? categoryName,
    String? itemName,
    double? amount,
    int? quantity,
    double? unitPrice,
    double? kdvRate,
    double? amountWithoutKdv,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      itemName: itemName ?? this.itemName,
      amount: amount ?? this.amount,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      kdvRate: kdvRate ?? this.kdvRate,
      amountWithoutKdv: amountWithoutKdv ?? this.amountWithoutKdv,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        expenseId,
        categoryId,
        categoryName,
        itemName,
        amount,
        quantity,
        unitPrice,
        kdvRate,
        amountWithoutKdv,
        notes,
        createdAt,
        updatedAt,
      ];
}

// Expense List Response
@JsonSerializable()
class ExpenseListResponse extends Equatable {
  final List<Expense> expenses;
  final int total;
  final int page;
  final int limit;
  @JsonKey(name: 'has_next')
  final bool hasNext;
  @JsonKey(name: 'has_previous')
  final bool hasPrevious;

  const ExpenseListResponse({
    required this.expenses,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ExpenseListResponse.fromJson(Map<String, dynamic> json) => _$ExpenseListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseListResponseToJson(this);

  @override
  List<Object> get props => [expenses, total, page, limit, hasNext, hasPrevious];
}

// Expense Update Request
@JsonSerializable()
class ExpenseUpdateRequest extends Equatable {
  @JsonKey(name: 'expense_date')
  final DateTime? expenseDate;
  final String? notes;
  @JsonKey(name: 'merchant_name')
  final String? merchantName;

  const ExpenseUpdateRequest({
    this.expenseDate,
    this.notes,
    this.merchantName,
  });

  factory ExpenseUpdateRequest.fromJson(Map<String, dynamic> json) => _$ExpenseUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseUpdateRequestToJson(this);

  @override
  List<Object?> get props => [expenseDate, notes, merchantName];
}

// Expense Item Create Request
@JsonSerializable()
class ExpenseItemCreateRequest extends Equatable {
  @JsonKey(name: 'category_id')
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

  const ExpenseItemCreateRequest({
    this.categoryId,
    required this.itemName,
    required this.amount,
    this.quantity = 1,
    this.unitPrice,
    this.kdvRate = 20.0,
    this.notes,
  });

  factory ExpenseItemCreateRequest.fromJson(Map<String, dynamic> json) => _$ExpenseItemCreateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemCreateRequestToJson(this);

  @override
  List<Object?> get props => [categoryId, itemName, amount, quantity, unitPrice, kdvRate, notes];
}

// Expense Item Update Request
@JsonSerializable()
class ExpenseItemUpdateRequest extends Equatable {
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'item_name')
  final String? itemName;
  final double? amount;
  final int? quantity;
  @JsonKey(name: 'unit_price')
  final double? unitPrice;
  @JsonKey(name: 'kdv_rate')
  final double? kdvRate;
  final String? notes;

  const ExpenseItemUpdateRequest({
    this.categoryId,
    this.itemName,
    this.amount,
    this.quantity,
    this.unitPrice,
    this.kdvRate,
    this.notes,
  });

  factory ExpenseItemUpdateRequest.fromJson(Map<String, dynamic> json) => _$ExpenseItemUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseItemUpdateRequestToJson(this);

  @override
  List<Object?> get props => [categoryId, itemName, amount, quantity, unitPrice, kdvRate, notes];
} 