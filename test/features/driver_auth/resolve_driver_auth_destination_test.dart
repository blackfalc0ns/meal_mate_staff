import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/staff_application_status_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/driver_auth_destination.dart';
import 'package:meal_mate_delivery/features/driver_auth/domain/resolve_driver_auth_destination.dart';

void main() {
  group('resolveDriverAuthDestination Table-Driven Tests', () {
    test(
      'when driver account does not exist -> returns DriverRegistrationDestination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: false,
          isFirstTimeSetup: false,
          role: UserRole.driver,
          phone: '+96550111222',
        );

        final destination = resolveDriverAuthDestination(lookup);
        expect(destination, isA<DriverRegistrationDestination>());
        expect(
          (destination as DriverRegistrationDestination).phone,
          '+96550111222',
        );
      },
    );

    test(
      'when isFirstTimeSetup is true -> returns DriverFirstTimeOtpDestination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: true,
          role: UserRole.driver,
          phone: '+96550111222',
          fullName: 'Ahmad Driver',
          restaurantName: 'Lab Restaurant',
        );

        final destination = resolveDriverAuthDestination(lookup);
        expect(destination, isA<DriverFirstTimeOtpDestination>());
        final otpDest = destination as DriverFirstTimeOtpDestination;
        expect(otpDest.phone, '+96550111222');
        expect(otpDest.fullName, 'Ahmad Driver');
      },
    );

    test(
      'when applicationStatus is stage 1 (Submitted) -> returns underReview destination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.driver,
          phone: '+96550111222',
          status: 'Submitted',
          applicationStatus: StaffApplicationStatusEntity(
            registrationId: 'reg-1',
            stage: 1,
            badge: 'قيد المراجعة',
            title: 'حسابك قيد المراجعة',
            subtitle: 'طلب التحاقك قيد المراجعة حالياً.',
            isApproved: false,
          ),
        );

        final destination = resolveDriverAuthDestination(lookup);
        expect(destination, isA<DriverAccountStatusDestination>());
        final statusDest = destination as DriverAccountStatusDestination;
        expect(statusDest.kind, AccountStatusKind.underReview);
        expect(statusDest.registrationId, 'reg-1');
      },
    );

    test(
      'when applicationStatus is stage 2 (NeedsChanges) -> returns moreInformationRequired destination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.driver,
          phone: '+96550111222',
          status: 'NeedsChanges',
          applicationStatus: StaffApplicationStatusEntity(
            registrationId: 'reg-2',
            stage: 2,
            canResubmit: true,
            isApproved: false,
          ),
        );

        final destination = resolveDriverAuthDestination(lookup);
        expect(destination, isA<DriverAccountStatusDestination>());
        final statusDest = destination as DriverAccountStatusDestination;
        expect(statusDest.kind, AccountStatusKind.moreInformationRequired);
        expect(statusDest.canResubmit, true);
      },
    );

    test(
      'when applicationStatus is stage 3 (Rejected) -> returns rejected destination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.driver,
          phone: '+96550111222',
          status: 'Rejected',
          applicationStatus: StaffApplicationStatusEntity(
            registrationId: 'reg-3',
            stage: 3,
            isApproved: false,
          ),
        );

        final destination = resolveDriverAuthDestination(lookup);
        expect(destination, isA<DriverAccountStatusDestination>());
        final statusDest = destination as DriverAccountStatusDestination;
        expect(statusDest.kind, AccountStatusKind.rejected);
        expect(statusDest.exception?.errorType, ApiErrorType.forbidden);
      },
    );

    test(
      'when driver is Active and isFirstTimeSetup is false -> returns DriverPasswordLoginDestination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.driver,
          phone: '+96550111222',
          fullName: 'Active Driver',
          status: 'Active',
        );

        final destination = resolveDriverAuthDestination(lookup);
        expect(destination, isA<DriverPasswordLoginDestination>());
        final passDest = destination as DriverPasswordLoginDestination;
        expect(passDest.phone, '+96550111222');
        expect(passDest.fullName, 'Active Driver');
      },
    );
  });
}
