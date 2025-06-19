import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;

  StorageService(this._secureStorage);

  // Auth token operations
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: AppConfig.authTokenKey, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: AppConfig.authTokenKey);
  }

  Future<void> deleteAuthToken() async {
    await _secureStorage.delete(key: AppConfig.authTokenKey);
  }

  // User data operations
  Future<void> saveUserData(String userData) async {
    await _secureStorage.write(key: AppConfig.userDataKey, value: userData);
  }

  Future<String?> getUserData() async {
    return await _secureStorage.read(key: AppConfig.userDataKey);
  }

  Future<void> deleteUserData() async {
    await _secureStorage.delete(key: AppConfig.userDataKey);
  }

  // Remember token operations
  Future<void> saveRememberToken(String token) async {
    await _secureStorage.write(key: AppConfig.rememberTokenKey, value: token);
  }

  Future<String?> getRememberToken() async {
    return await _secureStorage.read(key: AppConfig.rememberTokenKey);
  }

  Future<void> deleteRememberToken() async {
    await _secureStorage.delete(key: AppConfig.rememberTokenKey);
  }

  // Remember token expiry operations
  Future<void> saveRememberTokenExpiry(DateTime expiry) async {
    await _secureStorage.write(
      key: AppConfig.rememberTokenExpiryKey,
      value: expiry.toIso8601String(),
    );
  }

  Future<DateTime?> getRememberTokenExpiry() async {
    final expiryString = await _secureStorage.read(
      key: AppConfig.rememberTokenExpiryKey,
    );
    if (expiryString != null) {
      return DateTime.parse(expiryString);
    }
    return null;
  }

  Future<void> deleteRememberTokenExpiry() async {
    await _secureStorage.delete(key: AppConfig.rememberTokenExpiryKey);
  }

  // Check if remember token is valid
  Future<bool> isRememberTokenValid() async {
    final token = await getRememberToken();
    final expiry = await getRememberTokenExpiry();

    if (token == null || expiry == null) {
      return false;
    }

    return DateTime.now().isBefore(expiry);
  }

  // Theme operations
  Future<void> saveThemeMode(String themeMode) async {
    await _secureStorage.write(key: AppConfig.themeKey, value: themeMode);
  }

  Future<String?> getThemeMode() async {
    return await _secureStorage.read(key: AppConfig.themeKey);
  }

  // Language operations
  Future<void> saveLanguage(String language) async {
    await _secureStorage.write(key: AppConfig.languageKey, value: language);
  }

  Future<String?> getLanguage() async {
    return await _secureStorage.read(key: AppConfig.languageKey);
  }

  // Onboarding operations
  Future<void> setOnboardingCompleted(bool completed) async {
    await _secureStorage.write(
      key: AppConfig.onboardingKey,
      value: completed.toString(),
    );
  }

  Future<bool> isOnboardingCompleted() async {
    final value = await _secureStorage.read(key: AppConfig.onboardingKey);
    return value == 'true';
  }

  // Biometric operations
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: AppConfig.biometricKey,
      value: enabled.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: AppConfig.biometricKey);
    return value == 'true';
  }

  // Clear all data
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    return await _secureStorage.containsKey(key: key);
  }

  // Get all keys
  Future<Map<String, String>> readAll() async {
    return await _secureStorage.readAll();
  }

  // Generic data operations
  Future<void> saveData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    await _secureStorage.delete(key: key);
  }
}
