import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/reports_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _selectedPeriod = '3_months';

  // Donut chart için ayrı ay/yıl seçimi
  int _selectedDonutYear = DateTime.now().year;
  int _selectedDonutMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    // Load reports data on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  void _loadAllData() {
    ref
        .read(spendingTrendsProvider.notifier)
        .loadSpendingTrends(period: _selectedPeriod);
    ref
        .read(budgetVsActualProvider.notifier)
        .loadBudgetVsActual(year: _selectedYear, month: _selectedMonth);
    ref
        .read(categoryDistributionProvider.notifier)
        .loadCategoryDistribution(
          year: _selectedDonutYear,
          month: _selectedDonutMonth,
        );
  }

  Future<void> _selectMonth() async {
    final now = DateTime.now();
    final months = <Map<String, dynamic>>[];

    // Son 12 ayı oluştur (en yeniden en eskiye)
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add({
        'year': date.year,
        'month': date.month,
        'display': '${_getMonthName(date.month)} ${date.year}',
      });
    }

    final selectedMonth = await showDialog<Map<String, dynamic>>(
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
              final isSelected =
                  month['year'] == _selectedYear &&
                  month['month'] == _selectedMonth;

              return ListTile(
                title: Text(month['display']),
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
        ],
      ),
    );

    if (selectedMonth != null) {
      setState(() {
        _selectedYear = selectedMonth['year'];
        _selectedMonth = selectedMonth['month'];
      });
      ref
          .read(budgetVsActualProvider.notifier)
          .loadBudgetVsActual(year: _selectedYear, month: _selectedMonth);
    }
  }

  Future<void> _selectDonutMonth() async {
    final now = DateTime.now();
    final months = <Map<String, dynamic>>[];

    // Son 12 ayı oluştur (en yeniden en eskiye)
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add({
        'year': date.year,
        'month': date.month,
        'display': '${_getMonthName(date.month)} ${date.year}',
      });
    }

    final selectedMonth = await showDialog<Map<String, dynamic>>(
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
              final isSelected =
                  month['year'] == _selectedDonutYear &&
                  month['month'] == _selectedDonutMonth;

              return ListTile(
                title: Text(month['display']),
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
        ],
      ),
    );

    if (selectedMonth != null) {
      setState(() {
        _selectedDonutYear = selectedMonth['year'];
        _selectedDonutMonth = selectedMonth['month'];
      });
      ref
          .read(categoryDistributionProvider.notifier)
          .loadCategoryDistribution(
            year: _selectedDonutYear,
            month: _selectedDonutMonth,
          );
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
    final trendsState = ref.watch(spendingTrendsProvider);
    final budgetState = ref.watch(budgetVsActualProvider);
    final categoryState = ref.watch(categoryDistributionProvider);

    final isLoading =
        trendsState.isLoading ||
        budgetState.isLoading ||
        categoryState.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Reports'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: LoadingOverlay(
          isLoading: isLoading,
          loadingText: 'Reports are loading...',
          child: RefreshIndicator(
            onRefresh: () async {
              _loadAllData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Distribution Chart (Donut)
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

  Widget _buildCategoryDistributionChart(dynamic data) {
    if (data.data.isEmpty) {
      return _buildEmptyChart('Category Distribution');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.reportTitle ?? 'Category Distribution',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${_getMonthName(_selectedDonutMonth)} $_selectedDonutYear',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _selectDonutMonth,
                icon: const Icon(Icons.date_range),
                tooltip: 'Select Month',
                color: AppConstants.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 280,
            child: PieChart(
              PieChartData(
                sections: data.data.take(8).map<PieChartSectionData>((
                  category,
                ) {
                  final color = _parseColor(category.color);
                  return PieChartSectionData(
                    value: category.value,
                    title: '${category.percentage.toStringAsFixed(1)}%',
                    color: color,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Touch feedback can be added here if needed
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: data.data.take(8).map<Widget>((category) {
              final color = _parseColor(category.color);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Total amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppConstants.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expense:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  '₺${data.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetVsActualChart(dynamic data) {
    if (data.labels.isEmpty || data.datasets.isEmpty) {
      return _buildEmptyChart('Budget vs Actual');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.reportTitle ?? 'Budget vs Actual',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${_getMonthName(_selectedMonth)} $_selectedYear',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _selectMonth,
                icon: const Icon(Icons.date_range),
                tooltip: 'Select Month',
                color: AppConstants.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Legend
          _buildChartLegend(data.datasets),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxValue(data.datasets),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${data.labels[group.x.toInt()]}\n₺${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < data.labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 20, right: 26),
                            child: Transform.rotate(
                              angle: -0.785398, // -45 degrees in radians
                              child: Text(
                                data.labels[index],
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _getMaxValue(data.datasets) / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₺${_formatNumber(value)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
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
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxValue(data.datasets) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                  },
                ),
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
      return _buildEmptyChart('Spending Trends');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.reportTitle ?? 'Spending Trends',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${_getPeriodName(_selectedPeriod)} trend analysis',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: _changePeriod,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: '3_months',
                    child: Text('3 Months'),
                  ),
                  const PopupMenuItem(
                    value: '6_months',
                    child: Text('6 Months'),
                  ),
                  const PopupMenuItem(value: '1_year', child: Text('1 Year')),
                ],
                icon: const Icon(
                  Icons.timeline,
                  color: AppConstants.primaryColor,
                ),
                tooltip: 'Select Period',
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getLineChartMaxY(data) / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: _getLineChartMaxY(data) / 5,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₺${_formatNumber(value)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt().toString();
                        if (data.xAxisLabels.containsKey(index)) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              data.xAxisLabels[index],
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
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
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((touchedSpot) {
                        return LineTooltipItem(
                          '₺${touchedSpot.y.toStringAsFixed(0)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.datasets[0].data.map<FlSpot>((point) {
                      return FlSpot(point.x.toDouble(), point.y);
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: _parseColor(data.datasets[0].color),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: _parseColor(data.datasets[0].color),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          _parseColor(
                            data.datasets[0].color,
                          ).withValues(alpha: 0.3),
                          _parseColor(
                            data.datasets[0].color,
                          ).withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
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

  Widget _buildEmptyChart(String title) {
    final isDonutChart = title.contains('Category');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDonutChart ? Icons.pie_chart : Icons.bar_chart,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (isDonutChart)
                      Text(
                        '${_getMonthName(_selectedDonutMonth)} $_selectedDonutYear',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      )
                    else if (title.contains('Budget'))
                      Text(
                        '${_getMonthName(_selectedMonth)} $_selectedYear',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      )
                    else
                      Text(
                        '${_getPeriodName(_selectedPeriod)} trend analysis',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              if (isDonutChart)
                IconButton(
                  onPressed: _selectDonutMonth,
                  icon: const Icon(Icons.date_range),
                  tooltip: 'Select Month',
                  color: AppConstants.primaryColor,
                )
              else if (title.contains('Budget'))
                IconButton(
                  onPressed: _selectMonth,
                  icon: const Icon(Icons.date_range),
                  tooltip: 'Select Month',
                  color: AppConstants.primaryColor,
                )
              else
                PopupMenuButton<String>(
                  onSelected: _changePeriod,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: '3_months',
                      child: Text('3 Months'),
                    ),
                    const PopupMenuItem(
                      value: '6_months',
                      child: Text('6 Months'),
                    ),
                    const PopupMenuItem(value: '1_year', child: Text('1 Year')),
                  ],
                  icon: const Icon(
                    Icons.timeline,
                    color: AppConstants.primaryColor,
                  ),
                  tooltip: 'Select Period',
                ),
            ],
          ),
          const SizedBox(height: 30),
          Icon(
            isDonutChart ? Icons.pie_chart_outline : Icons.bar_chart,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 12),
          Text(
            'No data found',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildChartLegend(List<dynamic> datasets) {
    return Wrap(
      spacing: 16,
      children: datasets.map((dataset) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _parseColor(dataset.color),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              dataset.label ?? 'Data',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  double _getLineChartMaxY(dynamic data) {
    double max = 0;
    for (var point in data.datasets[0].data) {
      if (point.y > max) max = point.y.toDouble();
    }
    return max * 1.2;
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
              width: 5,
            ),
          );
        }
      }

      groups.add(BarChartGroupData(x: i, barRods: bars));
    }

    return groups;
  }
}
