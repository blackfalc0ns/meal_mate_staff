import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../domain/usecase/get_account_status_usecase.dart';
import 'account_status_event.dart';
import 'account_status_state.dart';

@injectable
class AccountStatusViewModel extends Cubit<AccountStatusState> {
  AccountStatusViewModel({
    required this.getAccountStatusUseCase,
  }) : super(const AccountStatusState());

  final GetAccountStatusUseCase getAccountStatusUseCase;

  void doIntent(AccountStatusEvent event) {
    switch (event) {
      case AccountStatusLoadEvent(:final phone, :final registrationId):
        _handleLoadStatus(phone, registrationId);
      case AccountStatusSetKindEvent(:final kind):
        emit(state.copyWith(kind: kind));
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
}
