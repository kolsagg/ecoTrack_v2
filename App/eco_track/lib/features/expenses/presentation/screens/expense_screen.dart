import 'package:eco_track/core/theme/app_theme.dart';
import 'package:eco_track/features/receipts/presentation/screens/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ExpenseScreen extends HookConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Month',
              style: AppTextStyles.headline2,
            ),
            const SizedBox(height: 16),
            // Toplam harcama kartı
            _buildTotalSpendingCard(),
            const SizedBox(height: 24),
            // Harcama grafiği kısmı
            _buildSpendingTrend(),
            const SizedBox(height: 24),
            // Kategoriler
            _buildCategories(),
            const SizedBox(height: 24),
            // Son işlemler
            _buildRecentTransactions(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButton: _buildAddExpenseButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTotalSpendingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Spending',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 8),
          const Text(
            '\$1,250',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingTrend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Spending Trend',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '\$1,250',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'This Month ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Text(
                    '+15%',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Column(
                    children: [
                      Container(
                        width: 32,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ['Jan', 'Feb', 'Mar', 'Apr', 'May'][index],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: 16),
        const Text(
          'Spending by Category',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 8),
        Text(
          '\$1,250',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Row(
          children: [
            Text(
              'This Month ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            Text(
              '+15%',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCategoryItem('Food', 0.3),
        const SizedBox(height: 12),
        _buildCategoryItem('Transportation', 0.8),
        const SizedBox(height: 12),
        _buildCategoryItem('Entertainment', 0.95),
        const SizedBox(height: 12),
        _buildCategoryItem('Utilities', 0.6),
        const SizedBox(height: 12),
        _buildCategoryItem('Other', 0.4),
      ],
    );
  }

  Widget _buildCategoryItem(String name, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(
              name == 'Food'
                  ? AppColors.primaryGreen
                  : name == 'Entertainment'
                      ? AppColors.warning
                      : AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: AppTextStyles.headline3,
        ),
        const SizedBox(height: 16),
        _buildTransactionItem(
          'Trader Joe\'s',
          'Grocery',
          -50,
          Icons.shopping_cart,
        ),
        const Divider(height: 1),
        _buildTransactionItem(
          'Shell',
          'Gas',
          -40,
          Icons.local_gas_station,
        ),
        const Divider(height: 1),
        _buildTransactionItem(
          'AMC Theatres',
          'Movie',
          -20,
          Icons.movie,
        ),
        const Divider(height: 1),
        _buildTransactionItem(
          'Con Edison',
          'Electricity',
          -100,
          Icons.lightbulb_outline,
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
      String title, String subtitle, int amount, IconData iconData) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                iconData,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$$amount',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'Spending',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Budget',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          // Ana sayfaya git
        } else if (index == 2) {
          // Bütçe sayfasına git
        } else if (index == 3) {
          // Profil sayfasına git
        }
      },
    );
  }

  Widget _buildAddExpenseButton() {
    return FloatingActionButton(
      onPressed: () {
        // Yeni harcama ekleme ekranına git
      },
      backgroundColor: AppColors.primaryBlue,
      child: const Icon(Icons.add),
    );
  }
} 