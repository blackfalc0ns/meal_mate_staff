import 'package:dio/dio.dart';

import '../errors/api_exception_mapper.dart';
import 'failures.dart';

sealed class ApiResult<T> {}

class ApiSuccessResult<T> extends ApiResult<T> {
  ApiSuccessResult({required this.data});

  final T data;
}

class ApiErrorResult<T> extends ApiResult<T> {
  ApiErrorResult({required this.failure});

  final Failure failure;
}

Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() apiCall) async {
  try {
    return ApiSuccessResult<T>(data: await apiCall());
  } on DioException catch (error) {
    return ApiErrorResult<T>(
      failure: ServerFailure.fromDioError(dioException: error),
    );
  } catch (error) {
    return ApiErrorResult<T>(
      failure: Failure.fromException(ApiExceptionMapper.fromError(error)),
    );
  }
}

Future<ApiResult<T>> safeLocalCall<T>(Future<T> Function() localCall) async {
  try {
    return ApiSuccessResult<T>(data: await localCall());
  } catch (error) {
    return ApiErrorResult<T>(
      failure: Failure.fromException(ApiExceptionMapper.fromError(error)),
    );
  }
}
