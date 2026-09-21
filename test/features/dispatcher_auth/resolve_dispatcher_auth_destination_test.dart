import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/features/auth/domain/entities/phone_lookup_result_entity.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/dispatcher_auth/domain/dispatcher_auth_destination.dart';
import 'package:meal_mate_delivery/features/dispatcher_auth/domain/resolve_dispatcher_auth_destination.dart';

void main() {
  group('resolveDispatcherAuthDestination Table-Driven Tests', () {
    test(
      'when delivery manager account does not exist -> returns DispatcherAccountNotFoundDestination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: false,
          isFirstTimeSetup: false,
          role: UserRole.operations,
          phone: '+96550999888',
        );

        final destination = resolveDispatcherAuthDestination(lookup);
        expect(destination, isA<DispatcherAccountNotFoundDestination>());
        final notFound = destination as DispatcherAccountNotFoundDestination;
        expect(notFound.phone, '+96550999888');
        expect(notFound.exception.errorType, ApiErrorType.notFound);
      },
    );

    test(
      'when isFirstTimeSetup is true -> returns DispatcherFirstTimeOtpDestination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: true,
          role: UserRole.operations,
          phone: '+96550999888',
          fullName: 'Operations Manager',
          restaurantName: 'Protein Lab',
        );

        final destination = resolveDispatcherAuthDestination(lookup);
        expect(destination, isA<DispatcherFirstTimeOtpDestination>());
        final otpDest = destination as DispatcherFirstTimeOtpDestination;
        expect(otpDest.phone, '+96550999888');
        expect(otpDest.fullName, 'Operations Manager');
        expect(otpDest.restaurantName, 'Protein Lab');
      },
    );

    test(
      'when manager exists and isFirstTimeSetup is false -> returns DispatcherPasswordLoginDestination',
      () {
        const lookup = PhoneLookupResultEntity(
          exists: true,
          isFirstTimeSetup: false,
          role: UserRole.operations,
          phone: '+96550999888',
          fullName: 'Existing Manager',
          status: 'Active',
        );

        final destination = resolveDispatcherAuthDestination(lookup);
        expect(destination, isA<DispatcherPasswordLoginDestination>());
        final passDest = destination as DispatcherPasswordLoginDestination;
        expect(passDest.phone, '+96550999888');
        expect(passDest.fullName, 'Existing Manager');
      },
    );
  });
}
