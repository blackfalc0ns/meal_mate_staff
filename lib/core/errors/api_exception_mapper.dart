import 'package:dio/dio.dart';

import '../network/failures.dart';
import 'api_error_type.dart';
import 'api_exception.dart';

class ApiExceptionMapper {
  const ApiExceptionMapper._();

  static ApiException fromFailure(Failure failure) => failure.exception;

  static ApiException fromDioException(DioException dioException) {
    return switch (dioException.type) {
      DioExceptionType.connectionTimeout => _exception(
        ApiErrorType.connectionTimeout,
      ),
      DioExceptionType.sendTimeout => _exception(ApiErrorType.sendTimeout),
      DioExceptionType.receiveTimeout => _exception(
        ApiErrorType.receiveTimeout,
      ),
      DioExceptionType.cancel => _exception(ApiErrorType.cancelled),
      DioExceptionType.connectionError => _exception(
        ApiErrorType.noInternetConnection,
      ),
      DioExceptionType.badResponse => fromResponse(dioException.response),
      _ => _exception(ApiErrorType.unknown),
    };
  }

  static ApiException fromResponse(Response<dynamic>? response) {
    if (response == null) return _exception(ApiErrorType.serverError);

    final errorType = _mapStatusCode(response.statusCode);
    final backendMessage = _extractBackendMessage(response.data);

    return ApiException(
      errorType: errorType,
      message: backendMessage ?? errorType.message,
      statusCode: response.statusCode,
      response: response.data,
      backendErrorCode: _extractBackendErrorCode(response.data),
    );
  }

  static ApiException fromError(Object error) {
    if (error is ApiException) return error;
    return ApiException(
      errorType: ApiErrorType.unknown,
      message: ApiErrorType.unknown.message,
      response: error,
    );
  }

  static ApiException _exception(ApiErrorType errorType) {
    return ApiException(errorType: errorType, message: errorType.message);
  }

  static ApiErrorType _mapStatusCode(int? statusCode) {
    return switch (statusCode) {
      400 => ApiErrorType.badRequest,
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      408 => ApiErrorType.requestTimeout,
      409 => ApiErrorType.conflict,
      422 => ApiErrorType.validationError,
      429 => ApiErrorType.tooManyRequests,
      500 => ApiErrorType.internalServerError,
      502 => ApiErrorType.badGateway,
      503 => ApiErrorType.serviceUnavailable,
      504 => ApiErrorType.gatewayTimeout,
      _ when statusCode != null && statusCode >= 500 =>
        ApiErrorType.serverError,
      _ when statusCode != null && statusCode >= 400 => ApiErrorType.badRequest,
      _ => ApiErrorType.unknown,
    };
  }

  static String? _extractBackendMessage(Object? data) {
    if (data is Map) {
      for (final key in const [
        'detail',
        'message',
        'message_en',
        'message_ar',
        'error',
        'title',
      ]) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data.trim();
    return null;
  }

  static String? _extractBackendErrorCode(Object? data) {
    if (data is Map) {
      for (final key in const ['errorCode', 'code', 'error_code', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    }
    return null;
  }
}
