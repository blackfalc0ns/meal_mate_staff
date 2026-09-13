import 'box_tracking_driver_entity.dart';
import 'box_tracking_step_entity.dart';

enum BoxTrackingStatus {
  readyAtRestaurant,
  pickedUpByDriver,
  onTheWay,
  delivered,
}

class BoxTrackingEntity {
  const BoxTrackingEntity({
    required this.boxId,
    required this.customerName,
    required this.deliveryAddress,
    required this.deliveryTime,
    required this.status,
    required this.driver,
    required this.planType,
    required this.orderDate,
    required this.mealCount,
    required this.customerNotes,
    required this.steps,
  });

  final String boxId;
  final String customerName;
  final String deliveryAddress;
  final String deliveryTime;
  final BoxTrackingStatus status;
  final BoxTrackingDriverEntity driver;
  final String planType;
  final String orderDate;
  final String mealCount;
  final String customerNotes;
  final List<BoxTrackingStepEntity> steps;
}
