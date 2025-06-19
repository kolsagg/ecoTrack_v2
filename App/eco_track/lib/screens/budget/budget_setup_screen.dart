import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../models/budget/budget_models.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class BudgetSetupScreen extends ConsumerStatefulWidget {
  final bool isEdit;

  const BudgetSetupScreen({super.key, required this.isEdit});

  @override
  ConsumerState<BudgetSetupScreen> createState() => _BudgetSetupScreenState();
}

class _BudgetSetupScreenState extends ConsumerState<BudgetSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  String _selectedCurrency = 'TRY';
  bool _autoAllocate = true;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadExistingBudget();
    }
  }

  void _loadExistingBudget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budget = ref.read(userBudgetProvider).budget;
      if (budget != null) {
        setState(() {
          _budgetController.text = budget.totalMonthlyBudget.toString();
          _selectedCurrency = budget.currency;
          _autoAllocate = budget.autoAllocate;
        });
      }
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userBudgetState = ref.watch(userBudgetProvider);
    final categoryBudgetsState = ref.watch(categoryBudgetsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEdit ? 'Edit Budget' : 'Create Budget'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: LoadingOverlay(
          isLoading:
              userBudgetState.isLoading || categoryBudgetsState.isLoading,
          loadingText: categoryBudgetsState.isLoading
              ? 'Resetting budget...'
              : widget.isEdit
              ? 'Updating budget...'
              : 'Creating budget...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 32),
                  _buildBudgetAmountSection(),
                  const SizedBox(height: 24),
                  _buildCurrencySection(),
                  const SizedBox(height: 24),
                  _buildAutoAllocateSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  if (userBudgetState.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(userBudgetState.error!),
                  ],
                  if (categoryBudgetsState.error != null) ...[
                    const SizedBox(height: 16),
                    _buildErrorMessage(categoryBudgetsState.error!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppConstants.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppConstants.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(height: 12),
          Text(
            widget.isEdit ? 'Update Your Budget' : 'Set Up Your Budget',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isEdit
                ? 'Modify your monthly budget settings'
                : 'Create your monthly budget to start tracking expenses',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly Budget Amount',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter your monthly budget',
            prefixIcon: const Icon(Icons.attach_money),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a budget amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'This will be your total monthly spending limit',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildCurrencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Currency',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCurrency,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppConstants.primaryColor),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'TRY', child: Text('Turkish Lira (₺)')),
            DropdownMenuItem(value: 'USD', child: Text('US Dollar (\$)')),
            DropdownMenuItem(value: 'EUR', child: Text('Euro (€)')),
          ],
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCurrency = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildAutoAllocateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Auto-Allocate Budget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Automatically distribute your budget across categories based on recommended percentages',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _autoAllocate,
            onChanged: (value) {
              setState(() {
                _autoAllocate = value;
              });
            },
            title: Text(
              _autoAllocate ? 'Enabled' : 'Disabled',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _autoAllocate
                  ? 'Budget will be automatically allocated to categories'
                  : 'You will manually set category budgets',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            activeColor: AppConstants.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveBudget,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Text(widget.isEdit ? 'Update Budget' : 'Create Budget'),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.isEdit) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showResetBudgetDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Budget'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              side: const BorderSide(color: AppConstants.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _saveBudget() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.parse(_budgetController.text);

    if (widget.isEdit) {
      final request = UserBudgetUpdateRequest(
        totalMonthlyBudget: amount,
        currency: _selectedCurrency,
        autoAllocate: _autoAllocate,
      );
      ref
          .read(userBudgetProvider.notifier)
          .updateUserBudgetWithAutoAllocation(request, amount)
          .then((allocation) {
            if (mounted && ref.read(userBudgetProvider).error == null) {
              // Budget update başarılı
              if (_autoAllocate && allocation != null) {
                // Auto allocation da başarılı, category budgetları yeniden yükle
                ref
                    .read(categoryBudgetsProvider.notifier)
                    .loadCategoryBudgets()
                    .then((_) {
                      if (mounted) {
                        Navigator.of(context).pop(true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Budget updated and allocated successfully',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
              } else {
                // Auto allocation disabled
                Navigator.of(context).pop(true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Budget updated successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          })
          .catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating budget: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    } else {
      // Budget oluşturma
      if (_autoAllocate) {
        // Auto allocate enabled - apply allocation endpoint'ini çağır
        final allocationRequest = BudgetAllocationRequest(totalBudget: amount);
        ref
            .read(budgetAllocationProvider.notifier)
            .applyBudgetAllocation(allocationRequest)
            .then((_) {
              if (mounted && ref.read(budgetAllocationProvider).error == null) {
                // Allocation başarılı, budget'ı yeniden yükle
                ref.read(userBudgetProvider.notifier).loadUserBudget().then((
                  _,
                ) {
                  if (mounted) {
                    Navigator.of(context).pop(true); // true döndür
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Budget created and allocated successfully',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                });
              }
            });
      } else {
        // Normal budget creation
        final request = UserBudgetCreateRequest(
          totalMonthlyBudget: amount,
          currency: _selectedCurrency,
          autoAllocate: _autoAllocate,
        );
        ref.read(userBudgetProvider.notifier).createUserBudget(request).then((
          _,
        ) {
          if (mounted && ref.read(userBudgetProvider).error == null) {
            Navigator.of(context).pop(true); // true döndür
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Budget created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });
      }
    }
  }

  void _showResetBudgetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Reset Budget'),
            ],
          ),
          content: const Text(
            'Are you sure you want to reset your budget? This will delete all category budgets and cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetBudget();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _resetBudget() {
    ref.read(categoryBudgetsProvider.notifier).resetAllCategoryBudgets().then((
      _,
    ) {
      final categoryBudgetsState = ref.read(categoryBudgetsProvider);
      if (mounted && categoryBudgetsState.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget reset successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted && categoryBudgetsState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error resetting budget: ${categoryBudgetsState.error}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
