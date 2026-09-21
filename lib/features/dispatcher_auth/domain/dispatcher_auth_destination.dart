import '../../../../core/errors/api_error_type.dart';
import '../../../../core/errors/api_exception.dart';

sealed class DispatcherAuthDestination {
  const DispatcherAuthDestination();
}

class DispatcherFirstTimeOtpDestination extends DispatcherAuthDestination {
  const DispatcherFirstTimeOtpDestination({
    required this.phone,
    this.fullName,
    this.restaurantName,
  });

  final String phone;
  final String? fullName;
  final String? restaurantName;
}

class DispatcherPasswordLoginDestination extends DispatcherAuthDestination {
  const DispatcherPasswordLoginDestination({
    required this.phone,
    this.fullName,
    this.restaurantName,
  });

  final String phone;
  final String? fullName;
  final String? restaurantName;
}

class DispatcherAccountNotFoundDestination extends DispatcherAuthDestination {
  const DispatcherAccountNotFoundDestination({
    required this.phone,
    this.exception = const ApiException(
      errorType: ApiErrorType.notFound,
      message:
          'هذا الرقم غير مسجل كمسؤول توصيل. يرجى التواصل مع إدارة المطعم لإضافتك أولاً.',
      statusCode: 404,
    ),
  });

  final String phone;
  final ApiException exception;
}

class DispatcherErrorDestination extends DispatcherAuthDestination {
  const DispatcherErrorDestination({required this.exception});

  final ApiException exception;
}

class DispatcherHomeDestination extends DispatcherAuthDestination {
  const DispatcherHomeDestination();
}
