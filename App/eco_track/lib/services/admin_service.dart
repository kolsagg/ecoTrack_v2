import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/admin/admin_models.dart';
import '../core/utils/dependency_injection.dart';
import 'api_service.dart';

class AdminService {
  final ApiService _apiService;

  AdminService() : _apiService = getIt<ApiService>();

  // Get system metrics
  Future<SystemMetrics> getSystemMetrics() async {
    try {
      final response = await _apiService.get('/health/metrics');

      if (kDebugMode) {
        print('Get system metrics response: ${response.data}');
      }

      return SystemMetrics.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting system metrics: ${e.message}');
      }
      throw Exception('Sistem metrikleri alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting system metrics: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get system health
  Future<SystemHealth> getSystemHealth() async {
    try {
      final response = await _apiService.get('/health/detailed');

      if (kDebugMode) {
        print('Get system health response: ${response.data}');
      }

      return SystemHealth.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting system health: ${e.message}');
      }
      throw Exception('Sistem sağlığı bilgileri alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting system health: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get admin dashboard data
  Future<AdminDashboardData> getDashboardData() async {
    try {
      // GEÇICI ÇÖZÜM: Backend endpoint hazır olmadığı için mock data
      // TODO: Backend'de /api/v1/admin/dashboard endpoint'i eklendikten sonra kaldırılacak

      if (kDebugMode) {
        print('Mock dashboard data - returning sample admin dashboard data');
      }

      // Mock data oluştur
      final mockData = {
        'system_metrics': {
          'total_users': 150,
          'active_users': 89,
          'total_merchants': 25,
          'total_expenses': 1250,
          'total_amount': 45678.90,
          'avg_expense_amount': 36.54,
        },
        'system_health': {
          'status': 'healthy',
          'database_status': 'connected',
          'redis_status': 'connected',
          'api_status': 'operational',
          'response_time': 125.5,
          'memory_usage': 68.2,
          'cpu_usage': 45.1,
          'disk_usage': 32.8,
          'last_check': DateTime.now().toIso8601String(),
        },
        'recent_users': [
          {
            'user_email': 'user1@example.com',
            'last_login': DateTime.now()
                .subtract(const Duration(hours: 2))
                .toIso8601String(),
            'total_expenses': 45,
            'total_amount': 1250.75,
            'is_active': true,
          },
          {
            'user_email': 'user2@example.com',
            'last_login': DateTime.now()
                .subtract(const Duration(hours: 5))
                .toIso8601String(),
            'total_expenses': 32,
            'total_amount': 890.50,
            'is_active': true,
          },
        ],
        'top_merchants': [
          {'name': 'Market A', 'transaction_count': 125},
          {'name': 'Market B', 'transaction_count': 98},
        ],
        'daily_stats': [
          {'date': '2024-01-15', 'transactions': 45, 'amount': 1250.0},
          {'date': '2024-01-14', 'transactions': 38, 'amount': 980.0},
        ],
      };

      return AdminDashboardData.fromJson(mockData);

      /* GERÇEK IMPLEMENTASYON (Backend hazır olduğunda):
      final response = await _apiService.get('/api/v1/admin/dashboard');

      if (kDebugMode) {
        print('Get dashboard data response: ${response.data}');
      }

      return AdminDashboardData.fromJson(response.data);
      */
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting dashboard data: ${e.message}');
      }
      throw Exception('Dashboard verileri alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting dashboard data: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get user activities
  Future<List<UserActivity>> getUserActivities({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // GEÇICI ÇÖZÜM: Backend endpoint hazır olmadığı için mock data
      // TODO: Backend'de /api/v1/admin/users/activities endpoint'i eklendikten sonra kaldırılacak

      if (kDebugMode) {
        print('Mock user activities - returning sample user activity data');
      }

      // Mock user activities data
      final mockActivities = [
        {
          'user_email': 'admin@example.com',
          'last_login': DateTime.now()
              .subtract(const Duration(minutes: 30))
              .toIso8601String(),
          'total_expenses': 67,
          'total_amount': 2150.75,
          'is_active': true,
        },
        {
          'user_email': 'user1@example.com',
          'last_login': DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          'total_expenses': 45,
          'total_amount': 1250.75,
          'is_active': true,
        },
        {
          'user_email': 'user2@example.com',
          'last_login': DateTime.now()
              .subtract(const Duration(hours: 5))
              .toIso8601String(),
          'total_expenses': 32,
          'total_amount': 890.50,
          'is_active': true,
        },
        {
          'user_email': 'user3@example.com',
          'last_login': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'total_expenses': 28,
          'total_amount': 675.25,
          'is_active': false,
        },
      ];

      return mockActivities.map((json) => UserActivity.fromJson(json)).toList();

      /* GERÇEK IMPLEMENTASYON (Backend hazır olduğunda):
      final response = await _apiService.get(
        '/api/v1/admin/users/activities',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      if (kDebugMode) {
        print('Get user activities response: ${response.data}');
      }

      final List<dynamic> activitiesJson = response.data['activities'] ?? [];
      return activitiesJson.map((json) => UserActivity.fromJson(json)).toList();
      */
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting user activities: ${e.message}');
      }
      throw Exception('Kullanıcı aktiviteleri alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting user activities: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get database status
  Future<Map<String, dynamic>> getDatabaseStatus() async {
    try {
      final response = await _apiService.get('/health/database');

      if (kDebugMode) {
        print('Get database status response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting database status: ${e.message}');
      }
      throw Exception('Veritabanı durumu alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting database status: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get API readiness status
  Future<Map<String, dynamic>> getReadinessStatus() async {
    try {
      final response = await _apiService.get('/health/ready');

      if (kDebugMode) {
        print('Get readiness status response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting readiness status: ${e.message}');
      }
      throw Exception('API hazırlık durumu alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting readiness status: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get API liveness status
  Future<Map<String, dynamic>> getLivenessStatus() async {
    try {
      final response = await _apiService.get('/health/live');

      if (kDebugMode) {
        print('Get liveness status response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting liveness status: ${e.message}');
      }
      throw Exception('API canlılık durumu alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting liveness status: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Get system statistics
  Future<Map<String, dynamic>> getSystemStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }

      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }

      final response = await _apiService.get(
        '/api/v1/admin/statistics',
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print('Get system statistics response: ${response.data}');
      }

      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting system statistics: ${e.message}');
      }
      throw Exception('Sistem istatistikleri alınamadı: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting system statistics: $e');
      }
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  // Check admin permissions
  Future<bool> checkAdminPermissions() async {
    try {
      // GEÇICI ÇÖZÜM: Backend endpoint hazır olmadığı için mock admin kontrolü
      // TODO: Backend'de /api/v1/admin/check-permissions endpoint'i eklendikten sonra kaldırılacak

      // Şimdilik tüm authenticated kullanıcıları admin olarak kabul et
      await _apiService.get('/health'); // Basit bir authenticated endpoint test

      if (kDebugMode) {
        print(
          'Mock admin check - user is authenticated, granting admin access',
        );
      }

      return true; // GEÇICI: Tüm kullanıcıları admin yap

      /* GERÇEK IMPLEMENTASYON (Backend hazır olduğunda):
      final response = await _apiService.get('/api/v1/admin/check-permissions');

      if (kDebugMode) {
        print('Check admin permissions response: ${response.data}');
      }

      return response.data['is_admin'] ?? false;
      */
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error checking admin permissions: ${e.message}');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error checking admin permissions: $e');
      }
      return false;
    }
  }
}
