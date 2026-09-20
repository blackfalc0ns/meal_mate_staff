import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

void main() {
  group('UserRole API mapping tests', () {
    test('maps UserRole.driver to Driver and back', () {
      expect(UserRole.driver.apiValue, 'Driver');
      expect(UserRole.fromApiValue('Driver'), UserRole.driver);
      expect(UserRole.fromApiValue('driver'), UserRole.driver);
    });

    test('maps UserRole.operations to DeliveryManager and back', () {
      expect(UserRole.operations.apiValue, 'DeliveryManager');
      expect(UserRole.fromApiValue('DeliveryManager'), UserRole.operations);
      expect(UserRole.fromApiValue('deliverymanager'), UserRole.operations);
    });

    test('defaults to operations for unknown or null role strings', () {
      expect(UserRole.fromApiValue(null), UserRole.operations);
      expect(UserRole.fromApiValue('Unknown'), UserRole.operations);
    });
  });
}
