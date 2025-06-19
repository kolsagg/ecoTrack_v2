import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/category/category_models.dart';
import '../services/auth_service.dart';

class CategoryService {
  final AuthService _authService;
  final Dio _dio;

  CategoryService(this._authService, this._dio);

  Future<List<CategoryResponse>> getCategories() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.get(
        ApiConfig.categoriesEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      final List<dynamic> jsonList = response.data;
      return jsonList
          .map((json) => CategoryResponse.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<CategoryResponse> createCategory(CategoryCreateRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.post(
        ApiConfig.categoriesEndpoint,
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return CategoryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error creating category: $e');
    }
  }

  Future<CategoryResponse> updateCategory(
    String categoryId,
    CategoryUpdateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _dio.put(
        '${ApiConfig.categoriesEndpoint}/$categoryId',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return CategoryResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      await _dio.delete(
        '${ApiConfig.categoriesEndpoint}/$categoryId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Error deleting category: $e');
    }
  }
} 