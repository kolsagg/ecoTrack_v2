import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/profile_stats_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile stats on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileStatsProvider.notifier).loadProfileStats();
    });
  }

  String _getUserInitials(String fullName) {
    if (fullName.trim().isEmpty) return 'U';

    final names = fullName.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 1).toUpperCase();
    }

    final firstName = names.first;
    final lastName = names.last;

    return '${firstName.substring(0, 1).toUpperCase()}${lastName.substring(0, 1).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final profileStats = ref.watch(profileStatsProvider);

    // Show error if exists
    ref.listen<ProfileStatsState>(profileStatsProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile stats: ${next.error}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                ref.read(profileStatsProvider.notifier).loadProfileStats();
              },
            ),
          ),
        );
      }
    });

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
          title: const Text('Profile'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textOnPrimaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppConstants.primaryColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(profileStatsProvider.notifier).loadProfileStats();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLarge,
              AppConstants.spacingLarge,
              AppConstants.spacingLarge,
              100, // Navbar için ekstra padding
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Avatar Section
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingXLarge),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppConstants.primaryColor,
                              AppConstants.primaryColor.withValues(alpha: 0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppConstants.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getUserInitials(user?.fullName ?? 'User'),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),

                      // User Name
                      Text(
                        user?.fullName ?? 'User',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSmall),

                      // User Email
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppConstants.spacingLarge),

                // Profile Stats Cards
                if (profileStats.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppConstants.spacingXLarge),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (profileStats.error != null)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingLarge),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: AppConstants.spacingMedium),
                          Text(
                            'Unable to load statistics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          Text(
                            'Pull down to refresh',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.account_balance_wallet,
                          title: 'This Month',
                          value:
                              '₺${profileStats.currentMonthSpending.toStringAsFixed(2)}',
                          subtitle: 'Total Spending',
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.calendar_today,
                          title: 'Last Month',
                          value:
                              '₺${profileStats.lastMonthSpending.toStringAsFixed(2)}',
                          subtitle: 'Total Spending',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.receipt_long,
                          title: 'Expenses',
                          value: '${profileStats.currentMonthExpenseCount}',
                          subtitle: 'Total This Month',
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMedium),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.savings,
                          title: 'Budget',
                          value: profileStats.budgetUsagePercentage > 0
                              ? '${profileStats.budgetUsagePercentage.toStringAsFixed(0)}%'
                              : 'N/A',
                          subtitle: profileStats.budgetUsagePercentage > 0
                              ? 'Usage Rate'
                              : 'No Budget Set',
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppConstants.spacingXLarge),

                // Account Information Card
                if (user != null) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadiusLarge,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingLarge),
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
                              const SizedBox(width: AppConstants.spacingSmall),
                              Text(
                                'Account Information',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight:
                                          AppConstants.fontWeightSemiBold,
                                      color: AppConstants.textPrimaryColor,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingLarge),
                          _buildInfoRow('E-mail', user.email),
                          _buildInfoRow('Full Name', user.fullName),
                          if (user.createdAt != null)
                            _buildInfoRow(
                              'Membership Date',
                              '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}',
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXLarge),

                  // Settings Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Settings & Options',
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                      icon: Icons.settings,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingMedium),

                  // Logout Buttons
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Log Out',
                      onPressed: () async {
                        await ref.read(authStateProvider.notifier).logout();

                        // Logout sonrası admin state'i güncelle
                        final refreshAdmin = ref.read(adminRefreshProvider);
                        await refreshAdmin();
                      },
                      isOutlined: true,
                      icon: Icons.logout,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingSmall),

                  // Logout from all devices button
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Log Out from All Devices',
                      onPressed: () async {
                        // Onay dialogu göster
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Log Out from All Devices'),
                            content: const Text(
                              'Are you sure you want to log out from all devices? '
                              'This will terminate your sessions on other devices.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('Log Out'),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          await ref
                              .read(authStateProvider.notifier)
                              .logoutFromAllDevices();

                          // Logout sonrası admin state'i güncelle
                          final refreshAdmin = ref.read(adminRefreshProvider);
                          await refreshAdmin();
                        }
                      },
                      isOutlined: true,
                      icon: Icons.logout_outlined,
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spacingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppConstants.primaryColor),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXSmall),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
