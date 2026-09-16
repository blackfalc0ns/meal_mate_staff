import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/fake_data/box_tracking_fake_data.dart';

void main() {
  group('BoxTrackingEntity & Fake Data Tests', () {
    test('defaultBox has valid attributes matching Figma specs', () {
      final box = BoxTrackingFakeData.defaultBox;

      expect(box.boxId, 'BX-10256');
      expect(box.customerName, 'أحمد العتيبي');
      expect(box.deliveryAddress, 'السليمانية، الرياض');
      expect(box.deliveryTime, '12:30 م');
      expect(box.status, BoxTrackingStatus.onTheWay);
      expect(box.planType, 'دايت متوازن');
      expect(box.orderDate, 'اليوم 09:50 ص');
      expect(box.mealCount, '3 وجبات (يوم كامل)');
      expect(box.customerNotes, 'يرجى الاتصال قبل الوصول');

      expect(box.driver.id, 'DR-1025');
      expect(box.driver.name, 'أحمد السعيد');
      expect(box.driver.isOnline, isTrue);

      expect(box.steps.length, 4);
      expect(box.steps[0].isCompleted, isTrue);
      expect(box.steps[1].isCompleted, isTrue);
      expect(box.steps[2].isActive, isTrue);
      expect(box.steps[3].isCompleted, isFalse);
      expect(box.steps[3].isActive, isFalse);
    });

    test('entity properties are retained properly on custom instance', () {
      const driver = BoxTrackingDriverEntity(
        id: 'DR-999',
        name: 'سالم أحمد',
        phone: '+966 55 000 0000',
        isOnline: false,
      );

      const step = BoxTrackingStepEntity(
        title: 'جاهز في المطعم',
        time: '10:00 ص',
        isCompleted: true,
        isActive: false,
      );

      const entity = BoxTrackingEntity(
        boxId: 'BX-999',
        customerName: 'فهد محمد',
        deliveryAddress: 'حي النخيل، الرياض',
        deliveryTime: '01:00 م',
        status: BoxTrackingStatus.readyAtRestaurant,
        driver: driver,
        planType: 'كيتو',
        orderDate: 'أمس 08:00 م',
        mealCount: '2 وجبات',
        customerNotes: 'ملاحظة خاصة',
        steps: [step],
      );

      expect(entity.boxId, 'BX-999');
      expect(entity.driver.name, 'سالم أحمد');
      expect(entity.steps.first.title, 'جاهز في المطعم');
    });
  });
}
