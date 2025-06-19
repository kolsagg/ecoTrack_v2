import 'dart:convert';
import '../core/utils/dependency_injection.dart';
import '../models/auth/auth_models.dart';
import '../models/auth/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = getIt<ApiService>();
  final StorageService _storageService = getIt<StorageService>();

  // Current user state
  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  // Initialize auth service - check for existing tokens
  Future<void> initialize() async {
    final token = await _storageService.getAuthToken();
    if (token != null) {
      try {
        // Set token in API service for validation
        _apiService.setAuthToken(token);

        // Validate token with backend
        final isValid = await validateToken();
        if (isValid) {
          // Get stored user data
          final userDataString = await _storageService.getUserData();
          if (userDataString != null) {
            // Parse JSON string back to Map
            final userData = jsonDecode(userDataString) as Map<String, dynamic>;
            _currentUser = User.fromJson(userData);
          }
        } else {
          // Token is invalid, clear stored data
          await logout();
        }
      } catch (e) {
        // If token validation fails, clear stored data
        await logout();
      }
    }
  }

  // Validate current token with backend
  Future<bool> validateToken() async {
    try {
      final token = await _storageService.getAuthToken();
      if (token == null) return false;

      // Use MFA status endpoint to validate token (it requires authentication)
      final response = await _apiService.get<Map<String, dynamic>>(
        '/api/v1/auth/mfa/status',
      );

      // If request succeeds, token is valid
      return response.statusCode == 200;
    } catch (e) {
      // Token validation failed
      return false;
    }
  }

  // Register new user
  Future<RegisterResponse> register(RegisterRequest request) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/register',
      data: request.toJson(),
    );

    final registerResponse = RegisterResponse.fromJson(response.data!);
    // For register, we don't get tokens, so we need to login after registration
    return registerResponse;
  }

  // Login user
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: request.toJson(),
    );

    final authResponse = AuthResponse.fromJson(response.data!);
    await _saveAuthData(authResponse);
    return authResponse;
  }

  // Request password reset
  Future<SuccessResponse> requestPasswordReset(
    PasswordResetRequest request,
  ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/reset-password',
      data: request.toJson(),
    );

    return SuccessResponse.fromJson(response.data!);
  }

  // Confirm password reset
  Future<SuccessResponse> confirmPasswordReset(
    PasswordResetConfirmRequest request,
  ) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/reset-password/confirm',
      data: request.toJson(),
    );

    return SuccessResponse.fromJson(response.data!);
  }

  // Get MFA status
  Future<MfaStatusResponse> getMfaStatus() async {
    final response = await _apiService.get<Map<String, dynamic>>(
      '/api/v1/auth/mfa/status',
    );

    return MfaStatusResponse.fromJson(response.data!);
  }

  // Create TOTP for MFA
  Future<TotpCreateResponse> createTotp() async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/mfa/totp/create',
    );

    return TotpCreateResponse.fromJson(response.data!);
  }

  // Verify TOTP code
  Future<SuccessResponse> verifyTotp(TotpVerifyRequest request) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/mfa/totp/verify',
      data: request.toJson(),
    );

    return SuccessResponse.fromJson(response.data!);
  }

  // Change password
  Future<SuccessResponse> changePassword(PasswordChangeRequest request) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/change-password',
      data: request.toJson(),
    );

    return SuccessResponse.fromJson(response.data!);
  }

  // Disable TOTP
  Future<SuccessResponse> disableTotp(TotpDisableRequest request) async {
    final response = await _apiService.post<Map<String, dynamic>>(
      '/api/v1/auth/mfa/totp/disable',
      data: request.toJson(),
    );

    return SuccessResponse.fromJson(response.data!);
  }

  // Update profile
  Future<User> updateProfile(ProfileUpdateRequest request) async {
    final response = await _apiService.put<Map<String, dynamic>>(
      '/api/v1/auth/profile',
      data: request.toJson(),
    );

    final updatedUser = User.fromJson(response.data!['user']);

    // Update current user and save to storage
    _currentUser = updatedUser;
    final userJsonString = jsonEncode(updatedUser.toJson());
    await _storageService.saveUserData(userJsonString);

    return updatedUser;
  }

  // Delete account
  Future<SuccessResponse> deleteAccount(AccountDeleteRequest request) async {
    final response = await _apiService.delete<Map<String, dynamic>>(
      '/api/v1/auth/account',
      data: request.toJson(),
    );

    await logout(); // Clear local data
    return SuccessResponse.fromJson(response.data!);
  }

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    await _storageService.deleteAuthToken();
    await _storageService.deleteUserData();
    // Remove token from API service
    _apiService.removeAuthToken();
  }

  // Get current auth token
  Future<String?> getToken() async {
    return await _storageService.getAuthToken();
  }

  // Save authentication data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    _currentUser = authResponse.user;
    await _storageService.saveAuthToken(authResponse.accessToken);
    // Set token in API service for future requests
    _apiService.setAuthToken(authResponse.accessToken);
    // Convert to JSON string properly
    final userJsonString = jsonEncode(authResponse.user.toJson());
    await _storageService.saveUserData(userJsonString);
  }

  // Refresh token (if needed)
  Future<AuthResponse?> refreshToken() async {
    try {
      // Get stored refresh token (we'd need to store this separately)
      // For now, we'll implement a basic refresh mechanism
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        // In a real implementation, you'd send the refresh token
      );

      final authResponse = AuthResponse.fromJson(response.data!);
      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      // If refresh fails, logout user
      await logout();
      return null;
    }
  }
}
