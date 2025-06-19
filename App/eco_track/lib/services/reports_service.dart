import 'package:dio/dio.dart';
import '../core/errors/exceptions.dart';
import '../models/report/report_models.dart';
import '../services/auth_service.dart';

class ReportsService {
  final AuthService _authService;
  final Dio _dio;

  ReportsService({
    required AuthService authService,
    required Dio dio,
  }) : _authService = authService,
       _dio = dio;

  // Get Category Distribution
  Future<CategoryDistributionResponse> getCategoryDistribution({
    required int year,
    required int month,
    String chartType = 'donut',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final request = CategoryDistributionRequest(
        year: year,
        month: month,
        chartType: chartType,
      );

      final response = await _dio.post(
        '/api/v1/reports/category-distribution',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return CategoryDistributionResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch category distribution',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching category distribution: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching category distribution: $e');
    }
  }

  // Get Spending Trends
  Future<SpendingTrendsResponse> getSpendingTrends({
    required String period, // '3_months', '6_months', '1_year'
    String chartType = 'line',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final request = SpendingTrendsRequest(
        period: period,
        chartType: chartType,
      );

      final response = await _dio.post(
        '/api/v1/reports/spending-trends',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return SpendingTrendsResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch spending trends',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching spending trends: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching spending trends: $e');
    }
  }

  // Get Budget vs Actual
  Future<BudgetVsActualResponse> getBudgetVsActual({
    required int year,
    required int month,
    String chartType = 'bar',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final request = BudgetVsActualRequest(
        year: year,
        month: month,
        chartType: chartType,
      );

      final response = await _dio.post(
        '/api/v1/reports/budget-vs-actual',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return BudgetVsActualResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch budget vs actual',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching budget vs actual: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching budget vs actual: $e');
    }
  }

  // Export Report
  Future<String> exportReport(ReportExportRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{
        'format': request.format,
        'report_type': request.reportType,
      };

      if (request.dateRange != null) {
        queryParams['start_date'] = request.dateRange!.startDate.toIso8601String();
        queryParams['end_date'] = request.dateRange!.endDate.toIso8601String();
      }

      if (request.filters != null) {
        request.filters!.forEach((key, value) {
          queryParams[key] = value;
        });
      }

      final response = await _dio.get(
        '/api/v1/reports/export',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Return the raw response data as string (CSV or JSON)
      if (response.data is String) {
        return response.data;
      } else {
        // If JSON, convert to string
        return response.data.toString();
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to export report',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error exporting report: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error exporting report: $e');
    }
  }


} 