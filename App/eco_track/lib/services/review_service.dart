import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../core/errors/exceptions.dart';
import '../models/review/review_models.dart';
import 'auth_service.dart';

class ReviewService {
  final AuthService _authService;
  final Dio _dio;

  ReviewService({required AuthService authService, required Dio dio})
    : _authService = authService,
      _dio = dio;

  // Create Merchant Review
  Future<ReviewSuccessResponse> createMerchantReview(
    String merchantId,
    MerchantReviewCreateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.post(
        '${ApiConfig.reviewsEndpoint}/merchants/$merchantId/reviews',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ReviewSuccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create merchant review',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error creating merchant review: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error creating merchant review: $e');
    }
  }

  // Get Merchant Reviews
  Future<MerchantReviewsResponse> getMerchantReviews(
    String merchantId, {
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('🌐 API Call - Get Merchant Reviews: $merchantId');
      final token = await _authService.getToken();

      final queryParams = <String, dynamic>{};
      if (page != null && limit != null) {
        queryParams['offset'] = (page - 1) * limit;
      } else if (page != null) {
        queryParams['offset'] = (page - 1) * 10; // default limit 10
      }
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print(
        '🔗 URL: ${ApiConfig.reviewsEndpoint}/merchants/$merchantId/reviews',
      );
      print('📋 Query Params: $queryParams');
      print('🔑 Has Token: ${token != null}');

      final response = await _dio.get(
        '${ApiConfig.reviewsEndpoint}/merchants/$merchantId/reviews',
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      print('✅ Reviews API Response Status: ${response.statusCode}');
      return MerchantReviewsResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Reviews API Error: ${e.message}');
      print('📄 Response Data: ${e.response?.data}');
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get merchant reviews',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting merchant reviews: ${e.message}');
      }
    } catch (e) {
      print('❌ Reviews General Error: $e');
      throw NetworkException('Error getting merchant reviews: $e');
    }
  }

  // Get Merchant Rating
  Future<MerchantRatingResponse> getMerchantRating(String merchantId) async {
    try {
      print('🌐 API Call - Get Merchant Rating: $merchantId');
      print(
        '🔗 URL: ${ApiConfig.reviewsEndpoint}/merchants/$merchantId/rating',
      );

      final response = await _dio.get(
        '${ApiConfig.reviewsEndpoint}/merchants/$merchantId/rating',
      );

      print('✅ Rating API Response Status: ${response.statusCode}');
      return MerchantRatingResponse.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Rating API Error: ${e.message}');
      print('📄 Response Data: ${e.response?.data}');
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get merchant rating',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting merchant rating: ${e.message}');
      }
    } catch (e) {
      print('❌ Rating General Error: $e');
      throw NetworkException('Error getting merchant rating: $e');
    }
  }

  // Update Review
  Future<ReviewSuccessResponse> updateReview(
    String reviewId,
    MerchantReviewUpdateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.put(
        '${ApiConfig.reviewsEndpoint}/reviews/$reviewId',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ReviewSuccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to update review',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error updating review: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error updating review: $e');
    }
  }

  // Delete Review
  Future<void> deleteReview(String reviewId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      await _dio.delete(
        '${ApiConfig.reviewsEndpoint}/reviews/$reviewId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to delete review',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error deleting review: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deleting review: $e');
    }
  }

  // Create Receipt Review (Authenticated)
  Future<ReviewSuccessResponse> createReceiptReview(
    String receiptId,
    ReceiptReviewCreateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.post(
        '${ApiConfig.reviewsEndpoint}/receipts/$receiptId/review',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ReviewSuccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create receipt review',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error creating receipt review: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error creating receipt review: $e');
    }
  }

  // Create Anonymous Receipt Review
  Future<ReviewSuccessResponse> createAnonymousReceiptReview(
    String receiptId,
    AnonymousReceiptReviewCreateRequest request,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.reviewsEndpoint}/receipts/$receiptId/review/anonymous',
        data: request.toJson(),
      );

      return ReviewSuccessResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create anonymous receipt review',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          'Error creating anonymous receipt review: ${e.message}',
        );
      }
    } catch (e) {
      throw NetworkException('Error creating anonymous receipt review: $e');
    }
  }

  // Get Review Categories
  Future<ReviewCategoriesResponse> getReviewCategories() async {
    try {
      final response = await _dio.get(
        '${ApiConfig.reviewsEndpoint}/categories',
      );

      return ReviewCategoriesResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get review categories',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting review categories: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error getting review categories: $e');
    }
  }

  // Mark Review as Helpful
  Future<void> markReviewAsHelpful(String reviewId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      await _dio.post(
        '${ApiConfig.reviewsEndpoint}/reviews/$reviewId/helpful',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to mark review as helpful',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error marking review as helpful: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error marking review as helpful: $e');
    }
  }

  // Get User Reviews
  Future<List<Review>> getUserReviews({
    int? page,
    int? limit,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('🌐 API Call - Get User Reviews');
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      // API offset kullanıyor, page değil
      if (page != null && limit != null) {
        queryParams['offset'] = (page - 1) * limit;
      } else if (page != null) {
        queryParams['offset'] = (page - 1) * 10; // default limit 10
      }
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      print('🔗 URL: ${ApiConfig.reviewsEndpoint}/user/reviews');
      print('📋 Query Params: $queryParams');

      // Test için mock data döndür
      print('📝 Returning mock user reviews data');
      await Future.delayed(
        const Duration(seconds: 1),
      ); // API çağrısını simüle et

      return [
        Review(
          id: 'review_1',
          userId: 'user_123',
          merchantId: '550e8400-e29b-41d4-a716-446655440000',
          rating: 5,
          comment: 'Harika bir deneyimdi! Çok memnun kaldım.',
          reviewerName: 'Test User',
          isAnonymous: false,
          helpfulCount: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: 'review_2',
          userId: 'user_123',
          merchantId: '550e8400-e29b-41d4-a716-446655440001',
          rating: 4,
          comment: 'İyi hizmet, fiyatlar uygun.',
          reviewerName: 'Test User',
          isAnonymous: false,
          helpfulCount: 1,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Review(
          id: 'review_3',
          userId: 'user_123',
          merchantId: '550e8400-e29b-41d4-a716-446655440002',
          rating: 3,
          comment: 'Ortalama bir deneyim.',
          reviewerName: 'Anonymous',
          isAnonymous: true,
          helpfulCount: 0,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      // TODO: API'de endpoint hazır olduğunda bu kodu kullan:
      /*
      final response = await _dio.get(
        '${ApiConfig.reviewsEndpoint}/user/reviews',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('✅ User Reviews API Response Status: ${response.statusCode}');
      final reviewsList = (response.data['reviews'] as List<dynamic>?)
          ?.map((item) => Review.fromJson(item as Map<String, dynamic>))
          .toList() ?? [];
      
      return reviewsList;
      */
    } on DioException catch (e) {
      print('❌ User Reviews API Error: ${e.message}');
      print('📄 Response Data: ${e.response?.data}');
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get user reviews',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting user reviews: ${e.message}');
      }
    } catch (e) {
      print('❌ User Reviews General Error: $e');
      throw NetworkException('Error getting user reviews: $e');
    }
  }
}
