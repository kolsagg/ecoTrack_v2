import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(authStateProvider.notifier)
          .requestPasswordReset(_emailController.text.trim());

      setState(() {
        _emailSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } catch (e) {
      // Hata auth state listener tarafından handle edilecek
      // Bu blok sadece beklenmedik durumlar için
      print('Password reset error not handled by auth state: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    // Auth state error'ını dinle ve göster
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        String errorMessage = 'Şifre sıfırlama başarısız oldu';

        // Hata tipine göre özel mesajlar
        final errorString = next.error!.toLowerCase();
        if (errorString.contains('user not found') ||
            errorString.contains('email not found') ||
            errorString.contains('404')) {
          errorMessage = 'No user found with this email address';
        } else if (errorString.contains('invalid email')) {
          errorMessage = 'Invalid email address';
        } else if (errorString.contains('too many requests') ||
            errorString.contains('429')) {
          errorMessage = 'Too many attempts. Please try again later';
        } else if (errorString.contains('network') ||
            errorString.contains('connection')) {
          errorMessage = 'Please check your internet connection';
        } else if (errorString.contains('server') ||
            errorString.contains('500')) {
          errorMessage = 'Server error. Please try again later';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );

        // Hata gösterildikten sonra temizle
        ref.read(authStateProvider.notifier).clearError();
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: AppConstants.textPrimaryColor,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: LoadingOverlay(
          isLoading: isLoading,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppConstants.spacingXLarge),

                    // Icon
                    Icon(
                      _emailSent ? Icons.mark_email_read : Icons.lock_reset,
                      size: AppConstants.iconSizeXLarge * 2,
                      color: AppConstants.primaryColor,
                    ),

                    const SizedBox(height: AppConstants.spacingXLarge),

                    // Title
                    Text(
                      _emailSent ? 'Check Your Email' : 'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppConstants.textPrimaryColor,
                            fontWeight: AppConstants.fontWeightBold,
                          ),
                    ),

                    const SizedBox(height: AppConstants.spacingMedium),

                    // Description
                    Text(
                      _emailSent
                          ? 'We\'ve sent a password reset link to ${_emailController.text.trim()}'
                          : 'Don\'t worry! Enter your email address and we\'ll send you a link to reset your password.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXXLarge),

                    if (!_emailSent) ...[
                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'Enter your email address',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: AppConstants.spacingXLarge),

                      // Reset Button
                      CustomButton(
                        text: 'Send Reset Link',
                        onPressed: _handleResetPassword,
                        isLoading: isLoading,
                      ),
                    ] else ...[
                      // Success actions
                      CustomButton(
                        text: 'Resend Email',
                        onPressed: () {
                          setState(() {
                            _emailSent = false;
                          });
                        },
                        isOutlined: true,
                      ),

                      const SizedBox(height: AppConstants.spacingMedium),

                      CustomButton(
                        text: 'Back to Login',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacingXXLarge),

                    // Help text
                    if (!_emailSent)
                      Text(
                        'Remember your password?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),

                    if (!_emailSent)
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Back to Login',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: AppConstants.fontWeightSemiBold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
