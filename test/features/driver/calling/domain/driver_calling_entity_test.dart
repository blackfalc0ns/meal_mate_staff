import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_active_call_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/fake_data/driver_calling_fake_data.dart';

void main() {
  group('DriverActiveCallEntity & DriverCallingFakeData', () {
    test('DriverActiveCallEntity instantiates with correct fields and supports copyWith', () {
      const entity = DriverActiveCallEntity(
        customerName: 'محمد علي',
        addressLine: 'شارع الخليج العربي ، قطعة 12 ، منزل 45',
        area: 'السلمانية',
        initialDurationSeconds: 24,
      );

      expect(entity.customerName, 'محمد علي');
      expect(entity.addressLine, 'شارع الخليج العربي ، قطعة 12 ، منزل 45');
      expect(entity.area, 'السلمانية');
      expect(entity.initialDurationSeconds, 24);

      final updated = entity.copyWith(initialDurationSeconds: 30);
      expect(updated.initialDurationSeconds, 30);
      expect(updated.customerName, 'محمد علي');
    });

    test('DriverCallingFakeData provides default activeCall matching Figma node 2090-5549', () {
      const activeCall = DriverCallingFakeData.activeCall;

      expect(activeCall.customerName, 'محمد علي');
      expect(activeCall.addressLine, 'شارع الخليج العربي ، قطعة 12 ، منزل 45');
      expect(activeCall.area, 'السلمانية');
      expect(activeCall.initialDurationSeconds, 24);
    });
  });
}
