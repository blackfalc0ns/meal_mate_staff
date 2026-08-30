import 'package:flutter/widgets.dart';

import '../errors/api_error_type.dart';

String mapFailureMessage(BuildContext context, String message) {
  return switch (message) {
    'No internet connection' => _localized(
      context,
      ar: 'لا يوجد اتصال بالإنترنت',
      en: message,
    ),
    'Connection timeout' => _localized(
      context,
      ar: 'انتهت مهلة الاتصال',
      en: message,
    ),
    'Server error' => _localized(context, ar: 'حدث خطأ في الخادم', en: message),
    _ => message,
  };
}

String mapApiErrorType(BuildContext context, ApiErrorType type) {
  return mapFailureMessage(context, type.message);
}

String _localized(
  BuildContext context, {
  required String ar,
  required String en,
}) {
  return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}
