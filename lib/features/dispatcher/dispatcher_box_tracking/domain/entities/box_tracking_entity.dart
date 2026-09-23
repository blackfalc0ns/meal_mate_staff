import 'box_tracking_driver_entity.dart';
import 'box_tracking_status.dart';
import 'box_tracking_step_entity.dart';

class BoxTrackingEntity {
  const BoxTrackingEntity({
    required this.boxId,
    required this.boxCode,
    required this.status,
    required this.statusText,
    required this.statusColor,
    required this.customerName,
    required this.scheduledTimeText,
    required this.deliveryAddress,
    this.driver,
    required this.programType,
    required this.orderDateText,
    required this.customerNotes,
    required this.mealsSummary,
    this.steps = const [],
  });

  final String boxId;
  final String boxCode;
  final BoxTrackingStatus status;
  final String statusText;
  final String statusColor;
  final String customerName;
  final String scheduledTimeText;
  final String deliveryAddress;
  final BoxTrackingDriverEntity? driver;
  final String programType;
  final String orderDateText;
  final String customerNotes;
  final String mealsSummary;
  final List<BoxTrackingStepEntity> steps;

  // Compatibility getters for legacy callers
  String get deliveryTime => scheduledTimeText;
  String get planType => programType;
  String get orderDate => orderDateText;
  String get mealCount => mealsSummary;
}
