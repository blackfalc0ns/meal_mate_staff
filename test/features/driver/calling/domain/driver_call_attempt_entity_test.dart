import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_call_attempt_entity.dart';

void main() {
  group('DriverCallAttemptEntity', () {
    test('instantiates with default values and supports copyWith', () {
      const entity = DriverCallAttemptEntity(
        customerName: 'محمد علي',
        customerPhone: '+966 50 123 4567',
        attemptNumber: 1,
      );

      expect(entity.customerName, 'محمد علي');
      expect(entity.customerPhone, '+966 50 123 4567');
      expect(entity.attemptNumber, 1);
      expect(entity.isPhoneUnlocked, isFalse);

      final updated = entity.copyWith(attemptNumber: 3);
      expect(updated.attemptNumber, 3);
      expect(updated.isPhoneUnlocked, isTrue);
    });

    test('supports value equality and hashCode', () {
      const e1 = DriverCallAttemptEntity(
        customerName: 'محمد علي',
        customerPhone: '+966 50 123 4567',
        attemptNumber: 2,
      );
      const e2 = DriverCallAttemptEntity(
        customerName: 'محمد علي',
        customerPhone: '+966 50 123 4567',
        attemptNumber: 2,
      );

      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
    });
  });
}
