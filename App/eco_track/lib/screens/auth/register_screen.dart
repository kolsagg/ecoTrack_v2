import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );
      
      if (mounted) {
        // Registration başarılı - email confirmation mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registration successful! Please check your email to confirm your account.'),
            backgroundColor: AppConstants.successColor,
            duration: const Duration(seconds: 5),
          ),
        );
        
        // Login ekranına geri dön
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
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
                    const SizedBox(height: AppConstants.spacingSmall),
                    
                    // Title
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppConstants.textPrimaryColor,
                        fontWeight: AppConstants.fontWeightBold,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacingXSmall),
                    
                    Text(
                      'Join EcoTrack and start your sustainable journey',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textSecondaryColor,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spacingMedium),
                    
                    // Name Fields Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _firstNameController,
                            label: 'First Name',
                            hintText: 'First name',
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 2) {
                                return 'Too short';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingMedium),
                        Expanded(
                          child: CustomTextField(
                            controller: _lastNameController,
                            label: 'Last Name',
                            hintText: 'Last name',
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (value.length < 2) {
                                return 'Too short';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spacingMedium),
                    
                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hintText: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email required';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.spacingMedium),
                    
                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hintText: 'Min 8 chars, A-z, 0-9',
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
                      textInputAction: TextInputAction.next,
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
                          return 'Password required';
                        }
                        if (value.length < 8) {
                          return 'Min 8 characters';
                        }
                        if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
                          return 'Need A-z, 0-9';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.spacingMedium),
                    
                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hintText: 'Repeat password',
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outlined,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: AppConstants.textSecondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm required';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords don\'t match';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppConstants.spacingMedium),
                    
                    // Terms and Conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: AppConstants.primaryColor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _acceptTerms = !_acceptTerms;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppConstants.textSecondaryColor,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to '),
                                  TextSpan(
                                    text: 'Terms',
                                    style: TextStyle(
                                      color: AppConstants.primaryColor,
                                      fontWeight: AppConstants.fontWeightMedium,
                                    ),
                                  ),
                                  const TextSpan(text: ' & '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppConstants.primaryColor,
                                      fontWeight: AppConstants.fontWeightMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppConstants.spacingLarge),
                    
                    // Register Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: isLoading,
                    ),
                    
                    const SizedBox(height: AppConstants.spacingLarge),
                    
                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Sign In',
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