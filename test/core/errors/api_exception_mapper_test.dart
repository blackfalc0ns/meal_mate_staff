import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception_mapper.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';

void main() {
  test('HTML maintenance response uses the status fallback message', () {
    final response = Response<String>(
      requestOptions: RequestOptions(path: '/driver-registration'),
      statusCode: 503,
      data:
          '<!doctype html><html><title>Updating</title>'
          '<p>MealMate API is updating.</p></html>',
      headers: Headers.fromMap({
        Headers.contentTypeHeader: ['text/html; charset=utf-8'],
      }),
    );

    final exception = ApiExceptionMapper.fromResponse(response);

    expect(exception.errorType, ApiErrorType.serviceUnavailable);
    expect(exception.message, 'Service unavailable');
    expect(exception.message, isNot(contains('<html>')));
  });

  group('backendErrorCode extraction', () {
    test('extracts extensions.code when present in ProblemDetails', () {
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
        statusCode: 404,
        data: {
          'title': 'غير موجود',
          'status': 404,
          'detail': 'تعذر إكمال الطلب. يرجى المحاولة مرة أخرى.',
          'extensions': {'code': 'DriverMap.StopNotFound'},
        },
      );

      final exception = ApiExceptionMapper.fromResponse(response);

      expect(exception.errorType, ApiErrorType.notFound);
      expect(exception.backendErrorCode, 'DriverMap.StopNotFound');
    });

    test('extracts extensions.code for DriverTrip.NotFound', () {
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/v1/driver/map/route'),
        statusCode: 404,
        data: {
          'title': 'غير موجود',
          'status': 404,
          'extensions': {'code': 'DriverTrip.NotFound'},
        },
      );

      final exception = ApiExceptionMapper.fromResponse(response);

      expect(exception.backendErrorCode, 'DriverTrip.NotFound');
    });

    test('falls back to root-level code if extensions is absent or not a map', () {
      final responseWithRootCode = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/test'),
        statusCode: 400,
        data: {
          'errorCode': 'AUTH_INVALID_TOKEN',
          'extensions': 'not-a-map',
        },
      );

      final exception = ApiExceptionMapper.fromResponse(responseWithRootCode);
      expect(exception.backendErrorCode, 'AUTH_INVALID_TOKEN');
    });

    test('returns null when code is empty or missing', () {
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/test'),
        statusCode: 400,
        data: {
          'title': 'Error',
          'extensions': {'code': '   '},
        },
      );

      final exception = ApiExceptionMapper.fromResponse(response);
      expect(exception.backendErrorCode, isNull);
    });

    test('extracts detail as display message from ProblemDetails', () {
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/v1/driver/orders/123/report-issue'),
        statusCode: 400,
        data: {
          'title': 'Bad Request',
          'status': 400,
          'detail': 'تفاصيل الخطأ بالعربية',
          'code': 'VALIDATION_FAILED',
        },
      );

      final exception = ApiExceptionMapper.fromResponse(response);
      expect(exception.message, 'تفاصيل الخطأ بالعربية');
      expect(exception.backendErrorCode, 'VALIDATION_FAILED');
    });

    test('ServerFailure extracts code from extensions.code and message from detail', () {
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/v1/dispatcher/reassignment-requests/123/accept'),
        statusCode: 409,
        data: {
          'title': 'Conflict',
          'status': 409,
          'detail': 'Reassignment request is already decided.',
          'extensions': {'code': 'REASSIGNMENT_ALREADY_DECIDED'},
        },
      );

      final failure = ServerFailure.fromResponse(response);
      expect(failure.code, 'REASSIGNMENT_ALREADY_DECIDED');
      expect(failure.errorMessage, 'Reassignment request is already decided.');
    });

    test('ServerFailure extracts code from root-level code and message from detail', () {
      final response = Response<Map<String, dynamic>>(
        requestOptions: RequestOptions(path: '/api/v1/driver/orders/123/request-reassignment'),
        statusCode: 409,
        data: {
          'title': 'Conflict',
          'status': 409,
          'detail': 'يوجد طلب إعادة تعيين نشط بالفعل',
          'code': 'driver.reassignment.request_already_active',
        },
      );

      final failure = ServerFailure.fromResponse(response);
      expect(failure.code, 'driver.reassignment.request_already_active');
      expect(failure.errorMessage, 'يوجد طلب إعادة تعيين نشط بالفعل');
    });
  });
}


