import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import '../../domain/entities/driver_pickup_manifest_entity.dart';
import '../../domain/repo/driver_pickup_manifest_repository.dart';
import '../data_source/driver_pickup_manifest_remote_data_source.dart';
import '../mapper/driver_pickup_manifest_mapper.dart';

@LazySingleton(as: DriverPickupManifestRepository)
class DriverPickupManifestRepositoryImpl
    implements DriverPickupManifestRepository {
  const DriverPickupManifestRepositoryImpl(this._remoteDataSource);

  final DriverPickupManifestRemoteDataSource _remoteDataSource;

  @override
  Future<ApiResult<DriverPickupManifestEntity>> getDriverPickupManifest({
    required DriverBoxesFilterType filter,
  }) {
    return safeApiCall<DriverPickupManifestEntity>(() async {
      final dto = await _remoteDataSource.getDriverPickupManifest(
        statusFilter: filter.wireValue,
      );
      return dto.toEntity();
    });
  }
}
