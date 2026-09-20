import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../../domain/entities/driver_registration_status_entity.dart';
import '../../domain/repo/account_status_repository.dart';
import '../data_source/account_status_remote_data_source.dart';
import '../mapper/account_status_mapper.dart';

@LazySingleton(as: AccountStatusRepository)
class AccountStatusRepositoryImpl implements AccountStatusRepository {
  const AccountStatusRepositoryImpl(this._remoteDataSource);

  final AccountStatusRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverRegistrationStatusEntity>> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) {
    return safeApiCall<DriverRegistrationStatusEntity>(() async {
      final dto = await _remoteDataSource.getRegistrationStatus(
        phone: phone,
        registrationId: registrationId,
      );
      return dto.toEntity();
    });
  }
}
