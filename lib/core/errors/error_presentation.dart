import 'api_error_type.dart';

class ErrorPresentation {
  const ErrorPresentation({
    required this.title,
    required this.message,
    required this.type,
  });

  final String title;
  final String message;
  final ApiErrorType type;
}
