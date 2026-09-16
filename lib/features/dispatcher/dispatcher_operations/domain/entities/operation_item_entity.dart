import 'operation_status.dart';

class OperationItemEntity {
  const OperationItemEntity({
    required this.id,
    required this.orderId,
    required this.status,
    required this.customerName,
    required this.area,
    required this.timestamp,
    this.driverName,
    this.driverAvatarUrl,
    this.isDriverOnline = true,
    this.reassignedToDriverName,
    this.reassignedToDriverAvatarUrl,
    this.cancellationReason,
  });

  final String id;
  final String orderId;
  final OperationStatus status;
  final String customerName;
  final String area;
  final String timestamp;
  final String? driverName;
  final String? driverAvatarUrl;
  final bool isDriverOnline;
  final String? reassignedToDriverName;
  final String? reassignedToDriverAvatarUrl;
  final String? cancellationReason;
}
