import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception_mapper.dart';

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
}
