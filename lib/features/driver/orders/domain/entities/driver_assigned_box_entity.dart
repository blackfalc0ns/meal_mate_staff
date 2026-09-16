import 'driver_box_delivery_status.dart';

class DriverAssignedBoxEntity {
  const DriverAssignedBoxEntity({
    required this.boxId,
    required this.orderCode,
    required this.mealCount,
    required this.area,
    this.status = DriverBoxDeliveryStatus.ready,
    this.isLoaded = false,
  });

  final String boxId;
  final String orderCode;
  final int mealCount;
  final String area;
  final DriverBoxDeliveryStatus status;
  final bool isLoaded;

  DriverAssignedBoxEntity copyWith({
    String? boxId,
    String? orderCode,
    int? mealCount,
    String? area,
    DriverBoxDeliveryStatus? status,
    bool? isLoaded,
  }) {
    return DriverAssignedBoxEntity(
      boxId: boxId ?? this.boxId,
      orderCode: orderCode ?? this.orderCode,
      mealCount: mealCount ?? this.mealCount,
      area: area ?? this.area,
      status: status ?? this.status,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
