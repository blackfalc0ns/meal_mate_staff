enum ApiErrorType {
  noInternetConnection,
  connectionTimeout,
  receiveTimeout,
  sendTimeout,
  serverError,
  internalServerError,
  badGateway,
  serviceUnavailable,
  gatewayTimeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  requestTimeout,
  conflict,
  validationError,
  tooManyRequests,
  cancelled,
  unknown,
  other,
}

extension ApiErrorTypeExtension on ApiErrorType {
  String get message {
    return switch (this) {
      ApiErrorType.noInternetConnection => 'No internet connection',
      ApiErrorType.connectionTimeout => 'Connection timeout',
      ApiErrorType.receiveTimeout => 'Receive timeout',
      ApiErrorType.sendTimeout => 'Send timeout',
      ApiErrorType.serverError => 'Server error',
      ApiErrorType.internalServerError => 'Internal server error',
      ApiErrorType.badGateway => 'Bad gateway',
      ApiErrorType.serviceUnavailable => 'Service unavailable',
      ApiErrorType.gatewayTimeout => 'Gateway timeout',
      ApiErrorType.badRequest => 'Bad request',
      ApiErrorType.unauthorized => 'Unauthorized',
      ApiErrorType.forbidden => 'Forbidden',
      ApiErrorType.notFound => 'Not found',
      ApiErrorType.requestTimeout => 'Request timeout',
      ApiErrorType.conflict => 'Conflict',
      ApiErrorType.validationError => 'Validation error',
      ApiErrorType.tooManyRequests => 'Too many requests',
      ApiErrorType.cancelled => 'Request cancelled',
      ApiErrorType.unknown => 'Unknown error',
      ApiErrorType.other => 'Something went wrong',
    };
  }
}
