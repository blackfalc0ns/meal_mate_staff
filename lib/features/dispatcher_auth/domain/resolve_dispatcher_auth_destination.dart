import '../../auth/domain/entities/phone_lookup_result_entity.dart';
import 'dispatcher_auth_destination.dart';

DispatcherAuthDestination resolveDispatcherAuthDestination(
  PhoneLookupResultEntity lookup,
) {
  if (!lookup.exists) {
    return DispatcherAccountNotFoundDestination(phone: lookup.phone);
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
