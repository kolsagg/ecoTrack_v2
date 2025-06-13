import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';

class HealthCheckResult {
  final bool isHealthy;
  final String message;
  final Map<String, dynamic>? details;

  HealthCheckResult({
    required this.isHealthy,
    required this.message,
    this.details,
  });
}

class HealthService {
  final Dio _dio;

  HealthService(this._dio);

  Future<HealthCheckResult> getGeneralHealth() async {
    try {
      final response = await _dio.get('/health');
      return HealthCheckResult(
        isHealthy: response.statusCode == 200,
        message: response.data['message'] ?? 'System is healthy',
        details: response.data,
      );
    } catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        message: 'Health check failed: ${e.toString()}',
      );
    }
  }

  Future<HealthCheckResult> getDetailedHealth() async {
    try {
      final response = await _dio.get('/health/detailed');
      return HealthCheckResult(
        isHealthy: response.statusCode == 200,
        message: response.data['message'] ?? 'Detailed health check completed',
        details: response.data,
      );
    } catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        message: 'Detailed health check failed: ${e.toString()}',
      );
    }
  }

  Future<HealthCheckResult> getDatabaseHealth() async {
    try {
      final response = await _dio.get('/health/database');
      return HealthCheckResult(
        isHealthy: response.statusCode == 200,
        message: response.data['message'] ?? 'Database connection is healthy',
        details: response.data,
      );
    } catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        message: 'Database health check failed: ${e.toString()}',
      );
    }
  }

  Future<HealthCheckResult> getAIHealth() async {
    try {
      final response = await _dio.get('/health/ai');
      return HealthCheckResult(
        isHealthy: response.statusCode == 200,
        message: response.data['message'] ?? 'AI service is healthy',
        details: response.data,
      );
    } catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        message: 'AI health check failed: ${e.toString()}',
      );
    }
  }

  Future<HealthCheckResult> getReadyStatus() async {
    try {
      final response = await _dio.get('/health/ready');
      return HealthCheckResult(
        isHealthy: response.statusCode == 200,
        message: response.data['message'] ?? 'System is ready',
        details: response.data,
      );
    } catch (e) {
      return HealthCheckResult(
        isHealthy: false,
        message: 'Ready check failed: ${e.toString()}',
      );
    }
  }

  Future<Map<String, HealthCheckResult>> getAllHealthChecks() async {
    final Map<String, HealthCheckResult> results = {};
    
    results['general'] = await getGeneralHealth();
    results['detailed'] = await getDetailedHealth();
    results['database'] = await getDatabaseHealth();
    results['ai'] = await getAIHealth();
    results['ready'] = await getReadyStatus();
    
    return results;
  }
}

final healthServiceProvider = Provider<HealthService>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.instance.apiBaseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.instance.connectTimeout),
    receiveTimeout: Duration(milliseconds: AppConfig.instance.receiveTimeout),
  ));

  if (AppConfig.instance.enableLogging) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
  
  return HealthService(dio);
});

final healthStateProvider = FutureProvider<Map<String, HealthCheckResult>>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return healthService.getAllHealthChecks();
}); 