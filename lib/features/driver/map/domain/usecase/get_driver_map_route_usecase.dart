import 'package:injectable/injectable.dart';

import '../../../../core/network/api_results.dart';
import '../entities/driver_map_route_entity.dart';
import '../repo/driver_map_repository.dart';

@injectable
class GetDriverMapRouteUseCase {
  const GetDriverMapRouteUseCase(this._repository);

  final DriverMapRepository _repository;

  Future<ApiResult<DriverMapRouteEntity>> call({String? focusedStopId}) {
    return _repository.getDriverMapRoute(focusedStopId: focusedStopId);
  }
}
