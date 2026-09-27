import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_boxes_filter_type.dart';
import '../entities/driver_pickup_manifest_entity.dart';
import '../repo/driver_pickup_manifest_repository.dart';

@injectable
class GetDriverPickupManifestUseCase {
  const GetDriverPickupManifestUseCase(this._repository);

  final DriverPickupManifestRepository _repository;

  Future<ApiResult<DriverPickupManifestEntity>> call(
    DriverBoxesFilterType filter,
  ) {
    return _repository.getDriverPickupManifest(filter: filter);
  }
}
