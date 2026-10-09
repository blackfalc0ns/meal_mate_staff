import '../../../features/driver/delivery_issues/domain/entities/reassignment_delivery_context_entity.dart';
import '../../../features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';

class DriverReassignmentRouteArguments {
  const DriverReassignmentRouteArguments({
    required this.delivery,
    this.initialRequest,
  });

  final ReassignmentDeliveryContextEntity delivery;
  final ReassignmentRequestEntity? initialRequest;
}
