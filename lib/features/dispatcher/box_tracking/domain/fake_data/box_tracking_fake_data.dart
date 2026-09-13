import '../entities/box_tracking_driver_entity.dart';
import '../entities/box_tracking_entity.dart';
import '../entities/box_tracking_step_entity.dart';

class BoxTrackingFakeData {
  const BoxTrackingFakeData._();

  static const BoxTrackingDriverEntity defaultDriver = BoxTrackingDriverEntity(
    id: 'DR-1025',
    name: 'أحمد السعيد',
    phone: '+966 50 123 4567',
    isOnline: true,
  );

  static const List<BoxTrackingStepEntity> defaultSteps = [
    BoxTrackingStepEntity(
      title: 'جاهز في المطعم',
      time: 'اليوم 10:15 ص',
      isCompleted: true,
      isActive: false,
    ),
    BoxTrackingStepEntity(
      title: 'استلمه السائق',
      time: 'اليوم 10:28 ص',
      isCompleted: true,
      isActive: false,
    ),
    BoxTrackingStepEntity(
      title: 'في الطريق للتوصيل',
      time: 'اليوم 10:45 ص',
      isCompleted: false,
      isActive: true,
    ),
    BoxTrackingStepEntity(
      title: 'تم التسليم',
      time: null,
      isCompleted: false,
      isActive: false,
    ),
  ];

  static const BoxTrackingEntity defaultBox = BoxTrackingEntity(
    boxId: 'BX-10256',
    customerName: 'أحمد العتيبي',
    deliveryAddress: 'السليمانية، الرياض',
    deliveryTime: '12:30 م',
    status: BoxTrackingStatus.onTheWay,
    driver: defaultDriver,
    planType: 'دايت متوازن',
    orderDate: 'اليوم 09:50 ص',
    mealCount: '3 وجبات (يوم كامل)',
    customerNotes: 'يرجى الاتصال قبل الوصول',
    steps: defaultSteps,
  );
}
