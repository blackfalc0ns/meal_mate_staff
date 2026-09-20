import '../../../../core/network/failures.dart';
import '../../../auth/domain/entities/phone_lookup_result_entity.dart';
import '../../domain/account_status_kind.dart';
import '../../domain/entities/driver_registration_status_entity.dart';

enum AccountStatusStateStatus {
  initial,
  loading,
  loaded,
  activating,
  activationSuccess,
  error,
}

class AccountStatusState {
  const AccountStatusState({
    this.status = AccountStatusStateStatus.initial,
    this.kind = AccountStatusKind.underReview,
    this.statusEntity,
    this.lookupResult,
    this.failure,
    this.errorMessage,
  });

  final AccountStatusStateStatus status;
  final AccountStatusKind kind;
  final DriverRegistrationStatusEntity? statusEntity;
  final PhoneLookupResultEntity? lookupResult;
  final Failure? failure;
  final String? errorMessage;

  bool get isLoading => status == AccountStatusStateStatus.loading;
  bool get isActivating => status == AccountStatusStateStatus.activating;
  bool get hasEntity => statusEntity != null;

  AccountStatusState copyWith({
    AccountStatusStateStatus? status,
    AccountStatusKind? kind,
    DriverRegistrationStatusEntity? statusEntity,
    PhoneLookupResultEntity? lookupResult,
    Failure? failure,
    String? errorMessage,
  }) {
    return AccountStatusState(
      status: status ?? this.status,
      kind: kind ?? this.kind,
      statusEntity: statusEntity ?? this.statusEntity,
      lookupResult: lookupResult ?? this.lookupResult,
      failure: failure ?? this.failure,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
