import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/budget_provider.dart';
import '../../widgets/common/loading_overlay.dart';
import 'budget_setup_screen.dart';
import 'budget_overview_screen.dart';

class BudgetManagementScreen extends ConsumerStatefulWidget {
  const BudgetManagementScreen({super.key});

  @override
  ConsumerState<BudgetManagementScreen> createState() => _BudgetManagementScreenState();
}

class _BudgetManagementScreenState extends ConsumerState<BudgetManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load user budget on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userBudgetProvider.notifier).loadUserBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userBudgetState = ref.watch(userBudgetProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budget Management'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            if (userBudgetState.budget != null)
              IconButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BudgetSetupScreen(isEdit: true),
                    ),
                  );
                  // Budget güncellenirse state'i yenile
                  if (result == true) {
                    ref.read(userBudgetProvider.notifier).loadUserBudget();
                  }
                },
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Budget',
              ),
          ],
        ),
        body: LoadingOverlay(
          isLoading: userBudgetState.isLoading && userBudgetState.budget == null,
          loadingText: 'Loading budget...',
          child: _buildBody(userBudgetState),
        ),
      ),
    );
  }

  Widget _buildBody(UserBudgetState userBudgetState) {
    // Loading state
    if (userBudgetState.isLoading && userBudgetState.budget == null) {
      return const SizedBox.shrink(); // LoadingOverlay handles this
    }

    // Budget exists - show overview
    if (userBudgetState.budget != null) {
      return const BudgetOverviewScreen();
    }

    // No budget (either null or 404 error) - show create budget screen directly
    if (userBudgetState.budget == null) {
      // Clear any "not found" errors since we're handling this case
      if (userBudgetState.error != null && 
          (userBudgetState.error!.contains('404') || 
           userBudgetState.error!.toLowerCase().contains('not found') ||
           userBudgetState.error!.toLowerCase().contains('budget'))) {
        // Clear the error since we're showing the appropriate screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(userBudgetProvider.notifier).clearError();
        });
      }
      // Direkt budget setup ekranını göster
      return const BudgetSetupScreen(isEdit: false);
    }

    // Other errors - show error state
    if (userBudgetState.error != null) {
      return _buildErrorState(userBudgetState.error!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Budget',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(userBudgetProvider.notifier).loadUserBudget();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
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
} 