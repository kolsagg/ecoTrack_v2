import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../models/loyalty/loyalty_models.dart';
import '../../providers/loyalty_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class LoyaltyHistoryScreen extends ConsumerStatefulWidget {
  const LoyaltyHistoryScreen({super.key});

  @override
  ConsumerState<LoyaltyHistoryScreen> createState() =>
      _LoyaltyHistoryScreenState();
}

class _LoyaltyHistoryScreenState extends ConsumerState<LoyaltyHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  TransactionType? _selectedFilter;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _loadHistory() {
    ref
        .read(loyaltyHistoryProvider.notifier)
        .loadLoyaltyHistory(limit: _pageSize);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreHistory();
    }
  }

  void _loadMoreHistory() {
    final historyState = ref.read(loyaltyHistoryProvider);
    if (historyState.history != null &&
        historyState.history!.transactions.isNotEmpty &&
        !historyState.isLoading) {
      ref
          .read(loyaltyHistoryProvider.notifier)
          .loadLoyaltyHistory(limit: _pageSize);
    }
  }

  List<LoyaltyTransaction> _getFilteredTransactions(
    List<LoyaltyTransaction> transactions,
  ) {
    if (_selectedFilter == null) return transactions;
    return transactions
        .where((transaction) => transaction.transactionType == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(loyaltyHistoryProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction History'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _loadHistory,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
            IconButton(
              onPressed: _showFilterDialog,
              icon: Icon(
                _selectedFilter != null
                    ? Icons.filter_alt
                    : Icons.filter_alt_outlined,
              ),
              tooltip: 'Filter',
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: historyState.isLoading && historyState.history == null,
          loadingText: 'Loading history...',
          child: RefreshIndicator(
            onRefresh: () async => _loadHistory(),
            child: _buildContent(historyState),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(LoyaltyHistoryState historyState) {
    if (historyState.error != null && historyState.history == null) {
      return _buildErrorState(historyState.error!);
    }

    if (historyState.history == null || !historyState.history!.success) {
      return _buildEmptyState();
    }

    final filteredTransactions = _getFilteredTransactions(
      historyState.history!.transactions,
    );

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (_selectedFilter != null) _buildFilterChip(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredTransactions.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredTransactions.length) {
                return _buildLoadingIndicator(historyState.isLoading);
              }
              return _buildTransactionCard(filteredTransactions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Chip(
            label: Text(_selectedFilter!.displayName),
            deleteIcon: const Icon(Icons.close, size: 18),
            onDeleted: () {
              setState(() {
                _selectedFilter = null;
              });
            },
            backgroundColor: AppConstants.primaryColor.withValues(alpha: 0.1),
            side: BorderSide(color: AppConstants.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(LoyaltyTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getTransactionTypeColor(
              transaction.transactionType,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getTransactionTypeIcon(transaction.transactionType),
            color: _getTransactionTypeColor(transaction.transactionType),
            size: 24,
          ),
        ),
        title: Text(
          transaction.merchantName ?? transaction.transactionType.displayName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (transaction.category != null)
              Text(
                transaction.category!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 4),
            Text(
              transaction.transactionType.description,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${transaction.pointsEarned} pts',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₺${NumberFormat('#,##0.00').format(transaction.transactionAmount)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isLoading) {
    if (!isLoading) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error Loading History',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _selectedFilter != null
                  ? 'No ${_selectedFilter!.displayName} Transactions'
                  : 'No Transaction History',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter != null
                  ? 'No transactions found for the selected filter.'
                  : 'Start making purchases to see your transaction history.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTransactionTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Colors.blue;
      case TransactionType.bonus:
        return Colors.green;
      case TransactionType.adjustment:
        return Colors.orange;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return Icons.shopping_bag;
      case TransactionType.bonus:
        return Icons.card_giftcard;
      case TransactionType.adjustment:
        return Icons.tune;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Transactions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Transactions'),
              onTap: () {
                setState(() {
                  _selectedFilter = null;
                });
                Navigator.pop(context);
              },
              trailing: _selectedFilter == null
                  ? Icon(Icons.check, color: AppConstants.primaryColor)
                  : null,
            ),
            ...TransactionType.values.map(
              (type) => ListTile(
                leading: Icon(_getTransactionTypeIcon(type)),
                title: Text(type.displayName),
                subtitle: Text(type.description),
                onTap: () {
                  setState(() {
                    _selectedFilter = type;
                  });
                  Navigator.pop(context);
                },
                trailing: _selectedFilter == type
                    ? Icon(Icons.check, color: AppConstants.primaryColor)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetails(LoyaltyTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getTransactionTypeColor(
                      transaction.transactionType,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTransactionTypeIcon(transaction.transactionType),
                    color: _getTransactionTypeColor(
                      transaction.transactionType,
                    ),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.merchantName ??
                            transaction.transactionType.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.transactionType.displayName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Transaction ID', transaction.id),
            _buildDetailRow(
              'Amount',
              '₺${NumberFormat('#,##0.00').format(transaction.transactionAmount)}',
            ),
            _buildDetailRow('Points Earned', '${transaction.pointsEarned} pts'),
            if (transaction.category != null)
              _buildDetailRow('Category', transaction.category!),
            _buildDetailRow(
              'Date',
              DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
            ),
            if (transaction.expenseId != null)
              _buildDetailRow('Expense ID', transaction.expenseId!),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
