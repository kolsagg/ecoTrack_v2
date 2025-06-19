import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_overlay.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
    }

    // Add listeners to track changes
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final user = ref.read(authStateProvider).user;
    if (user != null) {
      final hasChanges =
          _firstNameController.text != user.firstName ||
          _lastNameController.text != user.lastName ||
          _emailController.text != user.email;

      if (hasChanges != _hasChanges) {
        setState(() {
          _hasChanges = hasChanges;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(authStateProvider.notifier)
          .updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil güncellenirken hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değişiklikleri Kaydet'),
        content: const Text(
          'Yaptığınız değişiklikler kaydedilmedi. Çıkmak istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Çık'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
    if (value.trim().length < 2) {
      return 'En az 2 karakter olmalıdır';
    }
    if (value.trim().length > 50) {
      return 'En fazla 50 karakter olabilir';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profili Düzenle'),
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              if (_hasChanges)
                IconButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: const Icon(Icons.check),
                  tooltip: 'Kaydet',
                ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: _isLoading || authState.isLoading,
            loadingText: 'Profil güncelleniyor...',
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Avatar Section
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppConstants.primaryColor,
                                  AppConstants.primaryColor.withValues(
                                    alpha: 0.7,
                                  ),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppConstants.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            authState.user?.fullName ?? 'Kullanıcı',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Form Fields
                    Text(
                      'Kişisel Bilgiler',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // First Name Field
                    CustomTextField(
                      controller: _firstNameController,
                      label: 'Ad',
                      prefixIcon: Icons.person_outline,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Last Name Field
                    CustomTextField(
                      controller: _lastNameController,
                      label: 'Soyad',
                      prefixIcon: Icons.person_outline,
                      validator: _validateName,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      label: 'E-posta',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Değişiklikleri Kaydet',
                        onPressed: _hasChanges && !_isLoading
                            ? _saveProfile
                            : null,
                        icon: Icons.save,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'İptal',
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        isOutlined: true,
                        icon: Icons.cancel,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Bilgi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'E-posta adresinizi değiştirirseniz, yeni e-posta adresinizi doğrulamanız gerekebilir.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
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
        ),
      ),
    );
  }
}
