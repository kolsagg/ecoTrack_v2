import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../models/receipt/receipt_model.dart';
import '../models/receipt/receipt_requests.dart';
import '../models/expense/expense_model.dart';
import '../services/receipt_service.dart';

// Receipt Service Provider
final receiptServiceProvider = Provider<ReceiptService>((ref) {
  return getIt<ReceiptService>();
});

// Receipt State
class ReceiptState {
  final List<Receipt> receipts;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const ReceiptState({
    this.receipts = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  ReceiptState copyWith({
    List<Receipt>? receipts,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return ReceiptState(
      receipts: receipts ?? this.receipts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Receipt Notifier
class ReceiptNotifier extends StateNotifier<ReceiptState> {
  final ReceiptService _receiptService;

  ReceiptNotifier(this._receiptService) : super(const ReceiptState());

  // QR Code Scanning
  Future<QrScanResponse> scanQrCode(String qrData) async {
    try {
      return await _receiptService.scanQrCode(qrData);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Create Expense
  Future<Expense> createExpense(CreateExpenseRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final expense = await _receiptService.createExpense(request);
      // Refresh receipts after creating expense
      await loadReceipts(refresh: true);
      return expense;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Load Receipts
  Future<void> loadReceipts({
    bool refresh = false,
    String? merchantName,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    if (state.isLoading) return;

    try {
      final page = refresh ? 1 : state.currentPage + 1;
      
      if (!refresh && !state.hasMore) return;

      state = state.copyWith(isLoading: true, error: null);

      final response = await _receiptService.getReceipts(
        page: page,
        merchantName: merchantName,
        startDate: startDate,
        endDate: endDate,
        category: category,
      );

      final newReceipts = refresh 
          ? response.receipts 
          : [...state.receipts, ...response.receipts];

      state = state.copyWith(
        receipts: newReceipts,
        isLoading: false,
        currentPage: response.page,
        totalPages: response.totalPages,
        hasMore: response.page < response.totalPages,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Get Receipt Details
  Future<Receipt> getReceiptDetails(String receiptId) async {
    try {
      return await _receiptService.getReceiptDetails(receiptId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Share Receipt
  Future<Receipt> shareReceipt(String receiptId) async {
    try {
      final sharedReceipt = await _receiptService.shareReceipt(receiptId);
      
      // Update the receipt in the list
      final updatedReceipts = state.receipts.map((receipt) {
        return receipt.id == receiptId ? sharedReceipt : receipt;
      }).toList();
      
      state = state.copyWith(receipts: updatedReceipts);
      return sharedReceipt;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Delete Receipt
  Future<void> deleteReceipt(String receiptId) async {
    try {
      await _receiptService.deleteReceipt(receiptId);
      
      // Remove the receipt from the list
      final updatedReceipts = state.receipts
          .where((receipt) => receipt.id != receiptId)
          .toList();
      
      state = state.copyWith(receipts: updatedReceipts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Reset State
  void reset() {
    state = const ReceiptState();
  }
}

// Receipt Provider
final receiptProvider = StateNotifierProvider<ReceiptNotifier, ReceiptState>((ref) {
  final receiptService = ref.watch(receiptServiceProvider);
  return ReceiptNotifier(receiptService);
}); 