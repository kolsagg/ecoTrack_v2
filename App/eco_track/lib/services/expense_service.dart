import 'package:dio/dio.dart';
import '../core/errors/exceptions.dart';
import '../models/expense/expense_model.dart';
import '../services/auth_service.dart';

class ExpenseService {
  final AuthService _authService;
  final Dio _dio;

  ExpenseService({required AuthService authService, required Dio dio})
    : _authService = authService,
      _dio = dio;

  // List Expenses with Filtering and Pagination
  Future<ExpenseListResponse> getExpenses({
    int page = 1,
    int limit = 20,
    String? merchantName,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    double? minAmount,
    double? maxAmount,
    String sortBy = 'expense_date',
    String sortOrder = 'desc',
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      if (merchantName != null && merchantName.isNotEmpty) {
        queryParams['merchant'] = merchantName;
      }
      if (startDate != null) {
        queryParams['date_from'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['date_to'] = endDate.toIso8601String();
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (minAmount != null) {
        queryParams['min_amount'] = minAmount;
      }
      if (maxAmount != null) {
        queryParams['max_amount'] = maxAmount;
      }

      print('📡 Making request to: /api/v1/expenses');
      print('📊 Query params: $queryParams');

      final response = await _dio.get(
        '/api/v1/expenses',
        queryParameters: queryParams,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('✅ Response status: ${response.statusCode}');
      print('📄 Response data type: ${response.data.runtimeType}');
      print('📄 Response data: ${response.data}');

      // API wrapper objesi döndürüyor
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        // Check if it has the expected structure
        if (data.containsKey('expenses')) {
          return ExpenseListResponse.fromJson(data);
        } else {
          // If it's just a single expense or different format
          throw ApiException('Unexpected response format', statusCode: 500);
        }
      } else if (response.data is List) {
        // Fallback: API direkt liste döndürüyor
        final expensesList = (response.data as List)
            .map((item) => Expense.fromJson(item as Map<String, dynamic>))
            .toList();

        return ExpenseListResponse(
          expenses: expensesList,
          total: expensesList.length,
          page: page,
          limit: limit,
          hasNext: expensesList.length == limit,
          hasPrevious: page > 1,
        );
      } else {
        throw ApiException('Unexpected response format', statusCode: 500);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch expenses',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching expenses: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching expenses: $e');
    }
  }

  // Get Expense Detail
  Future<Expense> getExpenseDetail(String expenseId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        '/api/v1/expenses/$expenseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch expense details',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching expense details: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching expense details: $e');
    }
  }

  // Get Expense by Receipt ID
  Future<Expense?> getExpenseByReceiptId(String receiptId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        '/api/v1/expenses',
        queryParameters: {'receipt_id': receiptId, 'limit': 1},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is List && (response.data as List).isNotEmpty) {
        return Expense.fromJson((response.data as List).first);
      }

      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch expense by receipt ID',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException(
          'Error fetching expense by receipt ID: ${e.message}',
        );
      }
    } catch (e) {
      throw NetworkException('Error fetching expense by receipt ID: $e');
    }
  }

  // Update Expense
  Future<Expense> updateExpense(
    String expenseId,
    ExpenseUpdateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.put(
        '/api/v1/expenses/$expenseId',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to update expense',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error updating expense: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error updating expense: $e');
    }
  }

  // Delete Expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      await _dio.delete(
        '/api/v1/expenses/$expenseId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to delete expense',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error deleting expense: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deleting expense: $e');
    }
  }

  // List Expense Items
  Future<List<ExpenseItem>> getExpenseItems(String expenseId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        '/api/v1/expenses/$expenseId/items',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      if (data['items'] != null) {
        return (data['items'] as List)
            .map((item) => ExpenseItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch expense items',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching expense items: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching expense items: $e');
    }
  }

  // Create Expense Item
  Future<ExpenseItem> createExpenseItem(
    String expenseId,
    ExpenseItemCreateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.post(
        '/api/v1/expenses/$expenseId/items',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ExpenseItem.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create expense item',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error creating expense item: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error creating expense item: $e');
    }
  }

  // Update Expense Item
  Future<ExpenseItem> updateExpenseItem(
    String expenseId,
    String itemId,
    ExpenseItemUpdateRequest request,
  ) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.put(
        '/api/v1/expenses/$expenseId/items/$itemId',
        data: request.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      return ExpenseItem.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to update expense item',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error updating expense item: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error updating expense item: $e');
    }
  }

  // Delete Expense Item
  Future<void> deleteExpenseItem(String expenseId, String itemId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      await _dio.delete(
        '/api/v1/expenses/$expenseId/items/$itemId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to delete expense item',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error deleting expense item: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deleting expense item: $e');
    }
  }
}
