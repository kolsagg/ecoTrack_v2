import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../models/budget/budget_models.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/month_selector.dart';
import 'budget_setup_screen.dart';
import 'category_budget_screen.dart';

class BudgetOverviewScreen extends ConsumerStatefulWidget {
  const BudgetOverviewScreen({super.key});

  @override
  ConsumerState<BudgetOverviewScreen> createState() =>
      _BudgetOverviewScreenState();
}

class _BudgetOverviewScreenState extends ConsumerState<BudgetOverviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load budget summary and category budgets on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBudgetData();
    });
  }

  void _loadBudgetData() {
    ref.read(budgetSummaryProvider.notifier).loadBudgetSummary();
    ref.read(categoryBudgetsProvider.notifier).loadCategoryBudgets();
    ref.read(userBudgetProvider.notifier).loadUserBudget();
  }

  void _onDateChanged() {
    // Provider state'leri sıfırla (eski verileri temizle)
    ref.read(userBudgetProvider.notifier).reset();
    ref.read(budgetSummaryProvider.notifier).reset();
    ref.read(categoryBudgetsProvider.notifier).reset();

    // Yeni tarih için verileri yükle
    _loadBudgetData();
  }

  @override
  Widget build(BuildContext context) {
    final userBudgetState = ref.watch(userBudgetProvider);
    final budgetSummaryState = ref.watch(budgetSummaryProvider);
    final categoryBudgetsState = ref.watch(categoryBudgetsProvider);
    // selectedDateProvider'ı watch et - bu çok önemli!
    final selectedDateState = ref.watch(selectedDateProvider);
    final selectedDate = selectedDateState.selectedDate;

    // Get budget and loading state for current selected date
    final currentBudget = userBudgetState.budgetForDate(selectedDate);
    final isLoadingBudget = userBudgetState.isLoadingForDate(selectedDate);

    // Get summary and categories for current selected date
    final currentSummary = budgetSummaryState.summaryForDate(selectedDate);
    final isLoadingSummary = budgetSummaryState.isLoadingForDate(selectedDate);
    final summaryError = budgetSummaryState.errorForDate(selectedDate);

    final currentCategories = categoryBudgetsState.categoriesForDate(
      selectedDate,
    );
    final isLoadingCategories = categoryBudgetsState.isLoadingForDate(
      selectedDate,
    );

    return LoadingOverlay(
      isLoading: isLoadingBudget || isLoadingSummary || isLoadingCategories,
      loadingText: 'Loading budget overview...',
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Selector
              MonthSelector(
                onDateChanged: _onDateChanged,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),

              // Current Month Indicator
              const Align(
                alignment: Alignment.center,
                child: CurrentMonthIndicator(),
              ),

              const SizedBox(height: 16),

              // Budget Header Card
              _buildBudgetHeaderCard(currentBudget, selectedDate),
              const SizedBox(height: 16),

              // Budget Summary Card
              if (currentSummary != null)
                _buildBudgetSummaryCard(currentSummary),

              if (summaryError != null)
                _buildErrorCard('Budget Summary Error', summaryError),

              const SizedBox(height: 16),

              // Category Budgets Section
              _buildCategoryBudgetsSection(
                currentCategories,
                isLoadingCategories,
              ),

              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(selectedDate),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.wait([
      ref.read(userBudgetProvider.notifier).loadUserBudget(),
      ref.read(budgetSummaryProvider.notifier).loadBudgetSummary(),
      ref.read(categoryBudgetsProvider.notifier).loadCategoryBudgets(),
    ]);
  }

  Widget _buildBudgetHeaderCard(UserBudget? budget, DateTime selectedDate) {
    final monthName = [
      '',
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
    ][selectedDate.month];

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$monthName ${selectedDate.year} Budget',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      budget != null
                          ? 'Budget created for this month'
                          : 'No budget set for this month',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: budget != null
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                Icon(
                  budget != null ? Icons.check_circle : Icons.warning,
                  color: budget != null ? Colors.green : Colors.orange,
                  size: 40,
                ),
              ],
            ),

            if (budget != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBudgetInfo(
                      'Monthly Budget',
                      '₺${budget.totalMonthlyBudget.toStringAsFixed(2)}',
                      Icons.account_balance_wallet,
                      AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBudgetInfo(
                      'Currency',
                      budget.currency,
                      Icons.monetization_on,
                      Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBudgetInfo(
                      'Auto Allocation',
                      budget.autoAllocate ? 'Enabled' : 'Disabled',
                      budget.autoAllocate ? Icons.auto_awesome : Icons.settings,
                      budget.autoAllocate ? Colors.blue : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBudgetInfo(
                      'Created',
                      _formatDate(budget.createdAt),
                      Icons.calendar_today,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetInfo(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSummaryCard(BudgetSummaryResponse summary) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Progress indicators
            _buildProgressIndicator(
              'Allocation Progress',
              summary.allocationPercentage,
              summary.totalAllocated,
              summary.totalMonthlyBudget,
              Colors.blue,
            ),
            const SizedBox(height: 16),

            _buildProgressIndicator(
              'Spending Progress',
              summary.spendingPercentage,
              summary.totalSpent,
              summary.totalMonthlyBudget,
              Colors.orange,
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Summary stats
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Remaining Budget',
                    '₺${summary.remainingBudget.toStringAsFixed(2)}',
                    Icons.savings,
                    summary.remainingBudget >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Unallocated',
                    '₺${summary.unallocatedBudget.toStringAsFixed(2)}',
                    Icons.account_balance,
                    Colors.purple,
                  ),
                ),
              ],
            ),

            if (summary.categoriesOverBudget > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${summary.categoriesOverBudget} ${summary.categoriesOverBudget == 1 ? 'category is' : 'categories are'} over budget',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showOverBudgetCategories(),
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      tooltip: 'Show over budget categories',
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    String title,
    double percentage,
    double current,
    double total,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '₺${current.toStringAsFixed(2)} of ₺${total.toStringAsFixed(2)}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgetsSection(
    List<BudgetCategory> categories,
    bool isLoading,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Budgets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoryBudgetScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: 'Manage Categories',
                ),
              ],
            ),

            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (categories.isEmpty)
              _buildEmptyState()
            else
              _buildCategoriesList(categories),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Category Budgets',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add category budgets to track your spending',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryBudgetScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Category Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<BudgetCategory> categories) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ...categories.take(3).map((category) => _buildCategoryItem(category)),

        if (categories.length > 3) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryBudgetScreen(),
                ),
              );
            },
            child: Text('View All ${categories.length} Categories'),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryItem(BudgetCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category,
              color: AppConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.categoryName,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '₺${category.monthlyLimit.toStringAsFixed(2)} limit',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (category.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(DateTime selectedDate) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const BudgetSetupScreen(isEdit: false),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CategoryBudgetScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.category),
                    label: const Text('Categories'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Budget History Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Navigate to budget history screen
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BudgetHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('View Budget History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String title, String error) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(error, style: TextStyle(color: Colors.red[600])),
            const SizedBox(height: 8),
            TextButton(onPressed: _refreshData, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOverBudgetCategories() {
    final budgetSummaryState = ref.read(budgetSummaryProvider);
    final overBudgetCategories =
        budgetSummaryState.summary?.categorySummaries
            .where((category) => category.isOverBudget)
            .toList() ??
        [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Over Budget Categories'),
          ],
        ),
        content: overBudgetCategories.isEmpty
            ? const Text('No categories are currently over budget.')
            : SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'The following categories have exceeded their monthly budget:',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ...overBudgetCategories.map((category) {
                      final overAmount =
                          category.currentSpending - category.monthlyLimit;
                      final overPercentage =
                          (overAmount / category.monthlyLimit) * 100;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category.categoryName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '+${overPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Spent: ₺${category.currentSpending.toStringAsFixed(2)} / ₺${category.monthlyLimit.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Over by: ₺${overAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoryBudgetScreen(),
                ),
              );
            },
            child: const Text('Manage Categories'),
          ),
        ],
      ),
    );
  }
}

// Budget History Screen - Yeni ekran
class BudgetHistoryScreen extends ConsumerStatefulWidget {
  const BudgetHistoryScreen({super.key});

  @override
  ConsumerState<BudgetHistoryScreen> createState() =>
      _BudgetHistoryScreenState();
}

class _BudgetHistoryScreenState extends ConsumerState<BudgetHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetListProvider.notifier).loadBudgetList(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgetListState = ref.watch(budgetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget History'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: budgetListState.isLoading && budgetListState.budgets.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : budgetListState.budgets.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(budgetListProvider.notifier)
                    .loadBudgetList(refresh: true);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount:
                    budgetListState.budgets.length +
                    (budgetListState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == budgetListState.budgets.length) {
                    // Load more indicator
                    if (!budgetListState.isLoading) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(budgetListProvider.notifier).loadBudgetList();
                      });
                    }
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final budget = budgetListState.budgets[index];
                  return _buildBudgetHistoryItem(budget);
                },
              ),
            ),
    );
  }

  Widget _buildBudgetHistoryItem(UserBudget budget) {
    final monthNames = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = monthNames[budget.month];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                monthName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              Text(
                '${budget.year}',
                style: TextStyle(
                  fontSize: 10,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
        title: Text(
          '$monthName ${budget.year}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '₺${budget.totalMonthlyBudget.toStringAsFixed(2)} • ${budget.currency}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: budget.autoAllocate
                    ? Colors.blue[100]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                budget.autoAllocate ? 'Auto' : 'Manual',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: budget.autoAllocate
                      ? Colors.blue[700]
                      : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(budget.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
        onTap: () {
          // Navigate to this budget month
          final selectedDate = DateTime(budget.year, budget.month, 1);
          ref.read(selectedDateProvider.notifier).setSelectedDate(selectedDate);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Budget History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first budget to see it here',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
