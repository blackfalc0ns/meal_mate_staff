import '../../../../core/errors/api_error_type.dart';
import '../../../../core/errors/api_exception.dart';
import '../../auth/domain/entities/phone_lookup_result_entity.dart';
import 'dispatcher_auth_destination.dart';

DispatcherAuthDestination resolveDispatcherAuthDestination(
  PhoneLookupResultEntity lookup,
) {
  if (!lookup.exists) {
    return DispatcherAccountNotFoundDestination(
      phone: lookup.phone,
      exception: const ApiException(
        errorType: ApiErrorType.notFound,
        message:
            'هذا الرقم غير مسجل كمسؤول توصيل. يرجى التواصل مع إدارة المطعم لإضافتك أولاً.',
        statusCode: 404,
      ),
    );
  }

  if (lookup.isFirstTimeSetup) {
    return DispatcherFirstTimeOtpDestination(
      phone: lookup.phone,
      fullName: lookup.fullName,
      restaurantName: lookup.restaurantName,
    );
  }

  return DispatcherPasswordLoginDestination(
    phone: lookup.phone,
    fullName: lookup.fullName,
    restaurantName: lookup.restaurantName,
  );
}
