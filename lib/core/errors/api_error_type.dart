import 'package:flutter/widgets.dart';

import '../extensions/extensions.dart';

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

  String localizedMessage(BuildContext context) {
    final l10n = context.localization;
    return switch (this) {
      ApiErrorType.noInternetConnection => l10n.noInternetConnection,
      ApiErrorType.connectionTimeout => l10n.connectionTimeout,
      ApiErrorType.receiveTimeout => l10n.receiveTimeout,
      ApiErrorType.sendTimeout => l10n.sendTimeout,
      ApiErrorType.requestTimeout => l10n.requestTimeout,
      ApiErrorType.serverError ||
      ApiErrorType.internalServerError ||
      ApiErrorType.badGateway ||
      ApiErrorType.serviceUnavailable ||
      ApiErrorType.gatewayTimeout => l10n.serverError,
      ApiErrorType.unauthorized => l10n.unauthorized,
      ApiErrorType.forbidden => l10n.forbidden,
      ApiErrorType.notFound => l10n.notFound,
      ApiErrorType.conflict => l10n.conflict,
      ApiErrorType.validationError => l10n.validationError,
      ApiErrorType.tooManyRequests => l10n.tooManyRequests,
      ApiErrorType.cancelled => l10n.cancelled,
      ApiErrorType.unknown => l10n.unknownError,
      ApiErrorType.badRequest ||
      ApiErrorType.other => l10n.somethingWentWrong,
    };
  }
}
