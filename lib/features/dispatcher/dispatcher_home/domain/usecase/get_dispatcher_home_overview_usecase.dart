import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/dispatcher_home_overview_entity.dart';
import '../repo/dispatcher_home_repository.dart';

@injectable
class GetDispatcherHomeOverviewUseCase {
  const GetDispatcherHomeOverviewUseCase(this._repository);
  final DispatcherHomeRepository _repository;
  Future<ApiResult<DispatcherHomeOverviewEntity>> call() =>
      _repository.getOverview();
}
