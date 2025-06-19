import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/loyalty_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class PointsCalculatorScreen extends ConsumerStatefulWidget {
  const PointsCalculatorScreen({super.key});

  @override
  ConsumerState<PointsCalculatorScreen> createState() =>
      _PointsCalculatorScreenState();
}

class _PointsCalculatorScreenState
    extends ConsumerState<PointsCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesProvider.notifier).loadCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _calculatePoints() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    ref
        .read(pointsCalculatorProvider.notifier)
        .calculatePoints(
          amount: amount,
          category: _selectedCategory,
          merchantName: _merchantController.text.trim().isEmpty
              ? null
              : _merchantController.text.trim(),
        );
  }

  void _clearCalculation() {
    ref.read(pointsCalculatorProvider.notifier).clearCalculation();
    _amountController.clear();
    _merchantController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final calculatorState = ref.watch(pointsCalculatorProvider);
    final categoriesState = ref.watch(categoriesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Points Calculator'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            if (calculatorState.calculation != null)
              IconButton(
                onPressed: _clearCalculation,
                icon: const Icon(Icons.clear),
                tooltip: 'Clear',
              ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: calculatorState.isLoading,
          loadingText: 'Calculating points...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  _buildInfoCard(),

                  const SizedBox(height: 24),

                  // Input Form
                  _buildInputForm(categoriesState),

                  const SizedBox(height: 24),

                  // Calculate Button
                  _buildCalculateButton(),

                  const SizedBox(height: 24),

                  // Results
                  if (calculatorState.calculation != null)
                    _buildResultsCard(calculatorState.calculation!)
                  else if (calculatorState.error != null)
                    _buildErrorCard(calculatorState.error!),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'How Points Work',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Base Rate', '1 point per ₺1 spent'),
            _buildInfoItem(
              'Category Bonus',
              'Extra points for specific categories',
            ),
            _buildInfoItem(
              'Level Multiplier',
              'Higher levels earn more points',
            ),
            _buildInfoItem('Total Points', 'Base + Bonus × Level Multiplier'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(AsyncValue categoriesState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Purchase Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: 'Amount (₺)',
                hintText: 'Enter purchase amount',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Category Dropdown
            categoriesState.when(
              data: (categories) => DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category (Optional)',
                  hintText: 'Select category for bonus points',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.name,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              loading: () => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category (Loading...)',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: const [],
                onChanged: null,
              ),
              error: (_, __) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Category (Error loading)',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: const [],
                onChanged: null,
              ),
            ),

            const SizedBox(height: 16),

            // Merchant Field
            TextFormField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant (Optional)',
                hintText: 'Enter merchant name',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _calculatePoints,
        icon: const Icon(Icons.calculate),
        label: const Text(
          'Calculate Points',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(calculation) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor.withValues(alpha: 0.1),
              AppConstants.primaryColor.withValues(alpha: 0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: AppConstants.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Points Calculation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Total Points (Prominent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Points Earned',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat('#,###').format(calculation.totalPoints),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'points',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Breakdown
            Text(
              'Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildBreakdownItem(
              'Base Points',
              '${NumberFormat('#,###').format(calculation.basePoints)} pts',
              'Rate: ${(calculation.calculationDetails.baseRate * 100).toStringAsFixed(1)}%',
            ),

            if (calculation.bonusPoints > 0)
              _buildBreakdownItem(
                'Bonus Points',
                '${NumberFormat('#,###').format(calculation.bonusPoints)} pts',
                calculation.calculationDetails.categoryBonus != null
                    ? 'Category bonus: ${(calculation.calculationDetails.categoryBonus! * 100).toStringAsFixed(1)}%'
                    : 'Special bonus applied',
              ),

            _buildBreakdownItem(
              'Level Multiplier',
              '×${calculation.calculationDetails.levelMultiplier}',
              'Your current level bonus',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownItem(String title, String value, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(
              'Calculation Error',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _calculatePoints,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
