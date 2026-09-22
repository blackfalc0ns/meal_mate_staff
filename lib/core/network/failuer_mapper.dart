import 'package:flutter/widgets.dart';

import '../errors/api_error_type.dart';
import '../extensions/extensions.dart';

String mapFailureMessage(BuildContext context, String message) {
  final l10n = context.localization;
  return switch (message) {
    'No internet connection' => l10n.noInternetConnection,
    'Connection timeout' => l10n.connectionTimeout,
    'Receive timeout' => l10n.receiveTimeout,
    'Send timeout' => l10n.sendTimeout,
    'Request timeout' => l10n.requestTimeout,
    'Server error' => l10n.serverError,
    'Something went wrong' => l10n.somethingWentWrong,
    _ => message,
  };
}

String mapApiErrorType(BuildContext context, ApiErrorType type) {
  return type.localizedMessage(context);
}
