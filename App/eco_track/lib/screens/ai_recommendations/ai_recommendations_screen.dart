import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/ai_recommendations_provider.dart';
import '../../data/models/ai_recommendations_models.dart';

class AiRecommendationsScreen extends ConsumerStatefulWidget {
  const AiRecommendationsScreen({super.key});

  @override
  ConsumerState<AiRecommendationsScreen> createState() =>
      _AiRecommendationsScreenState();
}

class _AiRecommendationsScreenState
    extends ConsumerState<AiRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    // Provider'ın build metodu artık ilk yüklemeyi yapıyor
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsStateAsync = ref.watch(aiRecommendationsProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'AI Suggestions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: () {
                HapticFeedback.lightImpact();
                final currentState = ref
                    .read(aiRecommendationsProvider)
                    .valueOrNull;
                if (currentState != null) {
                  ref
                      .read(aiRecommendationsProvider.notifier)
                      .loadDataForCategory(currentState.selectedCategory);
                }
              },
            ),
          ],
        ),
        body: recommendationsStateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
          data: (state) {
            return Column(
              children: [
                _buildSegmentedControl(state.selectedCategory),
                Expanded(child: _buildContentForCategory(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSegmentedControl(RecommendationCategory selectedCategory) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SegmentedButton<RecommendationCategory>(
        segments: const <ButtonSegment<RecommendationCategory>>[
          ButtonSegment(
            value: RecommendationCategory.waste,
            label: Text(
              'Waste',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            icon: Icon(Icons.warning_amber, size: 16),
          ),
          ButtonSegment(
            value: RecommendationCategory.anomaly,
            label: Text(
              'Anomaly',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            icon: Icon(Icons.trending_up, size: 16),
          ),
          ButtonSegment(
            value: RecommendationCategory.pattern,
            label: Text(
              'Habit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            icon: Icon(Icons.insights, size: 16),
          ),
        ],
        selected: {selectedCategory},
        onSelectionChanged: (Set<RecommendationCategory> newSelection) {
          ref
              .read(aiRecommendationsProvider.notifier)
              .changeCategory(newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[700],
          selectedBackgroundColor: AppConstants.primaryColor,
          selectedForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildContentForCategory(RecommendationsState state) {
    switch (state.selectedCategory) {
      case RecommendationCategory.waste:
        if (state.isLoadingWastePrevention) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return _buildErrorStateForCategory(
            state.errorMessage ?? 'An error occurred',
          );
        }
        if (state.wastePreventionAlerts.isEmpty) {
          return _buildEmptyStateForCategory('Waste alert not found.');
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(aiRecommendationsProvider.notifier)
                .loadWastePreventionAlerts();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: state.wastePreventionAlerts
                .map((alert) => _buildWastePreventionCard(alert))
                .toList(),
          ),
        );
      case RecommendationCategory.anomaly:
        if (state.isLoadingAnomalies) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return _buildErrorStateForCategory(
            state.errorMessage ?? 'An error occurred',
          );
        }
        if (state.anomalyAlerts.isEmpty) {
          return _buildEmptyStateForCategory('Anomaly alert not found.');
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(aiRecommendationsProvider.notifier)
                .loadAnomalyAlerts();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: state.anomalyAlerts
                .map((alert) => _buildAnomalyCard(alert))
                .toList(),
          ),
        );
      case RecommendationCategory.pattern:
        if (state.isLoadingPatterns) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.hasError) {
          return _buildErrorStateForCategory(
            state.errorMessage ?? 'An error occurred',
          );
        }
        if (state.patternInsights.isEmpty) {
          return _buildEmptyStateForCategory(
            'Spending habit analysis not found.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await ref
                .read(aiRecommendationsProvider.notifier)
                .loadPatternInsights();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: state.patternInsights
                .map((insight) => _buildPatternCard(insight))
                .toList(),
          ),
        );
    }
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final currentState = ref
                    .read(aiRecommendationsProvider)
                    .valueOrNull;
                if (currentState != null) {
                  ref
                      .read(aiRecommendationsProvider.notifier)
                      .loadDataForCategory(currentState.selectedCategory);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorStateForCategory(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'An error occurred',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final currentState = ref
                    .read(aiRecommendationsProvider)
                    .valueOrNull;
                if (currentState != null) {
                  ref
                      .read(aiRecommendationsProvider.notifier)
                      .loadDataForCategory(currentState.selectedCategory);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateForCategory(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWastePreventionCard(WastePreventionAlert alert) {
    Color getRiskColor(String riskLevel) {
      switch (riskLevel.toLowerCase()) {
        case 'high':
          return Colors.red;
        case 'medium':
          return Colors.orange;
        case 'low':
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    String getRiskText(String riskLevel) {
      switch (riskLevel.toLowerCase()) {
        case 'high':
          return 'High Risk';
        case 'medium':
          return 'Medium Risk';
        case 'low':
          return 'Low Risk';
        default:
          return riskLevel;
      }
    }

    final riskColor = getRiskColor(alert.riskLevel);
    final purchaseDate = DateFormat('dd.MM.yyyy').format(alert.purchaseDate);
    final expirationDateTime = alert.purchaseDate.add(
      Duration(days: alert.estimatedShelfLifeDays),
    );
    final expirationDate = DateFormat('dd.MM.yyyy').format(expirationDateTime);
    final remainingDays = expirationDateTime.difference(DateTime.now()).inDays;

    String processedMessage = alert.alertMessage;
    final pattern = "'${alert.productName}': ";
    if (processedMessage.startsWith(pattern)) {
      processedMessage = processedMessage.substring(pattern.length);
    }

    String getRemainingDaysText() {
      if (remainingDays < 0) {
        return 'Expired';
      }
      if (remainingDays == 0) {
        return 'Expires Today';
      }
      if (remainingDays == 1) {
        return '1 day left';
      }
      return '$remainingDays days left';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: riskColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alert.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getRiskText(alert.riskLevel),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: riskColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            processedMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, color: riskColor, size: 22),
              const SizedBox(width: 8),
              Text(
                getRemainingDaysText(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: riskColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo(
                icon: Icons.calendar_today,
                label: 'Purchase',
                date: purchaseDate,
              ),
              _buildDateInfo(
                icon: Icons.event_busy,
                label: 'Expires',
                date: expirationDate,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required String date,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: $date',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAnomalyCard(CategoryAnomalyAlert alert) {
    Color getSeverityColor(String severity) {
      switch (severity.toLowerCase()) {
        case 'severe':
          return Colors.red;
        case 'moderate':
          return Colors.orange;
        case 'mild':
          return Colors.yellow[700]!;
        default:
          return Colors.grey;
      }
    }

    String getSeverityText(String severity) {
      switch (severity.toLowerCase()) {
        case 'severe':
          return 'Severe';
        case 'moderate':
          return 'Moderate';
        case 'mild':
          return 'Mild';
        default:
          return severity;
      }
    }

    final severityColor = getSeverityColor(alert.severity);
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: severityColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alert.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getSeverityText(alert.severity),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.alertMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Month',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      formatter.format(alert.currentMonthSpending),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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
                      'Average',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      formatter.format(alert.averageSpending),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+%${alert.anomalyPercentage.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          if (alert.suggestedAction.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.suggestedAction,
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatternCard(SpendingPatternInsight insight) {
    Color getPatternColor(String patternType) {
      switch (patternType.toLowerCase()) {
        case 'seasonal':
          return Colors.green;
        case 'weekly':
          return Colors.blue;
        case 'monthly':
          return Colors.purple;
        case 'recurring':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    String getPatternText(String patternType) {
      switch (patternType.toLowerCase()) {
        case 'seasonal':
          return 'Seasonal';
        case 'weekly':
          return 'Weekly';
        case 'monthly':
          return 'Monthly';
        case 'recurring':
          return 'Recurring';
        default:
          return patternType;
      }
    }

    final patternColor = getPatternColor(insight.patternType);
    final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: patternColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: patternColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getPatternText(insight.patternType),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: patternColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.insightMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.recommend, size: 16, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Suggestion',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  insight.recommendation,
                  style: TextStyle(fontSize: 12, color: Colors.green[700]),
                ),
                if (insight.potentialSavings != null &&
                    insight.potentialSavings! > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.savings, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Potential savings: ${formatter.format(insight.potentialSavings)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
