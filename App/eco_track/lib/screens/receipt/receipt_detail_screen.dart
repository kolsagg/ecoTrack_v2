import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/receipt_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/review_provider.dart';
import '../../models/receipt/receipt_model.dart';
import '../../models/expense/expense_model.dart';
import '../../models/review/review_models.dart';
import '../../widgets/common/loading_overlay.dart';

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  final String receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  Receipt? _receipt;
  Expense? _expense;
  bool _isLoading = true;
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReceiptDetail();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadReceiptDetail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Receipt detaylarını çek
      final receipt = await ref
          .read(receiptProvider.notifier)
          .getReceiptDetails(widget.receiptId);

      // Receipt ID ile ilişkili expense'i çek
      var expense = await ref
          .read(expenseProvider.notifier)
          .getExpenseByReceiptId(widget.receiptId);

      // Eğer expense varsa, detaylarını çek (items dahil)
      if (expense != null) {
        final expenseService = ref.read(expenseServiceProvider);
        expense = await expenseService.getExpenseDetail(expense.id);
      }

      setState(() {
        _receipt = receipt;
        _expense = expense;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(receiptReviewProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.grey[50],
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: LoadingOverlay(
          isLoading: _isLoading,
          loadingText: 'Loading receipt details...',
          child: _receipt == null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadReceiptDetail,
                  child: CustomScrollView(
                    slivers: [
                      _buildSliverAppBar(),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildReceiptCard(),
                              const SizedBox(height: 24),
                              // Only show review section if merchant is registered in our system
                              if (_receipt!.merchantId != null)
                                _buildRatingSection(reviewState),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => _showReceiptOptions(_receipt!),
                  icon: const Icon(Icons.more_vert, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Receipt not found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'The receipt you are looking for could not be found.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildReceiptHeader(),
          _buildReceiptInfo(),
          _buildItemsList(),
          _buildTotalSection(),
          _buildTaxDetails(),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withValues(alpha: 0.8),
            Colors.teal.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Text(
            _receipt!.merchantName ?? 'MERCHANT',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('dd.MM.yyyy HH:mm').format(_receipt!.transactionDate),
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Text(
            'Receipt No: ${_receipt!.id.length > 8 ? _receipt!.id.substring(0, 8) : _receipt!.id}',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInfoRow(
            'Date:',
            DateFormat('dd.MM.yyyy HH:mm').format(_receipt!.transactionDate),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Receipt ID:',
            _receipt!.id.length > 8
                ? _receipt!.id.substring(0, 8)
                : _receipt!.id,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    // Expense'den items çek, yoksa receipt'den çek
    final expenseItems = _expense?.items ?? [];
    final receiptItems = _receipt!.parsedReceiptData?.items ?? [];

    // Önce expense items'ları kullan, yoksa receipt items'ları
    final hasItems = expenseItems.isNotEmpty || receiptItems.isNotEmpty;

    if (!hasItems) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'No items available',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${expenseItems.isNotEmpty ? expenseItems.length : receiptItems.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          // Expense items varsa onları göster, yoksa receipt items'ları göster
          if (expenseItems.isNotEmpty)
            ...expenseItems.map((item) => _buildExpenseItemRow(item))
          else
            ...receiptItems.map((item) => _buildReceiptItemRow(item)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExpenseItemRow(ExpenseItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} pcs ${(item.unitPrice ?? (item.amount / item.quantity)).toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'} / pcs',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (item.categoryName != null)
                  Text(
                    'Category: ${item.categoryName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                Text(
                  'KDV: ${(item.amount * item.kdvRate / (100 + item.kdvRate)).toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'} (${item.kdvRate.toStringAsFixed(0)}%)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${item.amount.toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptItemRow(ReceiptItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} pcs ${item.unitPrice.toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'} / pcs',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (item.category != null)
                  Text(
                    'Category: ${item.category}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                Text(
                  'KDV: ${(item.amount * 20 / 120).toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'} (%20)',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${item.amount.toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade600, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_receipt!.totalAmount?.toStringAsFixed(2) ?? '0.00'} ${_receipt!.currency ?? 'TRY'}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxDetails() {
    final totalAmount = _receipt!.totalAmount ?? 0.0;

    // Items'lardan gerçek KDV tutarını hesapla (items altında gösterilen KDV tutarlarının toplamı)
    double totalTaxAmount = 0.0;
    double totalWithoutTax = 0.0;

    // Önce expense items'larını kontrol et
    final expenseItems = _expense?.items ?? [];
    if (expenseItems.isNotEmpty) {
      for (var item in expenseItems) {
        // Item altında gösterilen KDV hesaplaması ile aynı
        final itemTaxAmount = item.amount * item.kdvRate / (100 + item.kdvRate);
        totalTaxAmount += itemTaxAmount;
        totalWithoutTax += (item.amount - itemTaxAmount);
      }
    } else {
      // Expense items yoksa receipt items'larını kullan
      final receiptItems = _receipt!.parsedReceiptData?.items ?? [];
      if (receiptItems.isNotEmpty) {
        for (var item in receiptItems) {
          // Item altında gösterilen KDV hesaplaması ile aynı (%20 varsayılan)
          final itemTaxAmount = item.amount * 20 / 120;
          totalTaxAmount += itemTaxAmount;
          totalWithoutTax += (item.amount - itemTaxAmount);
        }
      } else {
        // Hiç item yoksa varsayılan %20 KDV hesapla
        totalWithoutTax = totalAmount / 1.20;
        totalTaxAmount = totalAmount - totalWithoutTax;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tax Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.2),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  const Text(
                    'KDV',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'Without tax',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${totalTaxAmount.toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${totalWithoutTax.toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${totalAmount.toStringAsFixed(2)} ${_receipt!.currency ?? 'TRY'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection(ReceiptReviewState reviewState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'How did you enjoy your order at ${_receipt!.merchantName ?? 'this merchant'}?',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRating = index + 1;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _selectedRating > index
                        ? Colors.amber
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.star,
                    color: _selectedRating > index
                        ? Colors.white
                        : Colors.grey[400],
                    size: 28,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience... (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppConstants.primaryColor),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedRating > 0 && !reviewState.isLoading
                  ? _submitReview
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedRating > 0
                    ? AppConstants.primaryColor
                    : Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: reviewState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Other Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No reviews yet. Be the first to review!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _submitReview() async {
    if (_selectedRating == 0) return;

    // UUID validation
    if (!_isValidUUID(widget.receiptId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid receipt ID format. Cannot submit review.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final request = ReceiptReviewCreateRequest(
        rating: _selectedRating,
        comment: _reviewController.text.trim(),
      );

      await ref
          .read(receiptReviewProvider.notifier)
          .createReceiptReview(widget.receiptId, request);

      final reviewState = ref.read(receiptReviewProvider);
      if (reviewState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${reviewState.error}'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reviewState.successMessage ?? 'Review submitted successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form
      setState(() {
        _selectedRating = 0;
        _reviewController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _isValidUUID(String uuid) {
    // UUID v4 regex pattern
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(uuid);
  }

  void _showReceiptOptions(Receipt receipt) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            if (!receipt.isPublic)
              ListTile(
                leading: const Icon(
                  Icons.public,
                  color: AppConstants.primaryColor,
                ),
                title: const Text('Make Public'),
                onTap: () {
                  Navigator.of(context).pop();
                  _makePublic(receipt);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _makePublic(Receipt receipt) async {
    try {
      await ref.read(receiptProvider.notifier).shareReceipt(receipt.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt made public successfully')),
      );
      // Reload receipt to get updated data
      await _loadReceiptDetail();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error making receipt public: $e')),
      );
    }
  }
}
