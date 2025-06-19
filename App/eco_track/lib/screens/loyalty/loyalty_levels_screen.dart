import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../models/loyalty/loyalty_models.dart';
import '../../providers/loyalty_provider.dart';
import '../../widgets/common/loading_overlay.dart';

class LoyaltyLevelsScreen extends ConsumerStatefulWidget {
  const LoyaltyLevelsScreen({super.key});

  @override
  ConsumerState<LoyaltyLevelsScreen> createState() =>
      _LoyaltyLevelsScreenState();
}

class _LoyaltyLevelsScreenState extends ConsumerState<LoyaltyLevelsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    ref.read(loyaltyLevelsProvider.notifier).loadLoyaltyLevels();
  }

  @override
  Widget build(BuildContext context) {
    final levelsState = ref.watch(loyaltyLevelsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Loyalty Levels'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: levelsState.isLoading,
          loadingText: 'Loading levels...',
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: levelsState.levels != null
                ? _buildLevelsList(levelsState.levels!)
                : levelsState.error != null
                ? _buildErrorState(levelsState.error!)
                : _buildEmptyState(),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelsList(LoyaltyLevelsResponse levels) {
    final sortedLevels = levels.levels.entries.toList()
      ..sort(
        (a, b) => a.value.pointsRequired.compareTo(b.value.pointsRequired),
      );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          _buildHeaderInfo(),

          const SizedBox(height: 24),

          // Levels List
          ...sortedLevels.map(
            (entry) => _buildLevelCard(
              entry.key,
              entry.value,
              _getLevelColor(entry.key),
            ),
          ),

          const SizedBox(height: 24),

          // Category Bonuses
          if (levels.categoryBonuses.isNotEmpty)
            _buildCategoryBonuses(levels.categoryBonuses),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
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
                  'How Loyalty Levels Work',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Earn points with every purchase and unlock higher levels for better rewards. Each level offers increased point multipliers and exclusive benefits.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelCard(String levelKey, LoyaltyLevelInfo level, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getLevelIcon(levelKey), color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.pointsRequired == 0
                            ? 'Starting level'
                            : '${NumberFormat('#,###').format(level.pointsRequired)} points required',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '×${level.multiplier}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Benefits
            Text(
              'Benefits',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...level.benefits.map((benefit) => _buildBenefitItem(benefit)),

            const SizedBox(height: 16),

            // Multiplier Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Points Multiplier: ${level.multiplier}x',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(benefit, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBonuses(Map<String, String> categoryBonuses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category Bonuses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Earn extra points on specific categories:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            ...categoryBonuses.entries.map(
              (entry) => _buildCategoryBonusItem(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBonusItem(String category, String bonus) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 20,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                category.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bonus,
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
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
            Icon(Icons.workspace_premium, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Levels Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loyalty levels information is not available at the moment.',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Levels',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
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
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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

  Color _getLevelColor(String levelKey) {
    switch (levelKey.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFFE5E4E2);
      default:
        return AppConstants.primaryColor;
    }
  }

  IconData _getLevelIcon(String levelKey) {
    switch (levelKey.toLowerCase()) {
      case 'bronze':
        return Icons.looks_3;
      case 'silver':
        return Icons.looks_two;
      case 'gold':
        return Icons.looks_one;
      case 'platinum':
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'grocery':
        return Icons.shopping_cart;
      case 'fuel':
        return Icons.local_gas_station;
      case 'restaurant':
        return Icons.dining;
      default:
        return Icons.category;
    }
  }
}
