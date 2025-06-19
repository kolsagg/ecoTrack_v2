import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _selectedPeriod = '3_months';

  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _loadAllData() {
    ref
        .read(categoryDistributionProvider.notifier)
        .loadCategoryDistribution(year: _selectedYear, month: _selectedMonth);
    ref
        .read(spendingTrendsProvider.notifier)
        .loadSpendingTrends(period: _selectedPeriod);
    ref
        .read(budgetVsActualProvider.notifier)
        .loadBudgetVsActual(year: _selectedYear, month: _selectedMonth);
  }

  Future<void> _selectMonth() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, _selectedMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (selectedDate != null) {
      setState(() {
        _selectedYear = selectedDate.year;
        _selectedMonth = selectedDate.month;
      });
      _loadAllData();
    }
  }

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    ref
        .read(spendingTrendsProvider.notifier)
        .loadSpendingTrends(period: period);
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryDistributionProvider);
    final trendsState = ref.watch(spendingTrendsProvider);
    final budgetState = ref.watch(budgetVsActualProvider);

    final isLoading =
        categoryState.isLoading ||
        trendsState.isLoading ||
        budgetState.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('EcoTrack'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _selectMonth,
              icon: const Icon(Icons.date_range),
              tooltip: 'Select Month/Year',
            ),
            PopupMenuButton<String>(
              onSelected: _changePeriod,
              itemBuilder: (context) => [
                const PopupMenuItem(value: '3_months', child: Text('3 Months')),
                const PopupMenuItem(value: '6_months', child: Text('6 Months')),
                const PopupMenuItem(value: '1_year', child: Text('1 Year')),
              ],
              icon: const Icon(Icons.timeline),
              tooltip: 'Select Period',
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: isLoading && categoryState.data == null,
          loadingText: 'Loading dashboard...',
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAllData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Period Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppConstants.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_getMonthName(_selectedMonth)} $_selectedYear',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Trends: ${_getPeriodName(_selectedPeriod)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Summary Cards from Category Distribution
                  if (categoryState.data != null)
                    _buildSummaryCards(categoryState.data!),

                  const SizedBox(height: 24),

                  // Category Distribution Chart
                  if (categoryState.data != null)
                    _buildCategoryDistributionChart(categoryState.data!),

                  const SizedBox(height: 24),

                  // Budget vs Actual Chart
                  if (budgetState.data != null)
                    _buildBudgetVsActualChart(budgetState.data!),

                  const SizedBox(height: 24),

                  // Spending Trends Chart
                  if (trendsState.data != null)
                    _buildSpendingTrendsChart(trendsState.data!),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

  String _getPeriodName(String period) {
    switch (period) {
      case '3_months':
        return '3 Months';
      case '6_months':
        return '6 Months';
      case '1_year':
        return '1 Year';
      default:
        return period;
    }
  }

  Widget _buildSummaryCards(dynamic categoryData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Expenses',
                '₺${categoryData.totalAmount.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Categories',
                '${categoryData.data.length}',
                Icons.category,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
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
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCategoryDistributionChart(dynamic data) {
    if (data.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.reportTitle ?? 'Spending by Category',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: data.data.take(6).map<PieChartSectionData>((
                  category,
                ) {
                  final color = _parseColor(category.color);
                  return PieChartSectionData(
                    value: category.value,
                    title: '${category.percentage.toStringAsFixed(1)}%',
                    color: color,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: data.data.take(6).map<Widget>((category) {
              final color = _parseColor(category.color);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(category.label, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetVsActualChart(dynamic data) {
    if (data.labels.isEmpty || data.datasets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.reportTitle ?? 'Budget vs Actual',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(data.datasets),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.labels.length) {
                          return Text(
                            data.labels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₺${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(data),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrendsChart(dynamic data) {
    if (data.datasets.isEmpty || data.datasets[0].data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.reportTitle ?? 'Spending Trends',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₺${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt().toString();
                        if (data.xAxisLabels.containsKey(index)) {
                          return Text(
                            data.xAxisLabels[index],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.datasets[0].data.map<FlSpot>((point) {
                      return FlSpot(point.x.toDouble(), point.y);
                    }).toList(),
                    isCurved: true,
                    color: _parseColor(data.datasets[0].color),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _parseColor(
                        data.datasets[0].color,
                      ).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'View Expenses',
                  Icons.receipt_long,
                  () => Navigator.of(context).pushNamed('/expenses'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Add Expense',
                  Icons.add,
                  () => Navigator.of(context).pushNamed('/add-expense'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Scan Receipt',
                  Icons.qr_code_scanner,
                  () => Navigator.of(context).pushNamed('/scan-receipt'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Export Data',
                  Icons.download,
                  () => Navigator.of(context).pushNamed('/export'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppConstants.primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '');
      // Add FF for alpha if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Fallback to a default color
      return AppConstants.primaryColor;
    }
  }

  double _getMaxValue(List<dynamic> datasets) {
    double max = 0;
    for (var dataset in datasets) {
      for (var value in dataset.data) {
        if (value > max) max = value.toDouble();
      }
    }
    return max * 1.2; // Add 20% padding
  }

  List<BarChartGroupData> _buildBarGroups(dynamic data) {
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < data.labels.length; i++) {
      final bars = <BarChartRodData>[];

      for (int j = 0; j < data.datasets.length; j++) {
        if (i < data.datasets[j].data.length) {
          bars.add(
            BarChartRodData(
              toY: data.datasets[j].data[i].toDouble(),
              color: _parseColor(data.datasets[j].color),
              width: 16,
            ),
          );
        }
      }

      groups.add(BarChartGroupData(x: i, barRods: bars));
    }

    return groups;
  }
}
