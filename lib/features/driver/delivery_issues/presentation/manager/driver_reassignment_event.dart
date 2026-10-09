import '../../domain/entities/reassignment_request_entity.dart';

sealed class DriverReassignmentEvent {
  const DriverReassignmentEvent();
}

class SubmitDriverReassignmentEvent extends DriverReassignmentEvent {
  const SubmitDriverReassignmentEvent({
    required this.boxId,
    required this.request,
  });

  final String boxId;
  final ReassignmentRequestEntity request;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmitDriverReassignmentEvent &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          request == other.request;

  @override
  int get hashCode => Object.hash(boxId, request);
}

class ResetDriverReassignmentStatusEvent extends DriverReassignmentEvent {
  const ResetDriverReassignmentStatusEvent();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResetDriverReassignmentStatusEvent &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;
}
