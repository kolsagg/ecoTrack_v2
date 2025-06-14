import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class Expense extends Equatable {
  final String id;
  @JsonKey(name: 'receipt_id')
  final String receiptId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'expense_date')
  final DateTime expenseDate;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @JsonKey(name: 'total_amount')
  final double? totalAmount;

  const Expense({
    required this.id,
    required this.receiptId,
    required this.userId,
    required this.expenseDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.totalAmount,
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
      ];
} 