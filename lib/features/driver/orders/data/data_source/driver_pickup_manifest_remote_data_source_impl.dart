import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/driver_pickup_manifest_response_dto.dart';
import 'driver_pickup_manifest_remote_data_source.dart';

@LazySingleton(as: DriverPickupManifestRemoteDataSource)
class DriverPickupManifestRemoteDataSourceImpl
    implements DriverPickupManifestRemoteDataSource {
  const DriverPickupManifestRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverPickupManifestResponseDto> getDriverPickupManifest({
    required String statusFilter,
  }) {
    return _apiServices.getDriverPickupManifest(statusFilter);
  }
}
