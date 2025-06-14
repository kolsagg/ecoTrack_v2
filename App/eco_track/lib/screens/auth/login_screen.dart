import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(authStateProvider.notifier).login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        // Navigate to main app - this will be handled by the main app routing
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

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
                      'Welcome Back',
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
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
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
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                    
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
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
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
      ),
    );
  }
} 