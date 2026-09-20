import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../../auth/domain/entities/phone_lookup_request_entity.dart';
import '../../../auth/domain/user_role.dart';
import '../../../auth/domain/usecase/lookup_phone_usecase.dart';
import '../../domain/usecase/get_account_status_usecase.dart';
import 'account_status_event.dart';
import 'account_status_state.dart';

@injectable
class AccountStatusViewModel extends Cubit<AccountStatusState> {
  AccountStatusViewModel({
    required this.getAccountStatusUseCase,
    this.lookupPhoneUseCase,
  }) : super(const AccountStatusState());

  final GetAccountStatusUseCase getAccountStatusUseCase;
  final LookupPhoneUseCase? lookupPhoneUseCase;

  void doIntent(AccountStatusEvent event) {
    switch (event) {
      case AccountStatusLoadEvent(:final phone, :final registrationId):
        _handleLoadStatus(phone, registrationId);
      case AccountStatusSetKindEvent(:final kind):
        emit(state.copyWith(kind: kind));
      case AccountStatusActivateApprovedEvent(:final phone):
        _handleActivateApproved(phone);
    }
  }

  Future<void> _handleLoadStatus(String? phone, String? registrationId) async {
    emit(state.copyWith(status: AccountStatusStateStatus.loading));

    final result = await getAccountStatusUseCase(
      phone: phone,
      registrationId: registrationId,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: AccountStatusStateStatus.loaded,
            kind: data.kind,
            statusEntity: data,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: AccountStatusStateStatus.error,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _handleActivateApproved(String phone) async {
    if (lookupPhoneUseCase == null) return;
    emit(state.copyWith(status: AccountStatusStateStatus.activating));

    final result = await lookupPhoneUseCase!(
      PhoneLookupRequestEntity(
        phone: phone,
        role: UserRole.driver,
      ),
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            status: AccountStatusStateStatus.activationSuccess,
            lookupResult: data,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            status: AccountStatusStateStatus.error,
            failure: failure,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }
}
