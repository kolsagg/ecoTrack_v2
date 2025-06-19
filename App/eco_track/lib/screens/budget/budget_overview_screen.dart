import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/common/loading_overlay.dart';
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
      ref.read(budgetSummaryProvider.notifier).loadBudgetSummary();
      ref.read(categoryBudgetsProvider.notifier).loadCategoryBudgets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userBudgetState = ref.watch(userBudgetProvider);
    final budgetSummaryState = ref.watch(budgetSummaryProvider);
    final categoryBudgetsState = ref.watch(categoryBudgetsProvider);

    return LoadingOverlay(
      isLoading: budgetSummaryState.isLoading || categoryBudgetsState.isLoading,
      loadingText: 'Loading budget overview...',
      child: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Budget Header Card
              _buildBudgetHeaderCard(userBudgetState.budget),
              const SizedBox(height: 16),

              // Budget Summary Card
              if (budgetSummaryState.summary != null)
                _buildBudgetSummaryCard(budgetSummaryState.summary!),

              if (budgetSummaryState.error != null)
                _buildErrorCard(
                  'Budget Summary Error',
                  budgetSummaryState.error!,
                ),

              const SizedBox(height: 16),

              // Category Budgets Section
              _buildCategoryBudgetsSection(categoryBudgetsState),

              const SizedBox(height: 16),

              // Action Buttons
              _buildActionButtons(),

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

  Widget _buildBudgetHeaderCard(userBudget) {
    if (userBudget == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet,
                    color: AppConstants.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${userBudget.totalMonthlyBudget.toStringAsFixed(2)} ${userBudget.currency}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.primaryColor,
                            ),
                      ),
                    ],
                  ),
                ),
                if (userBudget.autoAllocate)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Auto',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetSummaryCard(summary) {
    final spendingPercentage = summary.spendingPercentage.clamp(0.0, 100.0);
    final allocationPercentage = summary.allocationPercentage.clamp(0.0, 100.0);

    Color getSpendingColor() {
      if (spendingPercentage >= 90) return Colors.red;
      if (spendingPercentage >= 75) return Colors.orange;
      return Colors.green;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Summary',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Spending Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Spending',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${spendingPercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: getSpendingColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: spendingPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(getSpendingColor()),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Spent: ₺${summary.totalSpent.toStringAsFixed(2)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      'Remaining: ₺${summary.remainingBudget.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: summary.remainingBudget < 0
                            ? Colors.red[600]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Allocation Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Allocation',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${allocationPercentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: allocationPercentage / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppConstants.primaryColor,
                  ),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Allocated: ₺${summary.totalAllocated.toStringAsFixed(2)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    Text(
                      'Unallocated: ₺${summary.unallocatedBudget.toStringAsFixed(2)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            // Over Budget Warning
            if (summary.categoriesOverBudget > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${summary.categoriesOverBudget} ${summary.categoriesOverBudget == 1 ? 'category is' : 'categories are'} over budget',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  Widget _buildCategoryBudgetsSection(categoryBudgetsState) {
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CategoryBudgetScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (categoryBudgetsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (categoryBudgetsState.error != null)
              _buildErrorCard(
                'Category Budgets Error',
                categoryBudgetsState.error!,
              )
            else if (categoryBudgetsState.categories.isEmpty)
              _buildEmptyCategoriesState()
            else
              _buildCategoriesList(categoryBudgetsState.categories),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategoriesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Category Budgets',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Set up category budgets to track spending by category',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(categories) {
    return SizedBox(
      height: 300, // Fixed height to make it scrollable
      child: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: category.isActive ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.categoryName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${category.monthlyLimit.toStringAsFixed(2)} limit',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!category.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Inactive',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const BudgetSetupScreen(isEdit: true),
                    ),
                  );
                  if (result == true) {
                    _refreshData();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Budget'),
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
                  side: BorderSide(color: AppConstants.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
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
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
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
            Text(error, style: TextStyle(color: Colors.red[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
