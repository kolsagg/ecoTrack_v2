import 'dart:convert';

import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../data/models/ai_recommendations_models.dart';
import '../core/errors/exceptions.dart';
import 'api_service.dart';

class AiRecommendationsService {
  final ApiService _apiService;

  AiRecommendationsService(this._apiService);

  // AI istekleri için özel timeout ayarları (timeout kaldırılmış)
  Options get _aiRequestOptions => Options(
    receiveTimeout: const Duration(minutes: 5), // 5 dakika timeout
    sendTimeout: const Duration(minutes: 5), // 5 dakika send timeout
  );

  /// Get all AI recommendations (waste prevention, anomaly alerts, pattern insights)
  Future<RecommendationResponse> getAllRecommendations() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.recommendationsEndpoint,
        options: _aiRequestOptions,
      );

      if (response.data == null) {
        throw ApiException('No data received from server');
      }

      return RecommendationResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw ApiException('Failed to fetch recommendations: ${e.toString()}');
    }
  }

  /// Get only waste prevention alerts
  Future<List<WastePreventionAlert>> getWastePreventionAlerts() async {
    try {
      final response = await _apiService.get<String>(
        ApiConfig.wastePreventionEndpoint,
        options: _aiRequestOptions,
      );

      if (response.data == null || response.data!.isEmpty) {
        return [];
      }

      print('*** API Response Status Code: ${response.statusCode} ***');
      print('*** API Response Headers: ${response.headers} ***');
      print('*** Raw Response Data: ${response.data} ***');
      print('*** Response Data Type: ${response.data.runtimeType} ***');

      final Map<String, dynamic> data = jsonDecode(response.data!);
      final dynamic alertsData = data['waste_prevention_alerts'];

      if (alertsData is! List) {
        return [];
      }

      return (alertsData)
          .map(
            (json) =>
                WastePreventionAlert.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      print('*** DioException caught in getWastePreventionAlerts ***');
      print('*** DioException type: ${e.type} ***');
      print('*** DioException message: ${e.message} ***');
      print('*** DioException response status: ${e.response?.statusCode} ***');
      print('*** DioException response data: ${e.response?.data} ***');
      throw _handleError(e);
    } on FormatException catch (e) {
      throw ApiException('Failed to parse server response: ${e.message}');
    } on AuthException catch (e) {
      rethrow; // AuthException'ı olduğu gibi tekrar fırlat
    } catch (e) {
      throw ApiException(
        'Failed to fetch waste prevention alerts: ${e.toString()}',
      );
    }
  }

  /// Get only anomaly alerts
  Future<List<CategoryAnomalyAlert>> getAnomalyAlerts() async {
    try {
      final response = await _apiService.get<String>(
        ApiConfig.anomalyAlertsEndpoint,
        options: _aiRequestOptions,
      );

      if (response.data == null || response.data!.isEmpty) {
        return [];
      }

      final Map<String, dynamic> data = jsonDecode(response.data!);
      final dynamic alertsData = data['anomaly_alerts'];

      if (alertsData is! List) {
        return [];
      }

      return (alertsData)
          .map(
            (json) =>
                CategoryAnomalyAlert.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } on FormatException catch (e) {
      throw ApiException('Failed to parse server response: ${e.message}');
    } on AuthException catch (e) {
      rethrow; // AuthException'ı olduğu gibi tekrar fırlat
    } catch (e) {
      throw ApiException('Failed to fetch anomaly alerts: ${e.toString()}');
    }
  }

  /// Get only pattern insights
  Future<List<SpendingPatternInsight>> getPatternInsights() async {
    try {
      final response = await _apiService.get<String>(
        ApiConfig.patternInsightsEndpoint,
        options: _aiRequestOptions,
      );

      if (response.data == null || response.data!.isEmpty) {
        return [];
      }

      final Map<String, dynamic> data = jsonDecode(response.data!);
      final dynamic insightsData = data['spending_pattern_insights'];

      if (insightsData is! List) {
        return [];
      }

      return (insightsData)
          .map(
            (json) =>
                SpendingPatternInsight.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    } on FormatException catch (e) {
      throw ApiException('Failed to parse server response: ${e.message}');
    } on AuthException catch (e) {
      rethrow; // AuthException'ı olduğu gibi tekrar fırlat
    } catch (e) {
      throw ApiException('Failed to fetch pattern insights: ${e.toString()}');
    }
  }

  /// Check recommendations service health
  Future<bool> checkHealth() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.recommendationsHealthEndpoint,
        options: _aiRequestOptions,
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      return false;
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network settings.',
        );

      case DioExceptionType.badCertificate:
        return NetworkException('Certificate verification failed.');

      case DioExceptionType.unknown:
        final errorMessage = error.message ?? 'No message';
        final innerError = error.error?.toString() ?? 'No inner error';
        return NetworkException(
          'An unexpected error occurred. Details: $errorMessage. Inner error: $innerError. Please try again.',
        );
    }
  }

  Exception _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return ValidationException(data?['detail'] ?? 'Invalid request data.');

      case 401:
        return AuthException('Authentication failed. Please login again.');

      case 403:
        return AuthException(
          'Access denied. You don\'t have permission to perform this action.',
        );

      case 404:
        return ApiException('AI Recommendations service not found.');

      case 422:
        return ValidationException(
          data?['detail'] ?? 'Request validation failed.',
        );

      case 500:
        return ApiException(
          'AI Recommendations service is temporarily unavailable.',
        );

      default:
        return ApiException(
          data?['detail'] ??
              'An error occurred while fetching recommendations.',
        );
    }
  }
}
