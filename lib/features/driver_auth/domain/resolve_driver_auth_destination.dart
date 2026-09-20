import '../../account_status/domain/account_status_kind.dart';
import '../../auth/domain/entities/phone_lookup_result_entity.dart';
import 'driver_auth_destination.dart';

DriverAuthDestination resolveDriverAuthDestination(
  PhoneLookupResultEntity lookup,
) {
  if (!lookup.exists) {
    return DriverRegistrationDestination(phone: lookup.phone);
  }

  if (lookup.isFirstTimeSetup) {
    return DriverFirstTimeOtpDestination(
      phone: lookup.phone,
      fullName: lookup.fullName,
      restaurantName: lookup.restaurantName,
    );
  }

  final appStatus = lookup.applicationStatus;
  if (appStatus != null && !appStatus.isApproved) {
    final kind = switch (appStatus.stage) {
      2 => AccountStatusKind.moreInformationRequired,
      3 => AccountStatusKind.rejected,
      _ => AccountStatusKind.underReview,
    };
    return DriverAccountStatusDestination(
      kind: kind,
      registrationId: appStatus.registrationId,
      title: appStatus.title,
      subtitle: appStatus.subtitle,
      canResubmit: appStatus.canResubmit,
    );
  }

  return DriverPasswordLoginDestination(
    phone: lookup.phone,
    fullName: lookup.fullName,
    restaurantName: lookup.restaurantName,
  );
}
