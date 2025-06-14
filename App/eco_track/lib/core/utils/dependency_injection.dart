import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../services/expense_service.dart';
import '../../services/receipt_service.dart';
import '../../services/health_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/receipt_repository.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static Future<void> init() async {
    // External dependencies
    getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      ),
    );

    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio();
      
      // Set base URL
      dio.options.baseUrl = ApiConfig.baseUrl;
      
      // Add interceptors for logging in debug mode
      if (const bool.fromEnvironment('dart.vm.product') == false) {
        dio.interceptors.add(LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ));
      }
      
      return dio;
    });

    // Core services
    getIt.registerLazySingleton<StorageService>(
      () => StorageService(getIt<FlutterSecureStorage>()),
    );

    getIt.registerLazySingleton<ApiService>(
      () => ApiService(getIt<Dio>()),
    );

    // Health service
    getIt.registerLazySingleton<HealthService>(
      () => HealthService(getIt<ApiService>()),
    );

    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        apiService: getIt<ApiService>(),
        storageService: getIt<StorageService>(),
      ),
    );

    getIt.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepository(
        apiService: getIt<ApiService>(),
      ),
    );

    getIt.registerLazySingleton<ReceiptRepository>(
      () => ReceiptRepository(
        apiService: getIt<ApiService>(),
      ),
    );

    // Business logic services
    getIt.registerLazySingleton<AuthService>(
      () => AuthService(),
    );

    getIt.registerLazySingleton<ExpenseService>(
      () => ExpenseService(
        expenseRepository: getIt<ExpenseRepository>(),
      ),
    );

    getIt.registerLazySingleton<ReceiptService>(
      () => ReceiptService(getIt<AuthService>(), getIt<Dio>()),
    );
  }

  static void reset() {
    getIt.reset();
  }
} 