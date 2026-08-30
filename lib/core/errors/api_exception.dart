import 'api_error_type.dart';

class ApiException implements Exception {
  const ApiException({
    required this.errorType,
    required this.message,
    this.statusCode,
    this.response,
    this.backendErrorCode,
  });

  final ApiErrorType errorType;
  final String message;
  final int? statusCode;
  final Object? response;
  final String? backendErrorCode;

  @override
  String toString() => message;
}
