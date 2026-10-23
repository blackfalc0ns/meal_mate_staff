import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../entities/driver_support_issues_page_entity.dart';
import '../entities/driver_support_issues_query_entity.dart';
import '../repo/driver_support_repository.dart';

@injectable
class GetDriverSupportIssuesUseCase {
  const GetDriverSupportIssuesUseCase(this._repository);

  final DriverSupportRepository _repository;

  Future<ApiResult<DriverSupportIssuesPageEntity>> call(
    DriverSupportIssuesQueryEntity query,
  ) {
    return _repository.getSupportIssues(query);
  }
}
