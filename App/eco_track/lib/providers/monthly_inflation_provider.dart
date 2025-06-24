import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/api_config.dart';
import '../models/monthly_inflation.dart';

class MonthlyInflationNotifier extends StateNotifier<MonthlyInflationState> {
  MonthlyInflationNotifier() : super(const MonthlyInflationState());

  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> loadMonthlyInflation({
    int? year,
    int? month,
    String? productName,
    String? sortBy,
    String? order,
    int? limit,
  }) async {
    try {
      state = state.copyWith(
        isLoading: true,
        error: null,
        selectedYear: year,
        selectedMonth: month,
        searchQuery: productName ?? '',
        sortBy: sortBy ?? 'inflation_percentage',
        order: order ?? 'desc',
      );

      final token = await _secureStorage.read(key: 'auth_token');
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      final Map<String, dynamic> queryParams = {};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;
      if (productName != null && productName.isNotEmpty) {
        queryParams['product_name'] = productName;
      }
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (order != null) queryParams['order'] = order;
      if (limit != null) queryParams['limit'] = limit;

      // Debug information
      print('Monthly Inflation API Request:');
      print('URL: ${ApiConfig.apiBaseUrl}/reports/monthly-inflation');
      print('Query Parameters: $queryParams');

      final response = await _dio.get(
        '${ApiConfig.apiBaseUrl}/reports/monthly-inflation',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Monthly Inflation API Response:');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is List) {
          final List<MonthlyInflation> inflationData = responseData
              .map((json) => MonthlyInflation.fromJson(json))
              .toList();

          print('Parsed ${inflationData.length} inflation records');
          state = state.copyWith(data: inflationData, isLoading: false);
        } else {
          throw Exception(
            'Unexpected response format. Expected array but got ${responseData.runtimeType}',
          );
        }
      } else {
        throw Exception(
          'API request failed with status ${response.statusCode}: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error occurred';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server response timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage =
            'Cannot connect to server. Please check your internet connection.';
      } else if (e.response != null) {
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 401:
            errorMessage = 'Authentication failed. Please login again.';
            break;
          case 403:
            errorMessage =
                'Access denied. You don\'t have permission to view this data.';
            break;
          case 404:
            errorMessage = 'Monthly inflation data endpoint not found.';
            break;
          case 500:
            errorMessage = 'Server error. Please try again later.';
            break;
          default:
            errorMessage =
                'API error (${statusCode}): ${e.response?.statusMessage ?? 'Unknown error'}';
        }
      }

      print('Monthly Inflation API Error: $errorMessage');
      print('DioException details: $e');
      state = state.copyWith(isLoading: false, error: errorMessage);
    } catch (e) {
      final errorMessage = 'Unexpected error: ${e.toString()}';
      print('Monthly Inflation Error: $errorMessage');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  void updateFilters({
    int? year,
    int? month,
    String? searchQuery,
    String? sortBy,
    String? order,
  }) {
    loadMonthlyInflation(
      year: year ?? state.selectedYear,
      month: month ?? state.selectedMonth,
      productName: searchQuery ?? state.searchQuery,
      sortBy: sortBy ?? state.sortBy,
      order: order ?? state.order,
    );
  }

  void clearFilters() {
    loadMonthlyInflation();
  }
}

final monthlyInflationProvider =
    StateNotifierProvider<MonthlyInflationNotifier, MonthlyInflationState>(
      (ref) => MonthlyInflationNotifier(),
    );
