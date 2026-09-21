import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_home_map_driver_pin_entity.dart';
import '../repo/dispatcher_home_repository.dart';

@injectable
class GetDispatcherLiveDriversUseCase {
  const GetDispatcherLiveDriversUseCase(this._repository);
  final DispatcherHomeRepository _repository;
  Future<ApiResult<List<DispatcherHomeMapDriverPinEntity>>> call() =>
      _repository.getLiveDrivers();
}
