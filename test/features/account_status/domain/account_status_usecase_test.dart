import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/account_status/data/data_source/account_status_remote_data_source.dart';
import 'package:meal_mate_delivery/features/account_status/data/models/response/driver_registration_status_response_dto.dart';
import 'package:meal_mate_delivery/features/account_status/data/repo/account_status_repository_impl.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/account_status/domain/entities/driver_registration_status_entity.dart';
import 'package:meal_mate_delivery/features/account_status/domain/repo/account_status_repository.dart';
import 'package:meal_mate_delivery/features/account_status/domain/usecase/get_account_status_usecase.dart';

class FakeAccountStatusRemoteDataSource
    implements AccountStatusRemoteDataSource {
  DriverRegistrationStatusResponseDto response =
      const DriverRegistrationStatusResponseDto();
  Exception? errorToThrow;

  @override
  Future<DriverRegistrationStatusResponseDto> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return response;
  }
}

class FakeAccountStatusRepository implements AccountStatusRepository {
  DriverRegistrationStatusEntity result = const DriverRegistrationStatusEntity(
    registrationId: 'reg-1',
    kind: AccountStatusKind.underReview,
  );

  @override
  Future<ApiResult<DriverRegistrationStatusEntity>> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) async {
    return ApiSuccessResult(data: result);
  }
}

void main() {
  group('GetAccountStatusUseCase Tests', () {
    test('GetAccountStatusUseCase delegates to repository', () async {
      final fakeRepo = FakeAccountStatusRepository();
      fakeRepo.result = const DriverRegistrationStatusEntity(
        registrationId: 'reg-456',
        kind: AccountStatusKind.moreInformationRequired,
        changeRequestNotes: 'Fix driving license',
      );

      final useCase = GetAccountStatusUseCase(fakeRepo);
      final result = await useCase(phone: '+966501234567');

      expect(result, isA<ApiSuccessResult<DriverRegistrationStatusEntity>>());
      final data =
          (result as ApiSuccessResult<DriverRegistrationStatusEntity>).data;
      expect(data.registrationId, 'reg-456');
      expect(data.kind, AccountStatusKind.moreInformationRequired);
      expect(data.changeRequestNotes, 'Fix driving license');
    });
  });

  group('AccountStatusRepositoryImpl Tests', () {
    late FakeAccountStatusRemoteDataSource fakeDataSource;
    late AccountStatusRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeAccountStatusRemoteDataSource();
      repository = AccountStatusRepositoryImpl(fakeDataSource);
    });

    test(
      'getRegistrationStatus maps response DTO to entity on success',
      () async {
        fakeDataSource.response = const DriverRegistrationStatusResponseDto(
          registrationId: 'reg-99',
          status: 'NeedsChanges',
          changeRequestNotes: 'Unclear license',
        );

        final result = await repository.getRegistrationStatus(
          phone: '+966500000000',
        );

        expect(result, isA<ApiSuccessResult<DriverRegistrationStatusEntity>>());
        final data =
            (result as ApiSuccessResult<DriverRegistrationStatusEntity>).data;
        expect(data.registrationId, 'reg-99');
        expect(data.kind, AccountStatusKind.moreInformationRequired);
      },
    );

    test(
      'getRegistrationStatus wraps DioException into ApiErrorResult on failure',
      () async {
        fakeDataSource.errorToThrow = DioException(
          requestOptions: RequestOptions(path: '/status'),
          type: DioExceptionType.connectionTimeout,
        );

        final result = await repository.getRegistrationStatus(
          phone: '+966500000000',
        );

        expect(result, isA<ApiErrorResult<DriverRegistrationStatusEntity>>());
        final failure =
            (result as ApiErrorResult<DriverRegistrationStatusEntity>).failure;
        expect(failure, isNotNull);
      },
    );
  });
}
