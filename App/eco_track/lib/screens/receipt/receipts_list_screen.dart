import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/receipt_provider.dart';
import '../../models/receipt/receipt_model.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/common/loading_overlay.dart';

class ReceiptsListScreen extends ConsumerStatefulWidget {
  const ReceiptsListScreen({super.key});

  @override
  ConsumerState<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends ConsumerState<ReceiptsListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _categories = [
    'Food & Beverage',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Bills',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptProvider.notifier).loadReceipts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more data when approaching end of page
      ref.read(receiptProvider.notifier).loadReceipts(
        merchantName: _searchController.text.trim().isEmpty 
            ? null 
            : _searchController.text.trim(),
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
      );
    }
  }

  void _applyFilters() {
    ref.read(receiptProvider.notifier).loadReceipts(
      refresh: true,
      merchantName: _searchController.text.trim().isEmpty 
          ? null 
          : _searchController.text.trim(),
      category: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
    ref.read(receiptProvider.notifier).loadReceipts(refresh: true);
  }

  Future<void> _selectDateRange() async {
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (dateRange != null) {
      setState(() {
        _startDate = dateRange.start;
        _endDate = dateRange.end;
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Merchant Search
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Merchant Name',
                  hintText: 'Search by merchant name...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Selection
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Date Range
              InkWell(
                onTap: _selectDateRange,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range),
                      const SizedBox(width: 8),
                      Text(
                        _startDate != null && _endDate != null
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year} - ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'Select date range',
                        style: TextStyle(
                          color: _startDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _applyFilters();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final receiptState = ref.watch(receiptProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Receipts'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/qr-scanner');
              },
              icon: const Icon(Icons.qr_code_scanner),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/add-expense');
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: receiptState.isLoading && receiptState.receipts.isEmpty,
          loadingText: 'Loading receipts...',
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(receiptProvider.notifier).loadReceipts(
                refresh: true,
                merchantName: _searchController.text.trim().isEmpty 
                    ? null 
                    : _searchController.text.trim(),
                category: _selectedCategory,
                startDate: _startDate,
                endDate: _endDate,
              );
            },
            child: receiptState.receipts.isEmpty && !receiptState.isLoading
                ? _buildEmptyState()
                : _buildReceiptsList(receiptState),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No receipts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start by scanning QR codes or\nadding expenses manually',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptsList(ReceiptState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: state.receipts.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.receipts.length) {
          // Loading indicator for pagination
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final receipt = state.receipts[index];
        return _buildReceiptCard(receipt);
      },
    );
  }

  Widget _buildReceiptCard(Receipt receipt) {
    final itemCount = receipt.parsedReceiptData?.items?.length ?? 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            '/receipt-detail',
            arguments: receipt.id,
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      receipt.merchantName ?? 'Unknown Merchant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (receipt.totalAmount != null)
                    Text(
                      '${receipt.totalAmount!.toStringAsFixed(2)} ${receipt.currency ?? 'TRY'}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${receipt.transactionDate.day}/${receipt.transactionDate.month}/${receipt.transactionDate.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '$itemCount items',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              if (receipt.parsedReceiptData?.notes != null && 
                  receipt.parsedReceiptData!.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  receipt.parsedReceiptData!.notes!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (receipt.isPublic)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Shared',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleMenuAction(value, receipt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Receipt receipt) {
    switch (action) {
      case 'view':
        Navigator.of(context).pushNamed(
          '/receipt-detail',
          arguments: receipt.id,
        );
        break;
      case 'share':
        _shareReceipt(receipt);
        break;
      case 'delete':
        _deleteReceipt(receipt);
        break;
    }
  }

  void _shareReceipt(Receipt receipt) async {
    try {
      await ref.read(receiptProvider.notifier).shareReceipt(receipt.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt shared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _deleteReceipt(Receipt receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: Text('Are you sure you want to delete the receipt from ${receipt.merchantName ?? 'Unknown Merchant'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(receiptProvider.notifier).deleteReceipt(receipt.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 