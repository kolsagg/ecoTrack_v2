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
  ConsumerState<BudgetManagementScreen> createState() =>
      _BudgetManagementScreenState();
}

class _BudgetManagementScreenState
    extends ConsumerState<BudgetManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load user budget on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 BudgetManagementScreen: Initializing for current month');
      // Her zaman current month'a set et
      ref.read(selectedDateProvider.notifier).goToCurrentMonth();
      // Current month için budget'ı yükle
      ref.read(userBudgetProvider.notifier).loadUserBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userBudgetState = ref.watch(userBudgetProvider);
    final selectedDate = ref.watch(selectedDateProvider).selectedDate;
    final currentBudget = userBudgetState.budgetForDate(selectedDate);
    final isLoadingBudget = userBudgetState.isLoadingForDate(selectedDate);

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
            if (currentBudget != null)
              IconButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const BudgetSetupScreen(isEdit: true),
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
          isLoading: isLoadingBudget && currentBudget == null,
          loadingText: 'Loading budget...',
          child: _buildBody(userBudgetState),
        ),
      ),
    );
  }

  Widget _buildBody(UserBudgetState userBudgetState) {
    final selectedDate = ref.watch(selectedDateProvider).selectedDate;
    final now = DateTime.now();
    final isCurrentMonth =
        selectedDate.year == now.year && selectedDate.month == now.month;

    final currentBudget = userBudgetState.budgetForDate(selectedDate);
    final currentError = userBudgetState.errorForDate(selectedDate);
    final isLoadingBudget = userBudgetState.isLoadingForDate(selectedDate);

    // Yükleniyor durumunda overlay gösterilecek
    if (isLoadingBudget && currentBudget == null) {
      return const SizedBox.shrink();
    }

    // Herhangi bir ay için bütçe varsa, her zaman overview'ı göster.
    if (currentBudget != null) {
      return const BudgetOverviewScreen();
    }

    // Bütçe null ise ne göstereceğimize karar verelim.
    if (currentBudget == null) {
      // Eğer seçili ay, içinde bulunduğumuz ay ise, bütçe yok demektir.
      // Bu durumda budget setup ekranını göster.
      if (isCurrentMonth) {
        // "Not found" hatasını temizleyelim çünkü doğru ekrana yönlendiriyoruz.
        if (currentError != null &&
            (currentError.contains('404') ||
                currentError.toLowerCase().contains('not found'))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(userBudgetProvider.notifier).clearError();
          });
        }
        return const BudgetSetupScreen(isEdit: false);
      } else {
        // Eğer farklı bir ay seçildiyse ve bütçe yoksa, overview ekranında kal.
        // Overview ekranı kendi içinde "bütçe yok" mesajını gösterecektir.
        return const BudgetOverviewScreen();
      }
    }

    // Diğer hataları (örn: 500 sunucu hatası) göster.
    if (currentError != null) {
      return _buildErrorState(currentError);
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
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
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
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
