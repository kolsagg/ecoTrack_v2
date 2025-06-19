import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/admin_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminDashboardProvider);

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
          title: const Text('Settings & Options'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textOnPrimaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppConstants.primaryColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSettingsItem(
                context,
                icon: Icons.receipt_long,
                title: 'View Receipts',
                subtitle: 'Browse receipts',
                onTap: () {
                  Navigator.of(context).pushNamed('/receipts');
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Budget Management',
                subtitle: 'Manage your budget',
                onTap: () {
                  Navigator.of(context).pushNamed('/budget-management');
                },
              ),

              const SizedBox(height: AppConstants.spacingXLarge),

              // Additional Features Section
              _buildSectionHeader(context, 'Additional Features'),
              const SizedBox(height: AppConstants.spacingMedium),

              _buildSettingsItem(
                context,
                icon: Icons.rate_review,
                title: 'Reviews',
                subtitle: 'Merchant reviews',
                onTap: () => Navigator.pushNamed(context, '/my-reviews'),
              ),

              _buildSettingsItem(
                context,
                icon: Icons.stars,
                title: 'Loyalty Program',
                subtitle: 'Points and rewards',
                onTap: () {
                  Navigator.of(context).pushNamed('/loyalty-dashboard');
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.devices,
                title: 'Device Management',
                subtitle: 'Manage connected devices',
                onTap: () {
                  Navigator.of(context).pushNamed('/device-management');
                },
              ),

              // Admin Panel - only show if user is admin
              if (adminState.isAdmin) ...[
                const SizedBox(height: AppConstants.spacingXLarge),
                _buildSectionHeader(context, 'Admin'),
                const SizedBox(height: AppConstants.spacingMedium),

                _buildSettingsItem(
                  context,
                  icon: Icons.admin_panel_settings,
                  title: 'Admin Panel',
                  subtitle: 'System management',
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin-dashboard');
                  },
                ),
              ],

              const SizedBox(height: AppConstants.spacingXLarge),

              // Account Management Section
              _buildSectionHeader(context, 'Account Management'),
              const SizedBox(height: AppConstants.spacingMedium),

              _buildSettingsItem(
                context,
                icon: Icons.edit,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () {
                  Navigator.of(context).pushNamed('/edit-profile');
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.security,
                title: 'Security Settings',
                subtitle: 'Password and security',
                onTap: () {
                  Navigator.of(context).pushNamed('/security-settings');
                },
              ),

              _buildSettingsItem(
                context,
                icon: Icons.notifications,
                title: 'Notification Settings',
                subtitle: 'Manage notifications',
                onTap: () {
                  // TODO: Navigate to notification settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification settings are coming soon!'),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppConstants.spacingXLarge),

              // Danger Zone
              _buildSectionHeader(context, 'Danger Zone', isWarning: true),
              const SizedBox(height: AppConstants.spacingMedium),

              _buildSettingsItem(
                context,
                icon: Icons.delete_forever,
                title: 'Delete Account',
                subtitle: 'Delete your account permanently',
                onTap: () {
                  _showDeleteAccountDialog(context, ref);
                },
                isDestructive: true,
              ),

              const SizedBox(height: AppConstants.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool isWarning = false,
  }) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: isWarning ? Colors.red[700] : AppConstants.textPrimaryColor,
        fontWeight: AppConstants.fontWeightSemiBold,
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red[700] : AppConstants.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive
                ? Colors.red[700]
                : AppConstants.textPrimaryColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDestructive
                ? Colors.red[500]
                : AppConstants.textSecondaryColor,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDestructive
              ? Colors.red[400]
              : AppConstants.textSecondaryColor,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMedium,
          vertical: AppConstants.spacingSmall,
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Hesabı Sil'),
          ],
        ),
        content: const Text(
          'Bu işlem geri alınamaz! Hesabınız ve tüm verileriniz kalıcı olarak silinecektir.\n\nDevam etmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteAccount(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Son Onay'),
        content: const Text('Hesabınızı silmek için "SİL" yazın:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hesap silme işlemi yakında geliyor!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }
}
