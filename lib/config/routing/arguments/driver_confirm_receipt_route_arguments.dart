import '../../../features/driver/orders/domain/entities/driver_assigned_box_entity.dart';

class DriverConfirmReceiptRouteArguments {
  const DriverConfirmReceiptRouteArguments({this.box, this.tripId});

  final DriverAssignedBoxEntity? box;
  final String? tripId;
}
