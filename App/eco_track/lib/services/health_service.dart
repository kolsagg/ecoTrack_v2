import '../config/api_config.dart';
import '../core/errors/exceptions.dart';
import 'api_service.dart';

class HealthService {
  final ApiService _apiService;

  HealthService(this._apiService);

  // Basic health check - GET /health
  Future<Map<String, dynamic>> basicHealthCheck() async {
    try {
      final response = await _apiService.get(ApiConfig.healthEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw NetworkException('Failed to perform basic health check: ${e.toString()}');
    }
  }

  // Detailed health check - GET /health/detailed
  Future<Map<String, dynamic>> detailedHealthCheck() async {
    try {
      final response = await _apiService.get(ApiConfig.healthDetailedEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw NetworkException('Failed to perform detailed health check: ${e.toString()}');
    }
  }

  // Database health check - GET /health/database
  Future<Map<String, dynamic>> databaseHealthCheck() async {
    try {
      final response = await _apiService.get(ApiConfig.healthDatabaseEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw NetworkException('Failed to perform database health check: ${e.toString()}');
    }
  }

  // System metrics (requires auth) - GET /health/metrics
  Future<Map<String, dynamic>> systemMetrics() async {
    try {
      final response = await _apiService.get(ApiConfig.healthMetricsEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      if (e is AuthException) {
        throw AuthException('Authentication required for system metrics');
      }
      throw NetworkException('Failed to get system metrics: ${e.toString()}');
    }
  }

  // Readiness check - GET /health/ready
  Future<Map<String, dynamic>> readinessCheck() async {
    try {
      final response = await _apiService.get(ApiConfig.healthReadyEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw NetworkException('Failed to perform readiness check: ${e.toString()}');
    }
  }

  // Liveness check - GET /health/live
  Future<Map<String, dynamic>> livenessCheck() async {
    try {
      final response = await _apiService.get(ApiConfig.healthLiveEndpoint);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw NetworkException('Failed to perform liveness check: ${e.toString()}');
    }
  }

  // Comprehensive health check - calls all health endpoints
  Future<HealthCheckResult> comprehensiveHealthCheck({bool includeMetrics = false}) async {
    final results = <String, dynamic>{};
    final errors = <String, String>{};

    // Basic health check
    try {
      results['basic'] = await basicHealthCheck();
    } catch (e) {
      errors['basic'] = e.toString();
    }

    // Detailed health check
    try {
      results['detailed'] = await detailedHealthCheck();
    } catch (e) {
      errors['detailed'] = e.toString();
    }

    // Database health check
    try {
      results['database'] = await databaseHealthCheck();
    } catch (e) {
      errors['database'] = e.toString();
    }

    // Readiness check
    try {
      results['readiness'] = await readinessCheck();
    } catch (e) {
      errors['readiness'] = e.toString();
    }

    // Liveness check
    try {
      results['liveness'] = await livenessCheck();
    } catch (e) {
      errors['liveness'] = e.toString();
    }

    // System metrics (optional, requires auth)
    if (includeMetrics) {
      try {
        results['metrics'] = await systemMetrics();
      } catch (e) {
        errors['metrics'] = e.toString();
      }
    }

    return HealthCheckResult(
      isHealthy: errors.isEmpty,
      results: results,
      errors: errors,
      timestamp: DateTime.now(),
    );
  }

  // Check if backend is reachable
  Future<bool> isBackendReachable() async {
    try {
      await basicHealthCheck();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get backend status summary
  Future<BackendStatus> getBackendStatus() async {
    try {
      final basicHealth = await basicHealthCheck();
      final databaseHealth = await databaseHealthCheck();
      
      final isHealthy = basicHealth['status'] == 'healthy' && 
                       databaseHealth['status'] == 'healthy';
      
      return BackendStatus(
        isHealthy: isHealthy,
        version: basicHealth['version'] ?? 'unknown',
        environment: basicHealth['environment'] ?? 'unknown',
        databaseConnectionTime: databaseHealth['connection_time_ms']?.toDouble() ?? 0.0,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BackendStatus(
        isHealthy: false,
        version: 'unknown',
        environment: 'unknown',
        databaseConnectionTime: 0.0,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
    }
  }
}

// Health check result model
class HealthCheckResult {
  final bool isHealthy;
  final Map<String, dynamic> results;
  final Map<String, String> errors;
  final DateTime timestamp;

  HealthCheckResult({
    required this.isHealthy,
    required this.results,
    required this.errors,
    required this.timestamp,
  });

  // Get specific health check result
  T? getResult<T>(String key) {
    return results[key] as T?;
  }

  // Get specific error
  String? getError(String key) {
    return errors[key];
  }

  // Check if specific health check passed
  bool isCheckHealthy(String key) {
    return !errors.containsKey(key);
  }

  // Get summary
  Map<String, dynamic> toJson() {
    return {
      'isHealthy': isHealthy,
      'results': results,
      'errors': errors,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Backend status model
class BackendStatus {
  final bool isHealthy;
  final String version;
  final String environment;
  final double databaseConnectionTime;
  final DateTime timestamp;
  final String? error;

  BackendStatus({
    required this.isHealthy,
    required this.version,
    required this.environment,
    required this.databaseConnectionTime,
    required this.timestamp,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'isHealthy': isHealthy,
      'version': version,
      'environment': environment,
      'databaseConnectionTime': databaseConnectionTime,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }
} 