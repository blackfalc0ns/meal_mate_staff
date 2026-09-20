import '../../domain/account_status_kind.dart';

sealed class AccountStatusEvent {
  const AccountStatusEvent();
}

class AccountStatusLoadEvent extends AccountStatusEvent {
  const AccountStatusLoadEvent({
    this.phone,
    this.registrationId,
  });

  final String? phone;
  final String? registrationId;
}

class AccountStatusSetKindEvent extends AccountStatusEvent {
  const AccountStatusSetKindEvent(this.kind);

  final AccountStatusKind kind;
}
