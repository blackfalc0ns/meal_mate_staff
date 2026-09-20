import '../../../../core/network/failures.dart';
import '../../domain/account_status_kind.dart';
import '../../domain/entities/driver_registration_status_entity.dart';

enum AccountStatusStateStatus {
  initial,
  loading,
  loaded,
  error,
}

class AccountStatusState {
  const AccountStatusState({
    this.status = AccountStatusStateStatus.initial,
    this.kind = AccountStatusKind.underReview,
    this.statusEntity,
    this.failure,
    this.errorMessage,
  });

  final AccountStatusStateStatus status;
  final AccountStatusKind kind;
  final DriverRegistrationStatusEntity? statusEntity;
  final Failure? failure;
  final String? errorMessage;

  bool get isLoading => status == AccountStatusStateStatus.loading;
  bool get hasEntity => statusEntity != null;

  AccountStatusState copyWith({
    AccountStatusStateStatus? status,
    AccountStatusKind? kind,
    DriverRegistrationStatusEntity? statusEntity,
    Failure? failure,
    String? errorMessage,
  }) {
    return AccountStatusState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      statusEntity: statusEntity ?? this.statusEntity,
      failure: failure ?? this.failure,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
