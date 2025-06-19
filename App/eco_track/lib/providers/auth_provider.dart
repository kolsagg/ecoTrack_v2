import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/dependency_injection.dart';
import '../models/auth/auth_models.dart';
import '../models/auth/user_model.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return getIt<AuthService>();
});

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// Auth state class
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _authService.initialize();
      if (_authService.isAuthenticated) {
        state = state.copyWith(
          user: _authService.currentUser,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  // Register user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Register user (backend confirmation email gönderir)
      await _authService.register(request);

      // Email confirmation gerektiği için otomatik login yapmıyoruz
      // Kullanıcı email'ini confirm ettikten sonra manuel login yapacak
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Login user
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = LoginRequest(email: email, password: password);

      final response = await _authService.login(request);

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Login user with remember me support
  Future<void> loginWithRememberMe({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.loginWithRememberMe(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      state = state.copyWith(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
        error: null, // Başarılı durumda error'ı temizle
      );
    } catch (e) {
      print('🔥 AuthProvider loginWithRememberMe error: $e');
      print('🔥 Error type: ${e.runtimeType}');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false, // Hata durumunda authenticated false yap
      );

      print('🔥 State after error: ${state.error}');
      print(
        '🔥 State updated - loading: ${state.isLoading}, error: ${state.error}',
      );
      rethrow;
    }
  }

  // Request password reset
  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = PasswordResetRequest(email: email);
      await _authService.requestPasswordReset(request);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Confirm password reset
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = PasswordResetConfirmRequest(
        token: token,
        newPassword: newPassword,
      );
      await _authService.confirmPasswordReset(request);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Update profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = ProfileUpdateRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      final updatedUser = await _authService.updateProfile(request);

      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = AccountDeleteRequest(password: password);
      await _authService.deleteAccount(request);

      state = const AuthState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = PasswordChangeRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _authService.changePassword(request);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Disable TOTP
  Future<void> disableTotp(String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final request = TotpDisableRequest(password: password);
      await _authService.disableTotp(request);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(); // Reset to initial state
  }

  // Logout from all devices
  Future<void> logoutFromAllDevices() async {
    await _authService.logoutFromAllDevices();
    state = const AuthState(); // Reset to initial state
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// MFA providers
final mfaStatusProvider = FutureProvider<MfaStatusResponse>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getMfaStatus();
});

final totpCreateProvider = FutureProvider<TotpCreateResponse>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.createTotp();
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).error;
});
