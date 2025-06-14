// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
  id: json['id'] as String,
  receiptId: json['receipt_id'] as String,
  userId: json['user_id'] as String,
  expenseDate: DateTime.parse(json['expense_date'] as String),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  totalAmount: (json['total_amount'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
  'id': instance.id,
  'receipt_id': instance.receiptId,
  'user_id': instance.userId,
  'expense_date': instance.expenseDate.toIso8601String(),
  'notes': instance.notes,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'total_amount': instance.totalAmount,
};
