import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/account_status/domain/entities/driver_registration_status_entity.dart';
import 'package:meal_mate_delivery/features/account_status/domain/repo/account_status_repository.dart';
import 'package:meal_mate_delivery/features/account_status/domain/usecase/get_account_status_usecase.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/manager/account_status_event.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/manager/account_status_state.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/manager/account_status_view_model.dart';

class MockAccountStatusRepository implements AccountStatusRepository {
  DriverRegistrationStatusEntity result = const DriverRegistrationStatusEntity(
    registrationId: 'reg-status-1',
    kind: AccountStatusKind.underReview,
  );
  bool shouldFail = false;

  @override
  Future<ApiResult<DriverRegistrationStatusEntity>> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) async {
    if (shouldFail) {
      return ApiErrorResult(
        failure: ServerFailure.fromDioError(
          dioException: DioException(
            requestOptions: RequestOptions(path: '/status'),
            type: DioExceptionType.badResponse,
          ),
        ),
      );
    }
    return ApiSuccessResult(data: result);
  }
}

void main() {
  group('AccountStatusViewModel Tests', () {
    late MockAccountStatusRepository mockRepo;
    late AccountStatusViewModel viewModel;

    setUp(() {
      mockRepo = MockAccountStatusRepository();
      viewModel = AccountStatusViewModel(
        getAccountStatusUseCase: GetAccountStatusUseCase(mockRepo),
      );
    });

    tearDown(() {
      viewModel.close();
    });

    test('initial state defaults to underReview and initial status', () {
      expect(viewModel.state.status, AccountStatusStateStatus.initial);
      expect(viewModel.state.kind, AccountStatusKind.underReview);
      expect(viewModel.state.hasEntity, isFalse);
    });

    test('AccountStatusSetKindEvent updates kind in state', () {
      viewModel.doIntent(
        const AccountStatusSetKindEvent(AccountStatusKind.rejected),
      );
      expect(viewModel.state.kind, AccountStatusKind.rejected);
    });

    test(
      'AccountStatusLoadEvent emits loading then loaded with entity',
      () async {
        mockRepo.result = const DriverRegistrationStatusEntity(
          registrationId: 'reg-999',
          kind: AccountStatusKind.moreInformationRequired,
          changeRequestNotes: 'Fix documents',
        );

        viewModel.doIntent(
          const AccountStatusLoadEvent(phone: '+966501234567'),
        );

        await Future<void>.delayed(Duration.zero);

        expect(viewModel.state.status, AccountStatusStateStatus.loaded);
        expect(viewModel.state.kind, AccountStatusKind.moreInformationRequired);
        expect(viewModel.state.statusEntity?.registrationId, 'reg-999');
        expect(
          viewModel.state.statusEntity?.changeRequestNotes,
          'Fix documents',
        );
      },
    );

    test(
      'AccountStatusLoadEvent on failure emits error with failure',
      () async {
        mockRepo.shouldFail = true;

        viewModel.doIntent(
          const AccountStatusLoadEvent(phone: '+966501234567'),
        );

        await Future<void>.delayed(Duration.zero);

        expect(viewModel.state.status, AccountStatusStateStatus.error);
        expect(viewModel.state.failure, isNotNull);
        expect(viewModel.state.errorMessage, isNotNull);
      },
    );
  });
}
