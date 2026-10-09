import '../../../../../core/network/failures.dart';
import '../../domain/entities/reassignment_result_entity.dart';

enum DriverReassignmentStatus {
  idle,
  submitting,
  succeeded,
  failed,
  blocked,
}

class DriverReassignmentState {
  const DriverReassignmentState({
    this.status = DriverReassignmentStatus.idle,
    this.failure,
    this.result,
  });

  final DriverReassignmentStatus status;
  final Failure? failure;
  final ReassignmentResultEntity? result;

  bool get isSubmitting => status == DriverReassignmentStatus.submitting;
  bool get isSuccess => status == DriverReassignmentStatus.succeeded;
  bool get isFailed => status == DriverReassignmentStatus.failed;
  bool get isBlocked => status == DriverReassignmentStatus.blocked;

  bool get isAlreadyActiveConflict {
    final code = failure?.code;
    final backendCode = failure?.exception.backendErrorCode;
    return code == 'driver.reassignment.request_already_active' ||
        backendCode == 'driver.reassignment.request_already_active';
  }

  bool get isStopStateNotAllowed {
    final code = failure?.code;
    final backendCode = failure?.exception.backendErrorCode;
    return code == 'driver.reassignment.stop_state_not_allowed' ||
        backendCode == 'driver.reassignment.stop_state_not_allowed';
  }

  DriverReassignmentState copyWith({
    DriverReassignmentStatus? status,
    Failure? failure,
    ReassignmentResultEntity? result,
    bool clearFailure = false,
    bool clearResult = false,
  }) {
    return DriverReassignmentState(
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverReassignmentState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          failure == other.failure &&
          result == other.result;

  @override
  int get hashCode => Object.hash(status, failure, result);
}
