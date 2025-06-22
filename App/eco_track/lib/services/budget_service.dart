import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../core/errors/exceptions.dart';
import '../models/budget/budget_models.dart';
import '../models/report/report_models.dart';
import 'auth_service.dart';

class BudgetService {
  final AuthService _authService;
  final Dio _dio;

  BudgetService({required AuthService authService, required Dio dio})
    : _authService = authService,
      _dio = dio;

  // Health Check
  Future<BudgetHealthResponse> getHealth() async {
    try {
      final response = await _dio.get(ApiConfig.budgetHealthEndpoint);
      return BudgetHealthResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Budget health check failed',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          'Error during budget health check: ${e.message}',
        );
      }
    } catch (e) {
      throw NetworkException('Error during budget health check: $e');
    }
  }

  // Create User Budget
  Future<UserBudget> createUserBudget(
    UserBudgetCreateRequest request, {
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.post(
        ApiConfig.budgetEndpoint,
        data: request.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // API response format: {status: "success", budget: {...}}
      final responseData = response.data as Map<String, dynamic>;
      return UserBudget.fromJson(
        responseData['budget'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create user budget',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error creating user budget: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error creating user budget: $e');
    }
  }

  // Get User Budget
  Future<UserBudget?> getUserBudget({int? year, int? month}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        ApiConfig.budgetEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // API response format: {status: "success", budget: {...}}
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['budget'] != null) {
        return UserBudget.fromJson(
          responseData['budget'] as Map<String, dynamic>,
        );
      } else {
        return null;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // 404 durumunda null döndür (budget yok demektir)
        if (e.response!.statusCode == 404) {
          return null;
        }
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get user budget',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting user budget: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error getting user budget: $e');
    }
  }

  // Update User Budget
  Future<UserBudget> updateUserBudget(
    UserBudgetUpdateRequest request, {
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.put(
        ApiConfig.budgetEndpoint,
        data: request.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // API response format: {status: "success", budget: {...}}
      final responseData = response.data as Map<String, dynamic>;
      return UserBudget.fromJson(
        responseData['budget'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to update user budget',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error updating user budget: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error updating user budget: $e');
    }
  }

  // Create Category Budget
  Future<BudgetCategory> createCategoryBudget(
    BudgetCategoryCreateRequest request, {
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.post(
        ApiConfig.budgetCategoriesEndpoint,
        data: request.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return BudgetCategory.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create category budget',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error creating category budget: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error creating category budget: $e');
    }
  }

  // Get Category Budgets
  Future<BudgetCategoriesResponse> getCategoryBudgets({
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      final response = await _dio.get(
        ApiConfig.budgetCategoriesEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return BudgetCategoriesResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get category budgets',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting category budgets: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error getting category budgets: $e');
    }
  }

  // Get Budget Summary
  Future<BudgetSummaryResponse> getBudgetSummary({
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      print('📡 Making request to: ${ApiConfig.budgetSummaryEndpoint}');
      print('📋 Query params: $queryParams');

      final response = await _dio.get(
        ApiConfig.budgetSummaryEndpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Budget Summary Response status: ${response.statusCode}');
      print('📄 Budget Summary Response data: ${response.data}');

      // API response formatını kontrol et
      final responseData = response.data as Map<String, dynamic>;

      // API'den gelen response'u Flutter model'ine uyarla
      if (responseData.containsKey('summary')) {
        final summaryData = responseData['summary'] as Map<String, dynamic>;
        final categoryBudgets =
            responseData['category_budgets'] as List<dynamic>? ?? [];

        // Gerçek spending verilerini al
        final categorySpendingMap = await getCurrentMonthSpendingByCategory(
          year: year,
          month: month,
        );
        double totalSpent = categorySpendingMap.values.fold(
          0.0,
          (sum, amount) => sum + amount,
        );
        double spendingPercentage = 0.0;

        // Total monthly budget'ı al
        final totalMonthlyBudget =
            (summaryData['total_budget'] as num?)?.toDouble() ?? 0.0;

        if (totalMonthlyBudget > 0) {
          spendingPercentage = (totalSpent / totalMonthlyBudget) * 100;
        }

        // Category summaries'i oluştur
        final categorySummaries = categoryBudgets.map<BudgetSummaryItem>((
          budget,
        ) {
          final categoryId = budget['category_id'] as String? ?? '';
          final categoryName = budget['category_name'] as String? ?? '';
          final monthlyLimit =
              (budget['monthly_limit'] as num?)?.toDouble() ?? 0.0;

          // Category name ile spending map'ten harcamayı bul
          final currentSpending = categorySpendingMap[categoryName] ?? 0.0;
          final remainingBudget = monthlyLimit - currentSpending;
          final usagePercentage = monthlyLimit > 0
              ? (currentSpending / monthlyLimit) * 100
              : 0.0;

          print('📊 Budget Category: $categoryName (ID: $categoryId)');
          print(
            '📊 Monthly Limit: ₺$monthlyLimit, Current Spending: ₺$currentSpending',
          );

          return BudgetSummaryItem(
            categoryId: categoryId,
            categoryName: categoryName,
            monthlyLimit: monthlyLimit,
            currentSpending: currentSpending,
            remainingBudget: remainingBudget,
            usagePercentage: usagePercentage,
            isOverBudget: currentSpending > monthlyLimit,
          );
        }).toList();

        final now = DateTime.now();
        return BudgetSummaryResponse(
          totalMonthlyBudget: totalMonthlyBudget,
          totalAllocated:
              (summaryData['total_allocated'] as num?)?.toDouble() ?? 0.0,
          totalSpent: totalSpent,
          remainingBudget: totalMonthlyBudget - totalSpent,
          unallocatedBudget:
              totalMonthlyBudget -
              ((summaryData['total_allocated'] as num?)?.toDouble() ?? 0.0),
          allocationPercentage:
              (summaryData['allocation_percentage'] as num?)?.toDouble() ?? 0.0,
          spendingPercentage: spendingPercentage,
          categoriesOverBudget: categorySummaries
              .where((item) => item.isOverBudget)
              .length,
          categorySummaries: categorySummaries,
          year: year ?? now.year,
          month: month ?? now.month,
        );
      } else {
        // Eski format için fallback
        return BudgetSummaryResponse.fromJson(responseData);
      }
    } on DioException catch (e) {
      print(
        '❌ Budget Summary DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get budget summary',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting budget summary: ${e.message}');
      }
    } catch (e) {
      print('❌ Budget Summary General error: $e');
      throw NetworkException('Error getting budget summary: $e');
    }
  }

  // Apply Budget Allocation
  Future<BudgetAllocationResponse> applyBudgetAllocation(
    BudgetAllocationRequest request, {
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      print(
        '📡 Making allocation request to: ${ApiConfig.budgetApplyAllocationEndpoint}',
      );
      print('📄 Request data: ${request.toJson()}');
      print('📋 Query params: $queryParams');

      final response = await _dio.post(
        ApiConfig.budgetApplyAllocationEndpoint,
        data: request.toJson(),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Allocation Response status: ${response.statusCode}');
      print('📄 Allocation Response data: ${response.data}');

      return BudgetAllocationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print(
        '❌ Allocation DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to apply budget allocation',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          'Error applying budget allocation: ${e.message}',
        );
      }
    } catch (e) {
      print('❌ Allocation General error: $e');
      throw NetworkException('Error applying budget allocation: $e');
    }
  }

  // Get Budget List (Yeni method)
  Future<BudgetListResponse> getBudgetList({
    int limit = 12,
    int offset = 0,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};

      print('📡 Making request to: ${ApiConfig.budgetListEndpoint}');
      print('📋 Query params: $queryParams');

      final response = await _dio.get(
        ApiConfig.budgetListEndpoint,
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Budget List Response status: ${response.statusCode}');
      print('📄 Budget List Response data: ${response.data}');

      return BudgetListResponse.fromJson(response.data);
    } on DioException catch (e) {
      print(
        '❌ Budget List DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to get budget list',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error getting budget list: ${e.message}');
      }
    } catch (e) {
      print('❌ Budget List General error: $e');
      throw NetworkException('Error getting budget list: $e');
    }
  }

  // Delete Category Budget
  Future<void> deleteCategoryBudget(
    String categoryId, {
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      await _dio.delete(
        '${ApiConfig.budgetCategoriesEndpoint}/$categoryId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to delete category budget',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error deleting category budget: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deleting category budget: $e');
    }
  }

  // Reset All Category Budgets (Delete all user's category budgets)
  Future<void> resetAllCategoryBudgets({int? year, int? month}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      // First get all category budgets
      final categoriesResponse = await getCategoryBudgets(
        year: year,
        month: month,
      );

      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      // Delete each category budget
      for (final category in categoriesResponse.categoryBudgets) {
        await _dio.delete(
          '${ApiConfig.budgetCategoriesEndpoint}/${category.categoryId}',
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to reset category budgets',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          'Error resetting category budgets: ${e.message}',
        );
      }
    } catch (e) {
      throw NetworkException('Error resetting category budgets: $e');
    }
  }

  // Get current month spending by category using category distribution report
  Future<Map<String, double>> getCurrentMonthSpendingByCategory({
    int? year,
    int? month,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final now = DateTime.now();
      final targetYear = year ?? now.year;
      final targetMonth = month ?? now.month;

      print('📊 Fetching category distribution for $targetYear-$targetMonth');

      final request = CategoryDistributionRequest(
        year: targetYear,
        month: targetMonth,
        chartType: 'donut',
      );

      final response = await _dio.post(
        ApiConfig.categoryDistributionEndpoint,
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📊 Category distribution response: ${response.data}');

      final categoryDistribution = CategoryDistributionResponse.fromJson(
        response.data,
      );
      final Map<String, double> categorySpending = {};

      // Convert category distribution data to category spending map
      for (final categoryData in categoryDistribution.data) {
        // Category name'i kullanarak mapping yapıyoruz
        // Gerçek implementasyonda category name -> category ID mapping gerekebilir
        categorySpending[categoryData.label] = categoryData.value;
        print(
          '📊 Category: ${categoryData.label}, Amount: ₺${categoryData.value}',
        );
      }

      print(
        '📊 Total spending from category distribution: ₺${categoryDistribution.totalAmount}',
      );
      print('📊 Category spending map: $categorySpending');

      return categorySpending;
    } catch (e) {
      print('❌ Error fetching category spending: $e');
      return {};
    }
  }
}
