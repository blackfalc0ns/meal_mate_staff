import 'package:injectable/injectable.dart';

import '../../../../core/network/api_services.dart';
import '../models/response/driver_registration_status_response_dto.dart';
import 'account_status_remote_data_source.dart';

@LazySingleton(as: AccountStatusRemoteDataSource)
class AccountStatusRemoteDataSourceImpl
    implements AccountStatusRemoteDataSource {
  const AccountStatusRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverRegistrationStatusResponseDto> getRegistrationStatus({
    String? phone,
    String? registrationId,
  }) =>
      _apiServices.getDriverRegistrationStatus(
        phone: phone,
        registrationId: registrationId,
      );
}
