// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message';
}

// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});

  @override
  String toString() => 'NetworkException: $message';
}

// API related exceptions
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(super.message, {this.statusCode, super.code});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {super.code});

  @override
  String toString() => 'AuthException: $message';
}

// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException(super.message, {this.errors, super.code});

  @override
  String toString() => 'ValidationException: $message';
}

// Server related exceptions
class ServerException extends AppException {
  const ServerException(super.message, {super.code});

  @override
  String toString() => 'ServerException: $message';
}

// Cache related exceptions
class CacheException extends AppException {
  const CacheException(super.message, {super.code});

  @override
  String toString() => 'CacheException: $message';
}

// Storage related exceptions
class StorageException extends AppException {
  const StorageException(super.message, {super.code});

  @override
  String toString() => 'StorageException: $message';
}

// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});

  @override
  String toString() => 'PermissionException: $message';
}

// QR Scanner related exceptions
class QRScannerException extends AppException {
  const QRScannerException(super.message, {super.code});

  @override
  String toString() => 'QRScannerException: $message';
}

// File related exceptions
class FileException extends AppException {
  const FileException(super.message, {super.code});

  @override
  String toString() => 'FileException: $message';
} 