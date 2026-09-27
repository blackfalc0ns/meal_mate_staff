import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_drivers_status_query_entity.dart';
import '../entities/dispatcher_drivers_status_summary_entity.dart';
import '../repo/dispatcher_drivers_status_repository.dart';

@injectable
class GetDriversStatusUseCase {
  const GetDriversStatusUseCase(this._repository);

  final DispatcherDriversStatusRepository _repository;

  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> call([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) {
    return _repository.getDriversStatus(query);
  }
}
