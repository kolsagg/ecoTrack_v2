import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth/auth_models.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _totpCodeController = TextEditingController();
  final _disableTotpPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _obscureDisablePassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _totpCodeController.dispose();
    _disableTotpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    try {
      await ref
          .read(authStateProvider.notifier)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password change error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setupMfa() async {
    try {
      final totpResponse = await ref.read(totpCreateProvider.future);

      if (mounted) {
        _showMfaSetupDialog(totpResponse);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('MFA setup error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMfaSetupDialog(TotpCreateResponse totpResponse) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Two-Factor Authentication Setup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan the QR code below with your authenticator app:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(data: totpResponse.qrCodeUrl, size: 200),
              ),
              const SizedBox(height: 16),
              const Text(
                'If you can\'t scan the QR code, enter this code manually:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  totpResponse.secretKey,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _totpCodeController,
                label: 'Verification Code',
                hintText: 'Enter 6-digit code',
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Verification code is required';
                  }
                  if (value.length != 6) {
                    return 'Enter 6-digit code';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _totpCodeController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _verifyAndEnableMfa(),
            child: const Text('Verify and Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyAndEnableMfa() async {
    if (_totpCodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter 6-digit verification code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyTotp(
        TotpVerifyRequest(code: _totpCodeController.text),
      );

      if (mounted) {
        Navigator.of(context).pop();
        _totpCodeController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Two-factor authentication enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh MFA status
        ref.invalidate(mfaStatusProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disableMfa() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable MFA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your password to disable two-factor authentication:',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _disableTotpPasswordController,
              label: 'Password',
              hintText: 'Enter your current password',
              obscureText: _obscureDisablePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureDisablePassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureDisablePassword = !_obscureDisablePassword;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _disableTotpPasswordController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _confirmDisableMfa(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDisableMfa() async {
    if (_disableTotpPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await ref
          .read(authStateProvider.notifier)
          .disableTotp(_disableTotpPasswordController.text);

      if (mounted) {
        Navigator.of(context).pop();
        _disableTotpPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Two-factor authentication disabled'),
            backgroundColor: Colors.orange,
          ),
        );

        // Refresh MFA status
        ref.invalidate(mfaStatusProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('MFA disable error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final mfaStatusAsync = ref.watch(mfaStatusProvider);

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
          title: const Text('Security Settings'),
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textOnPrimaryColor,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppConstants.primaryColor,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        body: LoadingOverlay(
          isLoading: authState.isLoading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Password Change Section
                _buildSectionHeader('Change Password'),
                const SizedBox(height: AppConstants.spacingMedium),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLarge),
                    child: Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _currentPasswordController,
                            label: 'Current Password',
                            hintText: 'Enter your current password',
                            obscureText: _obscureCurrentPassword,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureCurrentPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppConstants.textSecondaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureCurrentPassword =
                                      !_obscureCurrentPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Current password is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppConstants.spacingMedium),

                          CustomTextField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            hintText: 'Min 8 chars, A-z, 0-9',
                            obscureText: _obscureNewPassword,
                            prefixIcon: Icons.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureNewPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppConstants.textSecondaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'New password is required';
                              }
                              if (value.length < 8) {
                                return 'Must be at least 8 characters';
                              }
                              if (!RegExp(
                                r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
                              ).hasMatch(value)) {
                                return 'Must contain uppercase, lowercase and number';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppConstants.spacingMedium),

                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            hintText: 'Re-enter new password',
                            obscureText: _obscureConfirmPassword,
                            prefixIcon: Icons.lock,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppConstants.textSecondaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password confirmation is required';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppConstants.spacingLarge),

                          CustomButton(
                            text: 'Change Password',
                            onPressed: _changePassword,
                            icon: Icons.security,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXLarge),

                // MFA Section
                _buildSectionHeader('Two-Factor Authentication (2FA)'),
                const SizedBox(height: AppConstants.spacingMedium),

                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: AppConstants.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Two-Factor Authentication',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppConstants.textPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Make your account more secure',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppConstants.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.spacingMedium),

                        mfaStatusAsync.when(
                          data: (mfaStatus) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: mfaStatus.isEnabled
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        mfaStatus.isEnabled
                                            ? Icons.check_circle
                                            : Icons.warning,
                                        color: mfaStatus.isEnabled
                                            ? Colors.green[700]
                                            : Colors.orange[700],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        mfaStatus.isEnabled
                                            ? '2FA Enabled'
                                            : '2FA Disabled',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: mfaStatus.isEnabled
                                              ? Colors.green[700]
                                              : Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: AppConstants.spacingMedium,
                                ),

                                if (mfaStatus.isEnabled) ...[
                                  const SizedBox(
                                    height: AppConstants.spacingMedium,
                                  ),
                                  CustomButton(
                                    text: 'Disable 2FA',
                                    onPressed: _disableMfa,
                                    icon: Icons.security,
                                    isOutlined: true,
                                    textColor: Colors.red,
                                  ),
                                ] else ...[
                                  Text(
                                    'Two-factor authentication adds an extra layer of security to your account. When signing in, you\'ll need to enter a code from your authenticator app in addition to your password.',
                                    style: TextStyle(
                                      color: AppConstants.textSecondaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: AppConstants.spacingMedium,
                                  ),
                                  CustomButton(
                                    text: 'Enable 2FA',
                                    onPressed: _setupMfa,
                                    icon: Icons.security,
                                  ),
                                ],
                              ],
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, stack) => Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Failed to load MFA status: $error',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingXLarge),

                // Security Tips
                _buildSectionHeader('Security Tips'),
                const SizedBox(height: AppConstants.spacingMedium),

                Card(
                  elevation: 1,
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
                        _buildSecurityTip(
                          Icons.password,
                          'Use Strong Passwords',
                          'Use passwords with at least 8 characters, including uppercase, lowercase, and numbers.',
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        _buildSecurityTip(
                          Icons.security,
                          'Enable 2FA',
                          'Two-factor authentication makes your account 99% more secure.',
                        ),
                        const SizedBox(height: AppConstants.spacingMedium),
                        _buildSecurityTip(
                          Icons.devices,
                          'Monitor Your Devices',
                          'Regularly check the devices connected to your account.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: AppConstants.fontWeightSemiBold,
        color: AppConstants.textPrimaryColor,
      ),
    );
  }

  Widget _buildSecurityTip(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
