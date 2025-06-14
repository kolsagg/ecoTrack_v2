import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../core/errors/exceptions.dart';
import '../models/receipt/receipt_model.dart';
import '../models/receipt/receipt_requests.dart';
import '../models/expense/expense_model.dart';
import '../services/auth_service.dart';

class ReceiptService {
  final AuthService _authService;
  final Dio _dio;

  ReceiptService(this._authService, this._dio);

  // QR Code Scanning
  Future<QrScanResponse> scanQrCode(String qrData) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final request = QrScanRequest(qrData: qrData);
      
      final response = await _dio.post(
        '/api/v1/receipts/scan',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return QrScanResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'QR code scanning failed',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error during QR code scanning: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error during QR code scanning: $e');
    }
  }

  // Create Expense (Manual Entry) - This creates both receipt and expense
  Future<Expense> createExpense(CreateExpenseRequest request) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.post(
        '/api/v1/expenses',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to create expense',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error creating expense: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error creating expense: $e');
    }
  }

  // Get Receipts List with Filtering and Pagination
  Future<ReceiptsListResponse> getReceipts({
    int page = 1,
    int perPage = 20,
    String? merchantName,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (merchantName != null && merchantName.isNotEmpty) {
        queryParams['merchant_name'] = merchantName;
      }
      if (startDate != null) {
        queryParams['start_date'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['end_date'] = endDate.toIso8601String();
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        '/api/v1/receipts',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return ReceiptsListResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch receipts',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching receipts: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching receipts: $e');
    }
  }

  // Get Receipt Details
  Future<Receipt> getReceiptDetails(String receiptId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.get(
        '/api/v1/receipts/$receiptId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Receipt.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch receipt details',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching receipt details: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching receipt details: $e');
    }
  }

  // Get Public Receipt
  Future<Receipt> getPublicReceipt(String receiptId) async {
    try {
      final response = await _dio.get('/api/v1/receipts/public/$receiptId');

      return Receipt.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to fetch public receipt',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error fetching public receipt: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error fetching public receipt: $e');
    }
  }

  // Get Receipt Web View URL
  String getReceiptWebViewUrl(String receiptId) {
    return '${ApiConfig.baseUrl}/api/v1/receipts/receipt/$receiptId';
  }

  // Share Receipt (Make Public)
  Future<Receipt> shareReceipt(String receiptId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      final response = await _dio.post(
        '/api/v1/receipts/$receiptId/share',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Receipt.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to share receipt',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else {
        throw NetworkException('Error sharing receipt: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error sharing receipt: $e');
    }
  }

  // Delete Receipt
  Future<void> deleteReceipt(String receiptId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw const AuthException('Token not found');
      }

      await _dio.delete(
        '/api/v1/receipts/$receiptId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null && 
          e.response!.statusCode != 200 && 
          e.response!.statusCode != 204) {
        final error = e.response!.data;
        throw ApiException(
          error['message'] ?? 'Failed to delete receipt',
          statusCode: e.response!.statusCode ?? 500,
        );
      } else if (e.response == null) {
        throw NetworkException('Error deleting receipt: ${e.message}');
      }
    } catch (e) {
      throw NetworkException('Error deleting receipt: $e');
    }
  }
} 