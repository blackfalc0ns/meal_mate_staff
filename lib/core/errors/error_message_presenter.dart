import '../network/failures.dart';
import 'error_presentation.dart';

class ErrorMessagePresenter {
  const ErrorMessagePresenter._();

  static ErrorPresentation fromFailure(Failure failure) {
    return ErrorPresentation(
      title: 'Something went wrong',
      message: failure.errorMessage,
      type: failure.exception.errorType,
    );
  }
}
