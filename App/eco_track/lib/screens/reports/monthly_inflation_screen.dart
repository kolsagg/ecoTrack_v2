import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/monthly_inflation_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../models/monthly_inflation.dart';

class MonthlyInflationScreen extends ConsumerStatefulWidget {
  const MonthlyInflationScreen({super.key});

  @override
  ConsumerState<MonthlyInflationScreen> createState() =>
      _MonthlyInflationScreenState();
}

class _MonthlyInflationScreenState
    extends ConsumerState<MonthlyInflationScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedYear;
  int? _selectedMonth;
  String _sortBy = 'inflation_percentage';
  String _order = 'desc';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    print('Loading monthly inflation data...');
    print(
      'Filters - Year: $_selectedYear, Month: $_selectedMonth, Search: ${_searchController.text}',
    );

    ref
        .read(monthlyInflationProvider.notifier)
        .loadMonthlyInflation(
          year: _selectedYear,
          month: _selectedMonth,
          productName: _searchController.text.isEmpty
              ? null
              : _searchController.text,
          sortBy: _sortBy,
          order: _order,
          limit: 100,
        );
  }

  Future<void> _selectYear() async {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    final selectedYear = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Year'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: years.length,
            itemBuilder: (context, index) {
              final year = years[index];
              final isSelected = year == _selectedYear;

              return ListTile(
                title: Text(year.toString()),
                selected: isSelected,
                selectedTileColor: AppConstants.primaryColor.withValues(
                  alpha: 0.1,
                ),
                onTap: () => Navigator.of(context).pop(year),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedYear = null;
              });
              Navigator.of(context).pop();
              _loadData();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (selectedYear != null) {
      setState(() {
        _selectedYear = selectedYear;
      });
      _loadData();
    }
  }

  Future<void> _selectMonth() async {
    final months = List.generate(12, (index) => index + 1);

    final selectedMonth = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              final isSelected = month == _selectedMonth;

              return ListTile(
                title: Text(_getMonthName(month)),
                selected: isSelected,
                selectedTileColor: AppConstants.primaryColor.withValues(
                  alpha: 0.1,
                ),
                onTap: () => Navigator.of(context).pop(month),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedMonth = null;
              });
              Navigator.of(context).pop();
              _loadData();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (selectedMonth != null) {
      setState(() {
        _selectedMonth = selectedMonth;
      });
      _loadData();
    }
  }

  void _onSearchChanged(String value) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (value == _searchController.text) {
        _loadData();
      }
    });
  }

  void _changeSorting(String sortBy, String order) {
    setState(() {
      _sortBy = sortBy;
      _order = order;
    });
    _loadData();
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(monthlyInflationProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Monthly Inflation'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: LoadingOverlay(
          isLoading: state.isLoading,
          loadingText: 'Loading inflation data...',
          child: RefreshIndicator(
            onRefresh: () async {
              _loadData();
            },
            child: Column(
              children: [
                // Filter Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _loadData();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppConstants.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Filter Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectYear,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(_selectedYear?.toString() ?? 'Year'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _selectedYear != null
                                    ? AppConstants.primaryColor
                                    : Colors.grey[600],
                                side: BorderSide(
                                  color: _selectedYear != null
                                      ? AppConstants.primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectMonth,
                              icon: const Icon(Icons.date_range),
                              label: Text(
                                _selectedMonth != null
                                    ? _getMonthName(_selectedMonth!)
                                    : 'Month',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _selectedMonth != null
                                    ? AppConstants.primaryColor
                                    : Colors.grey[600],
                                side: BorderSide(
                                  color: _selectedMonth != null
                                      ? AppConstants.primaryColor
                                      : Colors.grey[300]!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              final parts = value.split('_');
                              _changeSorting(parts[0], parts[1]);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'inflation_percentage_desc',
                                child: Text('Inflation ↑'),
                              ),
                              const PopupMenuItem(
                                value: 'inflation_percentage_asc',
                                child: Text('Inflation ↓'),
                              ),
                              const PopupMenuItem(
                                value: 'product_name_asc',
                                child: Text('Name A-Z'),
                              ),
                              const PopupMenuItem(
                                value: 'product_name_desc',
                                child: Text('Name Z-A'),
                              ),
                              const PopupMenuItem(
                                value: 'average_price_desc',
                                child: Text('Price ↑'),
                              ),
                              const PopupMenuItem(
                                value: 'average_price_asc',
                                child: Text('Price ↓'),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.sort,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Results Section
                if (state.error != null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading data',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (state.data.isEmpty && !state.isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_flat,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No inflation data found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your filters or search terms',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.data.length,
                      itemBuilder: (context, index) {
                        final item = state.data[index];
                        return _buildInflationCard(item);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInflationCard(MonthlyInflation item) {
    final inflationPercentage = item.inflationPercentage ?? 0.0;
    final previousMonthPrice = item.previousMonthPrice ?? item.averagePrice;
    final isPositive = inflationPercentage >= 0;
    final inflationColor = isPositive ? Colors.red : Colors.green;
    final inflationIcon = isPositive ? Icons.trending_up : Icons.trending_down;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.inflationPercentage != null
                      ? inflationColor.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.inflationPercentage != null
                          ? inflationIcon
                          : Icons.help_outline,
                      size: 16,
                      color: item.inflationPercentage != null
                          ? inflationColor
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.inflationPercentage != null
                          ? '${inflationPercentage.toStringAsFixed(2)}%'
                          : 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item.inflationPercentage != null
                            ? inflationColor
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Price',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '₺${item.averagePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Price',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      item.previousMonthPrice != null
                          ? '₺${previousMonthPrice.toStringAsFixed(2)}'
                          : 'N/A',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Purchases',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      '${item.purchaseCount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getMonthName(item.month)} ${item.year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Updated: ${_formatDate(item.lastUpdatedAt)}',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
