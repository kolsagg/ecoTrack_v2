import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../core/errors/exceptions.dart';
import '../models/loyalty/loyalty_models.dart';
import 'auth_service.dart';

class LoyaltyService {
  final AuthService _authService;
  final Dio _dio;

  LoyaltyService({required AuthService authService, required Dio dio})
    : _authService = authService,
      _dio = dio;

  // Get Loyalty Status
  Future<LoyaltyStatusResponse> getLoyaltyStatus() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        ApiConfig.loyaltyStatusEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return LoyaltyStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch loyalty status',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching loyalty status: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching loyalty status: $e');
    }
  }

  // Calculate Points
  Future<PointsCalculationResponse> calculatePoints({
    required double amount,
    String? category,
    String? merchantName,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{'amount': amount};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (merchantName != null && merchantName.isNotEmpty) {
        queryParams['merchant_name'] = merchantName;
      }

      final response = await _dio.get(
        ApiConfig.loyaltyCalculatePointsEndpoint,
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return PointsCalculationResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to calculate points',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error calculating points: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error calculating points: $e');
    }
  }

  // Get Loyalty History
  Future<LoyaltyHistoryResponse> getLoyaltyHistory({int limit = 50}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        ApiConfig.loyaltyHistoryEndpoint,
        queryParameters: {'limit': limit},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return LoyaltyHistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch loyalty history',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching loyalty history: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching loyalty history: $e');
    }
  }

  // Get Loyalty Levels
  Future<LoyaltyLevelsResponse> getLoyaltyLevels() async {
    try {
      final response = await _dio.get(ApiConfig.loyaltyLevelsEndpoint);

      return LoyaltyLevelsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch loyalty levels',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching loyalty levels: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching loyalty levels: $e');
    }
  }
}
