import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppConstants.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          title: const Text('EcoTrack'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textOnPrimaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppConstants.primaryColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco,
                            color: AppConstants.primaryColor,
                            size: AppConstants.iconSizeLarge,
                          ),
                          const SizedBox(width: AppConstants.spacingMedium),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, ${user?.firstName ?? 'User'}!',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  user?.email ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      Text(
                        'Start tracking your expenses and make a positive impact on the environment.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.spacingXLarge),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppConstants.textPrimaryColor,
                  fontWeight: AppConstants.fontWeightSemiBold,
                ),
              ),
              
              const SizedBox(height: AppConstants.spacingLarge),
              
              // Action Buttons Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.spacingMedium,
                mainAxisSpacing: AppConstants.spacingMedium,
                childAspectRatio: 1.2,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: 'Scan Receipt',
                    subtitle: 'Scan QR code',
                    onTap: () {
                      Navigator.of(context).pushNamed('/qr-scanner');
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.add_circle_outline,
                    title: 'Add Expense',
                    subtitle: 'Manual entry',
                    onTap: () {
                      Navigator.of(context).pushNamed('/add-expense');
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.receipt_long,
                    title: 'View Receipts',
                    subtitle: 'Browse receipts',
                    onTap: () {
                      Navigator.of(context).pushNamed('/receipts');
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Budget',
                    subtitle: 'Manage budget',
                    onTap: () {
                      // TODO: Navigate to budget
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Budget coming soon!')),
                      );
                    },
                  ),
                ],
              ),
              
              const Spacer(),
              
              // User Info Section
              if (user != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: AppConstants.fontWeightSemiBold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        _buildInfoRow('Email', user.email),
                        _buildInfoRow('Name', user.fullName),
                        if (user.createdAt != null)
                          _buildInfoRow('Member Since', 
                            '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacingLarge),
                
                // Logout Button
                CustomButton(
                  text: 'Logout',
                  onPressed: () async {
                    await ref.read(authStateProvider.notifier).logout();
                  },
                  isOutlined: true,
                  icon: Icons.logout,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMedium),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppConstants.iconSizeLarge,
                color: AppConstants.primaryColor,
              ),
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: AppConstants.fontWeightSemiBold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.spacingXSmall),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: AppConstants.fontWeightMedium,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 