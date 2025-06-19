import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../models/budget/budget_models.dart';
import '../../providers/budget_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class CategoryBudgetScreen extends ConsumerStatefulWidget {
  const CategoryBudgetScreen({super.key});

  @override
  ConsumerState<CategoryBudgetScreen> createState() =>
      _CategoryBudgetScreenState();
}

class _CategoryBudgetScreenState extends ConsumerState<CategoryBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  String? _selectedCategoryId;
  bool _isEditing = false;
  String? _editingCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(categoryBudgetsProvider.notifier).loadCategoryBudgets();
    ref.read(categoriesProvider.notifier).loadCategories();
    ref.read(budgetSummaryProvider.notifier).loadBudgetSummary();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _showAddBudgetDialog() {
    _resetForm();
    _showBudgetDialog();
  }

  void _showEditBudgetDialog(BudgetCategory budgetCategory) {
    _resetForm();
    _isEditing = true;
    _editingCategoryId = budgetCategory.categoryId;
    _selectedCategoryId = budgetCategory.categoryId;
    _budgetController.text = budgetCategory.monthlyLimit.toString();
    _showBudgetDialog();
  }

  void _resetForm() {
    _isEditing = false;
    _editingCategoryId = null;
    _selectedCategoryId = null;
    _budgetController.clear();
  }

  void _showBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditing ? 'Edit Budget' : 'Add Category Budget'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Dropdown
              Consumer(
                builder: (context, ref, child) {
                  final categoriesAsync = ref.watch(categoriesProvider);

                  return categoriesAsync.when(
                    data: (categories) {
                      // Filter out categories that already have budgets (except when editing)
                      final budgetCategories = ref
                          .watch(categoryBudgetsProvider)
                          .categories;
                      final availableCategories = categories.where((category) {
                        if (_isEditing && category.id == _selectedCategoryId) {
                          return true; // Include current category when editing
                        }
                        return !budgetCategories.any(
                          (bc) => bc.categoryId == category.id,
                        );
                      }).toList();

                      if (availableCategories.isEmpty && !_isEditing) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'All categories already have budgets. Use category management to add new categories.',
                                  style: TextStyle(color: Colors.orange[600]),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Select Category',
                          border: OutlineInputBorder(),
                        ),
                        items: availableCategories.map((category) {
                          return DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: _isEditing
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (error, _) =>
                        Text('Failed to load categories: $error'),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Budget Amount Input
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Budget Limit',
                  border: OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter budget amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(categoriesProvider);
              final budgetCategories = ref
                  .watch(categoryBudgetsProvider)
                  .categories;

              return categoriesAsync.when(
                data: (categories) {
                  final availableCategories = categories.where((category) {
                    if (_isEditing && category.id == _selectedCategoryId) {
                      return true;
                    }
                    return !budgetCategories.any(
                      (bc) => bc.categoryId == category.id,
                    );
                  }).toList();

                  final isButtonEnabled =
                      _isEditing || availableCategories.isNotEmpty;

                  return ElevatedButton(
                    onPressed: isButtonEnabled ? _saveBudget : null,
                    child: Text(_isEditing ? 'Update' : 'Save'),
                  );
                },
                loading: () => ElevatedButton(
                  onPressed: null,
                  child: Text(_isEditing ? 'Update' : 'Save'),
                ),
                error: (_, __) => ElevatedButton(
                  onPressed: null,
                  child: Text(_isEditing ? 'Update' : 'Save'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_budgetController.text);

    try {
      if (_isEditing) {
        // For editing, we need to delete the old one and create a new one
        // since the API doesn't have an update endpoint for category budgets
        await ref
            .read(categoryBudgetsProvider.notifier)
            .deleteCategoryBudget(_editingCategoryId!);
      }

      final request = BudgetCategoryCreateRequest(
        categoryId: _selectedCategoryId!,
        monthlyLimit: amount,
        isActive: true,
      );

      await ref
          .read(categoryBudgetsProvider.notifier)
          .createCategoryBudget(request);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Budget updated' : 'Budget added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _deleteBudget(String categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete the budget for $categoryName category?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await ref
                    .read(categoryBudgetsProvider.notifier)
                    .deleteCategoryBudget(categoryId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Budget deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetCategory budgetCategory) {
    // Get real spending data from budget summary
    final budgetSummaryState = ref.watch(budgetSummaryProvider);
    double currentSpending = 0.0;
    double usagePercentage = 0.0;
    bool isOverBudget = false;

    if (budgetSummaryState.summary != null) {
      // Category name ile eşleştirme yap (çünkü category distribution category name döndürüyor)
      final categorySummary = budgetSummaryState.summary!.categorySummaries
          .firstWhere(
            (summary) => summary.categoryName == budgetCategory.categoryName,
            orElse: () => const BudgetSummaryItem(),
          );

      if (categorySummary.categoryId.isNotEmpty) {
        currentSpending = categorySummary.currentSpending;
        usagePercentage = categorySummary.usagePercentage;
        isOverBudget = categorySummary.isOverBudget;
      }
    }

    final remainingBudget = budgetCategory.monthlyLimit - currentSpending;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    budgetCategory.categoryName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditBudgetDialog(budgetCategory),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteBudget(
                        budgetCategory.categoryId,
                        budgetCategory.categoryName,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget Limit',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '₺${budgetCategory.monthlyLimit.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '₺${currentSpending.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget ? Colors.red[600] : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                Text(
                  '₺${remainingBudget.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: remainingBudget < 0
                        ? Colors.red[600]
                        : Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            LinearProgressIndicator(
              value: (usagePercentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget || usagePercentage > 100
                    ? Colors.red
                    : usagePercentage > 80
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${usagePercentage.toStringAsFixed(1)}% used',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Row(
              children: [
                if (!budgetCategory.isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Inactive',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                if (isOverBudget)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 12, color: Colors.red[700]),
                        const SizedBox(width: 4),
                        Text(
                          'Over Budget',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final categoryBudgetsState = ref.watch(categoryBudgetsProvider);
    final budgetSummaryState = ref.watch(budgetSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category Budgets'),
        elevation: 0,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final categoriesAsync = ref.watch(categoriesProvider);
              final budgetCategories = ref
                  .watch(categoryBudgetsProvider)
                  .categories;

              return categoriesAsync.when(
                data: (categories) {
                  final availableCategories = categories.where((category) {
                    return !budgetCategories.any(
                      (bc) => bc.categoryId == category.id,
                    );
                  }).toList();

                  final hasAvailableCategories = availableCategories.isNotEmpty;

                  return IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: hasAvailableCategories
                        ? _showAddBudgetDialog
                        : null,
                    tooltip: 'Add Budget',
                  );
                },
                loading: () => IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: null,
                  tooltip: 'Add Budget',
                ),
                error: (_, __) => IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddBudgetDialog,
                  tooltip: 'Add Budget',
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading:
            categoryBudgetsState.isLoading || budgetSummaryState.isLoading,
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: Column(
            children: [
              // Summary Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor,
                      AppConstants.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category Budget Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Budgets defined for ${categoryBudgetsState.categories.length} categories',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    if (budgetSummaryState.summary != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Total Spending: ₺${budgetSummaryState.summary!.totalSpent.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Over Budget Categories: ${budgetSummaryState.summary!.categoriesOverBudget}',
                        style: TextStyle(
                          color:
                              budgetSummaryState.summary!.categoriesOverBudget >
                                  0
                              ? Colors.red[200]
                              : Colors.white70,
                          fontSize: 14,
                          fontWeight:
                              budgetSummaryState.summary!.categoriesOverBudget >
                                  0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Error Messages
              if (categoryBudgetsState.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Failed to load category budgets: ${categoryBudgetsState.error}',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              if (budgetSummaryState.error != null)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_outlined, color: Colors.orange[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Failed to load spending data: ${budgetSummaryState.error}',
                          style: TextStyle(color: Colors.orange[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              // Budget List
              Expanded(
                child: categoryBudgetsState.categories.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No category budgets defined yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Set budget limits for your categories',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: categoryBudgetsState.categories.length,
                        itemBuilder: (context, index) {
                          final budgetCategory =
                              categoryBudgetsState.categories[index];
                          return _buildBudgetCard(budgetCategory);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
