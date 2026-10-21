import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_reassignment_details_entity.dart';
import '../../domain/entities/reassignment_result_entity.dart';

enum DriverReassignmentStatus {
  idle,
  loadingRequest,
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
    this.activeRequest,
    this.requests = const [],
  });

  final DriverReassignmentStatus status;
  final Failure? failure;
  final ReassignmentResultEntity? result;
  final DriverReassignmentDetailsEntity? activeRequest;
  final List<DriverReassignmentDetailsEntity> requests;

  bool get isLoadingRequest => status == DriverReassignmentStatus.loadingRequest;
  bool get isSubmitting => status == DriverReassignmentStatus.submitting;
  bool get isSuccess => status == DriverReassignmentStatus.succeeded;
  bool get isFailed => status == DriverReassignmentStatus.failed;
  bool get isBlocked =>
      status == DriverReassignmentStatus.blocked ||
      (activeRequest != null && activeRequest!.isRequested);

  bool get hasActiveRequest => activeRequest != null;
  bool get isDecisionPending =>
      activeRequest != null && activeRequest!.isRequested;
  bool get isAccepted => activeRequest != null && activeRequest!.isAccepted;
  bool get isRejected => activeRequest != null && activeRequest!.isRejected;
  bool get isClosed => activeRequest != null && activeRequest!.isClosed;

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
    DriverReassignmentDetailsEntity? activeRequest,
    List<DriverReassignmentDetailsEntity>? requests,
    bool clearFailure = false,
    bool clearResult = false,
    bool clearActiveRequest = false,
  }) {
    return DriverReassignmentState(
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      result: clearResult ? null : (result ?? this.result),
      activeRequest:
          clearActiveRequest ? null : (activeRequest ?? this.activeRequest),
      requests: requests ?? this.requests,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverReassignmentState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          failure == other.failure &&
          result == other.result &&
          activeRequest == other.activeRequest;

  @override
  int get hashCode => Object.hash(status, failure, result, activeRequest);
}
