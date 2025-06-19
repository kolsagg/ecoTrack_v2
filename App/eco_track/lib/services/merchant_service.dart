import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../models/merchant/merchant_models.dart';
import '../core/utils/dependency_injection.dart';
import 'api_service.dart';

class MerchantService {
  final ApiService _apiService;

  MerchantService() : _apiService = getIt<ApiService>();

  // Get all merchants with pagination
  Future<MerchantListResponse> getMerchants({
    int page = 1,
    int size = 20,
    String? search,
    bool? isActive,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page, 'size': size};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await _apiService.get(
        '/api/v1/merchants',
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print('Get merchants response: ${response.data}');
      }

      return MerchantListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting merchants: ${e.message}');
      }
      throw Exception('Cannot load merchant list: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting merchants: $e');
      }
      throw Exception('Unexpected error getting merchants: $e');
    }
  }

  // Get merchant by ID
  Future<Merchant> getMerchant(String merchantId) async {
    try {
      final response = await _apiService.get('/api/v1/merchants/$merchantId');

      if (kDebugMode) {
        print('Get merchant response: ${response.data}');
      }

      return Merchant.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error getting merchant: ${e.message}');
      }
      throw Exception('Cannot load merchant details: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error getting merchant: $e');
      }
      throw Exception('Unexpected error getting merchant: $e');
    }
  }

  // Create new merchant
  Future<Merchant> createMerchant(MerchantCreateRequest request) async {
    try {
      final response = await _apiService.post(
        '/api/v1/merchants/',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('Create merchant response: ${response.data}');
      }

      return Merchant.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error creating merchant: ${e.message}');
      }
      throw Exception('Cannot create merchant: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error creating merchant: $e');
      }
      throw Exception('Unexpected error creating merchant: $e');
    }
  }

  // Update merchant
  Future<Merchant> updateMerchant(
    String merchantId,
    MerchantUpdateRequest request,
  ) async {
    try {
      final response = await _apiService.put(
        '/api/v1/merchants/$merchantId',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('Update merchant response: ${response.data}');
      }

      return Merchant.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error updating merchant: ${e.message}');
      }
      throw Exception('Cannot update merchant: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error updating merchant: $e');
      }
      throw Exception('Unexpected error updating merchant: $e');
    }
  }

  // Delete merchant
  Future<void> deleteMerchant(String merchantId) async {
    try {
      await _apiService.delete('/api/v1/merchants/$merchantId');

      if (kDebugMode) {
        print('Merchant deleted successfully');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error deleting merchant: ${e.message}');
      }
      throw Exception('Cannot delete merchant: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error deleting merchant: $e');
      }
      throw Exception('Unexpected error deleting merchant: $e');
    }
  }

  // Regenerate API key for merchant
  Future<ApiKeyRegenerationResponse> regenerateApiKey(String merchantId) async {
    try {
      final response = await _apiService.post(
        '/api/v1/merchants/$merchantId/regenerate-api-key',
      );

      if (kDebugMode) {
        print('Regenerate API key response: ${response.data}');
      }

      return ApiKeyRegenerationResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error regenerating API key: ${e.message}');
      }
      throw Exception('Cannot regenerate API key: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error regenerating API key: $e');
      }
      throw Exception('Unexpected error regenerating API key: $e');
    }
  }

  // Toggle merchant active status
  Future<Merchant> toggleMerchantStatus(
    String merchantId,
    bool isActive,
  ) async {
    final request = MerchantUpdateRequest(isActive: isActive);
    return updateMerchant(merchantId, request);
  }

  // Search merchants
  Future<MerchantListResponse> searchMerchants(String query) async {
    return getMerchants(search: query);
  }
}
