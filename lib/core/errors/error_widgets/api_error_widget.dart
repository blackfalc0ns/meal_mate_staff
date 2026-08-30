import 'package:flutter/material.dart';

import '../api_error_type.dart';
import '../api_exception.dart';
import 'client_error_widget.dart';
import 'generic_error_widget.dart';
import 'no_internet_error_widget.dart';
import 'server_error_widget.dart';
import 'timeout_error_widget.dart';

class ApiErrorWidget extends StatelessWidget {
  const ApiErrorWidget({
    super.key,
    required this.exception,
    this.onRetry,
    this.onGoBack,
    this.onContactSupport,
    this.onCheckConnection,
  });

  final ApiException exception;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final VoidCallback? onContactSupport;
  final VoidCallback? onCheckConnection;

  @override
  Widget build(BuildContext context) {
    return switch (exception.errorType) {
      ApiErrorType.noInternetConnection => NoInternetErrorWidget(
        onRetry: onRetry,
        onCheckConnection: onCheckConnection,
      ),
      ApiErrorType.connectionTimeout ||
      ApiErrorType.receiveTimeout ||
      ApiErrorType.sendTimeout ||
      ApiErrorType.requestTimeout => TimeoutErrorWidget(
        timeoutType: exception.errorType,
        onRetry: onRetry,
      ),
      ApiErrorType.serverError ||
      ApiErrorType.internalServerError ||
      ApiErrorType.badGateway ||
      ApiErrorType.serviceUnavailable ||
      ApiErrorType.gatewayTimeout => ServerErrorWidget(
        serverErrorType: exception.errorType,
        statusCode: exception.statusCode,
        serverMessage: exception.message,
        onRetry: onRetry,
        onContactSupport: onContactSupport,
      ),
      ApiErrorType.badRequest ||
      ApiErrorType.unauthorized ||
      ApiErrorType.forbidden ||
      ApiErrorType.notFound ||
      ApiErrorType.conflict ||
      ApiErrorType.validationError ||
      ApiErrorType.tooManyRequests => ClientErrorWidget(
        clientErrorType: exception.errorType,
        statusCode: exception.statusCode,
        serverMessage: exception.message,
        onRetry: onRetry,
        onGoBack: onGoBack,
      ),
      _ => GenericErrorWidget(
        errorType: exception.errorType,
        serverMessage: exception.message,
        onRetry: onRetry,
        onGoBack: onGoBack,
      ),
    };
  }
}
