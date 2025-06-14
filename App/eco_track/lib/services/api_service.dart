import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../core/errors/exceptions.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    _dio.options.sendTimeout = ApiConfig.sendTimeout;
    _dio.options.headers.addAll(ApiConfig.defaultHeaders);

    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          // This will be handled by individual services
          handler.next(options);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
        onError: (error, handler) {
          final exception = _handleError(error);
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: exception,
            type: error.type,
            response: error.response,
          ));
        },
      ),
    );
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Set auth token
  void setAuthToken(String token) {
    _dio.options.headers[ApiConfig.authHeaderKey] = ApiConfig.authHeaderValue(token);
  }

  // Remove auth token
  void removeAuthToken() {
    _dio.options.headers.remove(ApiConfig.authHeaderKey);
  }

  // Handle errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      
      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');
      
      case DioExceptionType.connectionError:
        return NetworkException('No internet connection. Please check your network settings.');
      
      case DioExceptionType.badCertificate:
        return NetworkException('Certificate verification failed.');
      
      case DioExceptionType.unknown:
        return NetworkException('An unexpected error occurred. Please try again.');
    }
  }

  Exception _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        return ValidationException(
          data?['detail'] ?? 'Invalid request data.',
        );
      
      case 401:
        return AuthException('Authentication failed. Please login again.');
      
      case 403:
        return AuthException('Access denied. You don\'t have permission to perform this action.');
      
      case 404:
        return ApiException('Resource not found.');
      
      case 422:
        return ValidationException(
          data?['detail'] ?? 'Validation failed.',
        );
      
      case 429:
        return ApiException('Too many requests. Please try again later.');
      
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException('Server error. Please try again later.');
      
      default:
        return ApiException(
          data?['detail'] ?? 'An error occurred. Please try again.',
        );
    }
  }
} 