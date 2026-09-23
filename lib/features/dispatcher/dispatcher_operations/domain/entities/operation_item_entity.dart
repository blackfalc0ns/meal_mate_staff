import 'operation_status.dart';
import 'operations_customer_entity.dart';
import 'operations_driver_entity.dart';
import 'operations_indicator_color.dart';

class OperationItemEntity {
  const OperationItemEntity({
    required this.id,
    required this.boxId,
    required this.boxCode,
    required this.status,
    required this.customer,
    required this.timeText,
    this.occurredAtUtc,
    this.driver,
    this.originalDriver,
    this.replacementDriver,
    this.cancelledBy,
    this.cancelledByText,
  });

  final String id;
  final String boxId;
  final String boxCode;
  final OperationStatus status;
  final OperationsCustomerEntity customer;
  final String timeText;
  final DateTime? occurredAtUtc;
  final OperationsDriverEntity? driver;
  final OperationsDriverEntity? originalDriver;
  final OperationsDriverEntity? replacementDriver;
  final String? cancelledBy;
  final String? cancelledByText;

  // Compatibility getters during transition before fake data and legacy callers are removed
  String get orderId => boxCode;
  String get customerName => customer.name;
  String get area => customer.area;
  String get timestamp => timeText;
  String? get driverName => driver?.name;
  String? get driverAvatarUrl => driver?.avatarUrl;
  bool get isDriverOnline =>
      driver?.indicatorColor == OperationsIndicatorColor.green;
  String? get reassignedToDriverName => replacementDriver?.name;
  String? get reassignedToDriverAvatarUrl => replacementDriver?.avatarUrl;
  String? get cancellationReason => cancelledByText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          boxId == other.boxId &&
          boxCode == other.boxCode &&
          status == other.status &&
          customer == other.customer &&
          timeText == other.timeText &&
          occurredAtUtc == other.occurredAtUtc &&
          driver == other.driver &&
          originalDriver == other.originalDriver &&
          replacementDriver == other.replacementDriver &&
          cancelledBy == other.cancelledBy &&
          cancelledByText == other.cancelledByText;

  @override
  int get hashCode => Object.hash(
    id,
    boxId,
    boxCode,
    status,
    customer,
    timeText,
    occurredAtUtc,
    driver,
    originalDriver,
    replacementDriver,
    cancelledBy,
    cancelledByText,
  );
}
