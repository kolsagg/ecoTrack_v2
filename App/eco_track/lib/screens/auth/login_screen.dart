import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    print('🗑️ LoginScreen dispose() called!');
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    print('🚀 Login attempt started');
    print('🚀 Widget mounted at start: $mounted');

    try {
      print('🚀 Before auth call - mounted: $mounted');

      await ref
          .read(authStateProvider.notifier)
          .loginWithRememberMe(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            rememberMe: _rememberMe,
          );

      print('✅ Login successful');
      print('✅ After successful login - mounted: $mounted');

      // Login sonrası admin state'i güncelle
      final refreshAdmin = ref.read(adminRefreshProvider);
      await refreshAdmin();

      if (mounted) {
        // Navigate to main app - this will be handled by the main app routing
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      print('❌ After catch - mounted: $mounted');
      print('❌ Login failed in _handleLogin: $e');
      print('❌ Error Type: ${e.runtimeType}');
      print('⚠️ Error will be handled by auth state listener');
      // Hata mesajı auth state listener tarafından gösterilecek
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    // Auth state error'ını dinle ve göster
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      print('🟢 AUTH STATE LISTENER TRIGGERED!');
      print(
        '🟢 Previous: loading=${previous?.isLoading}, error=${previous?.error}',
      );
      print('🟢 Next: loading=${next.isLoading}, error=${next.error}');

      // Widget dispose edilmişse hiçbir şey yapma
      if (!mounted) {
        print('🚫 Widget disposed in listener, skipping error display');
        return;
      }

      if (next.error != null && next.error != previous?.error) {
        // Debug için hata mesajını konsola yazdır
        print('🔴 Login Error: ${next.error}');
        print('🔴 Error Type: ${next.error.runtimeType}');

        String errorMessage = 'Login failed';

        // Hata tipine göre özel mesajlar
        final errorString = next.error!.toLowerCase();
        print('🔴 Error String (lowercase): $errorString');

        if (errorString.contains('authentication failed') ||
            errorString.contains('invalid credentials') ||
            errorString.contains('authexception') ||
            errorString.contains('401') ||
            errorString.contains('login again')) {
          errorMessage = 'Email or password is incorrect';
        } else if (errorString.contains('email not confirmed') ||
            errorString.contains('account not verified')) {
          errorMessage = 'Please confirm your email address';
        } else if (errorString.contains('account locked') ||
            errorString.contains('account disabled')) {
          errorMessage = 'Your account is locked. Please contact support';
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

        print('🔴 Final Error Message: $errorMessage');
        print('🔴 Showing SnackBar...');

        // SnackBar'ı güvenli şekilde göster
        try {
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
          print('✅ SnackBar shown successfully');
        } catch (e) {
          print('❌ Failed to show SnackBar: $e');
        }

        // Hata gösterildikten sonra temizle
        try {
          ref.read(authStateProvider.notifier).clearError();
        } catch (e) {
          print('❌ Failed to clear error: $e');
        }
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.spacingLarge),

                  // App Logo/Title
                  Icon(
                    Icons.eco,
                    size: AppConstants.iconSizeXLarge * 1.5,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(height: AppConstants.spacingSmall),

                  Text(
                    AppConstants.appName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppConstants.primaryColor,
                      fontWeight: AppConstants.fontWeightBold,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXSmall),

                  Text(
                    'Track your expenses, save the planet',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXLarge),

                  // Welcome Text
                  Text(
                    'Welcome to EcoTrack',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppConstants.textPrimaryColor,
                      fontWeight: AppConstants.fontWeightSemiBold,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXSmall),

                  Text(
                    'Sign in to continue to your account',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hintText: 'Enter your email',
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

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppConstants.textSecondaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppConstants.spacingSmall),

                  // Remember Me & Forgot Password Row
                  Row(
                    children: [
                      // Remember Me Checkbox
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: AppConstants.primaryColor,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _rememberMe = !_rememberMe;
                          });
                        },
                        child: Text(
                          'Remember Me',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppConstants.textPrimaryColor),
                        ),
                      ),
                      const Spacer(),
                      // Forgot Password
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: AppConstants.fontWeightMedium,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Login Button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingMedium,
                        ),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppConstants.textSecondaryColor,
                              ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingLarge),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: AppConstants.fontWeightSemiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
